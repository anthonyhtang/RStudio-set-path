param(
  [string]$RStudioExe = "C:\Program Files\RStudio\rstudio.exe",
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName UIAutomationClient

function Write-Log {
  param([string]$Message)
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host "[$timestamp] $Message"
}

function Get-RStudioProcess {
  $proc = Get-Process rstudio -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 } |
    Sort-Object StartTime |
    Select-Object -First 1

  if ($null -eq $proc) {
    throw "Could not find an RStudio process with a visible main window."
  }

  $proc.Refresh()
  $proc
}

function Wait-Until {
  param(
    [scriptblock]$Condition,
    [int]$TimeoutSeconds = 20,
    [int]$PollMilliseconds = 250,
    [string]$Description = "condition"
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    if (& $Condition) {
      return
    }
    Start-Sleep -Milliseconds $PollMilliseconds
  }

  throw "Timed out waiting for $Description."
}

function Focus-RStudio {
  param([int]$ProcessId)

  $shell = New-Object -ComObject WScript.Shell
  if (-not $shell.AppActivate($ProcessId)) {
    throw "Failed to activate RStudio window for PID $ProcessId."
  }
  Start-Sleep -Milliseconds 600
}

function Send-Keys {
  param(
    [string]$Keys,
    [int]$DelayMilliseconds = 700
  )

  [System.Windows.Forms.SendKeys]::SendWait($Keys)
  Start-Sleep -Milliseconds $DelayMilliseconds
}

function Invoke-CommandPalette {
  param([string]$SearchText)

  Set-Clipboard -Value $SearchText
  Send-Keys "^+p" 900
  Send-Keys "^a" 300
  Send-Keys "^v" 500
  Send-Keys "{ENTER}" 1800
}

function Invoke-ConsoleCommand {
  param([string]$Command)

  Set-Clipboard -Value $Command
  Send-Keys "^2" 500
  Send-Keys "^v" 300
  Send-Keys "{ENTER}" 1500
}

function Get-Ancestors {
  param([System.Windows.Automation.AutomationElement]$Element)

  $walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
  $ancestors = @()
  $cursor = $Element
  for ($i = 0; $i -lt 6 -and $null -ne $cursor; $i++) {
    $ancestors += [PSCustomObject]@{
      Name = $cursor.Current.Name
      ClassName = $cursor.Current.ClassName
      ControlType = $cursor.Current.ControlType.ProgrammaticName
    }
    $cursor = $walker.GetParent($cursor)
  }
  $ancestors
}

function Get-FocusSnapshot {
  $element = [System.Windows.Automation.AutomationElement]::FocusedElement
  if ($null -eq $element) {
    return [PSCustomObject]@{
      Name = ""
      ClassName = ""
      ControlType = ""
      LocalizedControlType = ""
      AutomationId = ""
      Ancestors = @()
    }
  }

  [PSCustomObject]@{
    Name = $element.Current.Name
    ClassName = $element.Current.ClassName
    ControlType = $element.Current.ControlType.ProgrammaticName
    LocalizedControlType = $element.Current.LocalizedControlType
    AutomationId = $element.Current.AutomationId
    Ancestors = Get-Ancestors -Element $element
  }
}

function Normalize-PathForR {
  param([string]$Path)
  ($Path -replace "\\", "/")
}

function Normalize-ComparablePath {
  param([string]$Path)
  [IO.Path]::GetFullPath($Path).TrimEnd("\") -replace "\\", "/"
}

$artifactDir = Join-Path $Root "manual-test-artifacts"
$caseDir = Join-Path $artifactDir "active-file-case"
$caseFile = Join-Path $caseDir "focus-case.R"
$wdOut = Join-Path $artifactDir "active-file-getwd.txt"
$summaryOut = Join-Path $artifactDir "manual-rstudio-summary.json"

New-Item -ItemType Directory -Force -Path $caseDir | Out-Null
Set-Content -Path $caseFile -Encoding UTF8 -Value @(
  "# manual verification file",
  "message('quickwd manual test')"
)
Remove-Item -Force -ErrorAction SilentlyContinue $wdOut, $summaryOut

$originalClipboard = $null
try {
  $originalClipboard = Get-Clipboard -Raw -ErrorAction Stop
} catch {
  $originalClipboard = $null
}

try {
  Write-Log "Opening test file in RStudio: $caseFile"
  Start-Process -FilePath $RStudioExe -ArgumentList ('"' + $caseFile + '"') | Out-Null
  Start-Sleep -Seconds 5

  $proc = Get-RStudioProcess
  Focus-RStudio -ProcessId $proc.Id

  Write-Log "Running add-in from the command palette on first use after open"
  Send-Keys "^{1}" 600
  Invoke-CommandPalette -SearchText "quick working directory active file"
  $focusAfterAddin = Get-FocusSnapshot

  Write-Log "Capturing working directory from the R session"
  $wdCommand = "writeLines(getwd(), '" + (Normalize-PathForR -Path $wdOut) + "')"
  Invoke-ConsoleCommand -Command $wdCommand
  Wait-Until -Description "working-directory output" -TimeoutSeconds 15 -Condition {
    (Test-Path $wdOut) -and ((Get-Item $wdOut).Length -gt 0)
  }

  Write-Log "Running built-in activate files command for focus comparison"
  Focus-RStudio -ProcessId $proc.Id
  Invoke-CommandPalette -SearchText "activate files"
  $focusAfterBuiltin = Get-FocusSnapshot

  $expectedDir = (Resolve-Path $caseDir).Path
  $actualDir = (Get-Content -Path $wdOut -Raw).Trim()
  $expectedComparable = Normalize-ComparablePath -Path $expectedDir
  $actualComparable = Normalize-ComparablePath -Path $actualDir

  $sameFocusTarget =
    ($focusAfterAddin.ClassName -eq $focusAfterBuiltin.ClassName) -and
    ($focusAfterAddin.ControlType -eq $focusAfterBuiltin.ControlType)

  $summary = [PSCustomObject]@{
    TestedAt = (Get-Date).ToString("s")
    RStudioPid = $proc.Id
    CaseFile = $caseFile
    ExpectedWorkingDirectory = $expectedDir
    ActualWorkingDirectory = $actualDir
    WorkingDirectoryMatched = ($actualComparable -eq $expectedComparable)
    FocusAfterAddin = $focusAfterAddin
    FocusAfterBuiltinActivateFiles = $focusAfterBuiltin
    FocusMatchedBuiltinActivateFiles = $sameFocusTarget
  }

  $summary | ConvertTo-Json -Depth 6 | Set-Content -Path $summaryOut -Encoding UTF8
  Write-Log "Manual test summary written to $summaryOut"
  Get-Content -Path $summaryOut
}
finally {
  if ($null -ne $originalClipboard) {
    Set-Clipboard -Value $originalClipboard
  }
}
