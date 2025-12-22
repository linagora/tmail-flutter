#Requires -Version 5.1
# Custom Claude Code statusline for PowerShell
# Cross-platform support: Windows PowerShell 5.1+, PowerShell Core 7+
# Theme: detailed | Colors: true | Features: directory, git, model, usage, session, tokens

# Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Enable virtual terminal sequences for ANSI colors
function Enable-VirtualTerminal {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell Core 7+ has built-in support
        return
    }

    # Windows PowerShell 5.1 - enable virtual terminal
    try {
        $null = [System.Console]::OutputEncoding
        if ($PSVersionTable.PSVersion.Major -eq 5) {
            # Attempt to enable virtual terminal processing
            $signature = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
'@
            $type = Add-Type -MemberDefinition $signature -Name 'WinAPI' -Namespace 'VirtualTerminal' -PassThru -ErrorAction SilentlyContinue
            if ($type) {
                $handle = $type::GetStdHandle(-11) # STD_OUTPUT_HANDLE
                $mode = 0
                $null = $type::GetConsoleMode($handle, [ref]$mode)
                $mode = $mode -bor 0x0004 # ENABLE_VIRTUAL_TERMINAL_PROCESSING
                $null = $type::SetConsoleMode($handle, $mode)
            }
        }
    }
    catch {
        # Silent fail - colors just won't work
    }
}

# Initialize color support
$script:UseColor = $true
if ($env:NO_COLOR) {
    $script:UseColor = $false
}
elseif (-not [Console]::IsOutputRedirected -and [Console]::OutputEncoding) {
    Enable-VirtualTerminal
}
else {
    $script:UseColor = $false
}

# Color helper functions
function Get-Color {
    param([string]$Code)
    if ($script:UseColor) { return "`e[${Code}m" }
    return ""
}

function Get-Reset {
    if ($script:UseColor) { return "`e[0m" }
    return ""
}

# Color definitions
$DirColor = Get-Color "1;36"      # cyan
$GitColor = Get-Color "1;32"      # green
$ModelColor = Get-Color "1;35"    # magenta
$VersionColor = Get-Color "1;33"  # yellow
$UsageColor = Get-Color "1;35"    # magenta
$CostColor = Get-Color "1;36"     # cyan
$Reset = Get-Reset

# Time conversion functions
function ConvertTo-Epoch {
    param([string]$Timestamp)

    try {
        # Parse ISO8601 timestamp
        $dt = [DateTime]::Parse($Timestamp).ToUniversalTime()
        $epoch = [DateTimeOffset]::new($dt).ToUnixTimeSeconds()
        return $epoch
    }
    catch {
        return 0
    }
}

function Format-TimeHM {
    param([long]$Epoch)

    try {
        $dt = [DateTimeOffset]::FromUnixTimeSeconds($Epoch).LocalDateTime
        return $dt.ToString("HH:mm")
    }
    catch {
        return "00:00"
    }
}

function Get-ProgressBar {
    param(
        [int]$Percent = 0,
        [int]$Width = 10
    )

    if ($Percent -lt 0) { $Percent = 0 }
    if ($Percent -gt 100) { $Percent = 100 }

    $filled = [Math]::Floor($Percent * $Width / 100)
    $empty = $Width - $filled

    $bar = ("=" * $filled) + ("-" * $empty)
    return $bar
}

function Get-SessionColor {
    param([int]$SessionPercent)

    if (-not $script:UseColor) { return "" }

    $remaining = 100 - $SessionPercent
    if ($remaining -le 10) {
        return "`e[1;31m"  # red
    }
    elseif ($remaining -le 25) {
        return "`e[1;33m"  # yellow
    }
    else {
        return "`e[1;32m"  # green
    }
}

# Read JSON from stdin
try {
    $inputLines = @()
    while ($null -ne ($line = [Console]::In.ReadLine())) {
        $inputLines += $line
    }
    $inputJson = $inputLines -join "`n"

    if ([string]::IsNullOrWhiteSpace($inputJson)) {
        Write-Error "No input provided"
        exit 1
    }

    $data = $inputJson | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON input: $_"
    exit 1
}

# Extract basic information
$currentDir = "unknown"
if ($data.workspace.current_dir) {
    $currentDir = $data.workspace.current_dir
}
elseif ($data.cwd) {
    $currentDir = $data.cwd
}

# Replace home directory with ~
$homeDir = $env:USERPROFILE
if (-not $homeDir) {
    $homeDir = $env:HOME
}
if ($homeDir -and $currentDir.StartsWith($homeDir)) {
    $currentDir = $currentDir.Replace($homeDir, "~")
}

$modelName = "Claude"
if ($data.model.display_name) {
    $modelName = $data.model.display_name
}

$modelVersion = ""
if ($data.model.version -and $data.model.version -ne "null") {
    $modelVersion = $data.model.version
}

# Git branch detection
$gitBranch = ""
try {
    $null = git rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -eq 0) {
        $gitBranch = git branch --show-current 2>$null
        if ([string]::IsNullOrWhiteSpace($gitBranch)) {
            $gitBranch = git rev-parse --short HEAD 2>$null
        }
    }
}
catch {
    # Not in a git repository
}

# ccusage integration
$sessionText = ""
$sessionPercent = 0
$sessionBar = ""
$costUSD = ""
$costPerHour = ""
$totalTokens = ""

try {
    # Try npx first, then ccusage
    $blocksOutput = $null
    try {
        $blocksOutput = npx ccusage@latest blocks --json 2>$null
    }
    catch {
        try {
            $blocksOutput = ccusage blocks --json 2>$null
        }
        catch {
            # ccusage not available
        }
    }

    if ($blocksOutput) {
        $blocks = $blocksOutput | ConvertFrom-Json
        $activeBlock = $blocks.blocks | Where-Object { $_.isActive -eq $true } | Select-Object -First 1

        if ($activeBlock) {
            if ($activeBlock.costUSD) {
                $costUSD = $activeBlock.costUSD
            }
            if ($activeBlock.burnRate.costPerHour) {
                $costPerHour = $activeBlock.burnRate.costPerHour
            }
            if ($activeBlock.totalTokens) {
                $totalTokens = $activeBlock.totalTokens
            }

            # Session time calculation
            $resetTimeStr = $activeBlock.usageLimitResetTime
            if (-not $resetTimeStr) {
                $resetTimeStr = $activeBlock.endTime
            }
            $startTimeStr = $activeBlock.startTime

            if ($resetTimeStr -and $startTimeStr) {
                $startSec = ConvertTo-Epoch $startTimeStr
                $endSec = ConvertTo-Epoch $resetTimeStr
                $nowSec = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

                $total = $endSec - $startSec
                if ($total -lt 1) { $total = 1 }

                $elapsed = $nowSec - $startSec
                if ($elapsed -lt 0) { $elapsed = 0 }
                if ($elapsed -gt $total) { $elapsed = $total }

                $sessionPercent = [Math]::Floor($elapsed * 100 / $total)
                $remaining = $endSec - $nowSec
                if ($remaining -lt 0) { $remaining = 0 }

                $rh = [Math]::Floor($remaining / 3600)
                $rm = [Math]::Floor(($remaining % 3600) / 60)
                $endHM = Format-TimeHM $endSec

                $sessionText = "${rh}h ${rm}m until reset at ${endHM}"
            }
        }
    }
# Directory
$output += "📁 ${DirColor}${currentDir}${Reset}"

# Git branch
if ($gitBranch) {
    $output += "  🌿 ${GitColor}${gitBranch}${Reset}"
}

# Model
$output += "  🤖 ${ModelColor}${modelName}${Reset}"

# Model version
if ($modelVersion) {
    $output += "  🏷️ ${VersionColor}${modelVersion}${Reset}"
}

# Session time
if ($sessionText) {
    $sessionColorCode = Get-SessionColor $sessionPercent
    $output += "  ⌛ ${sessionColorCode}${sessionText}${Reset}"
}

# Cost
if ($costUSD -and $costUSD -match '^\d+(\.\d+)?$') {
    if ($costPerHour -and $costPerHour -match '^\d+(\.\d+)?$') {
        $costUSDFormatted = [string]::Format("{0:F2}", [double]$costUSD)
        $costPerHourFormatted = [string]::Format("{0:F2}", [double]$costPerHour)
        $output += "  💵 ${CostColor}`$$costUSDFormatted (`$$costPerHourFormatted/h)${Reset}"
    }
    else {
        $costUSDFormatted = [string]::Format("{0:F2}", [double]$costUSD)
        $output += "  💵 ${CostColor}`$$costUSDFormatted${Reset}"
    }
}

# Tokens
if ($totalTokens -and $totalTokens -match '^\d+$') {
    $output += "  📊 ${UsageColor}${totalTokens} tok${Reset}"
}

Write-Host $output
