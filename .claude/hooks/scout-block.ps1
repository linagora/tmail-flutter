# scout-block.ps1 - PowerShell implementation for blocking heavy directories
# Blocks: node_modules, __pycache__, .git/, dist/, build/

# Read JSON input from stdin
$inputJson = $input | Out-String

# Validate input not empty
if ([string]::IsNullOrWhiteSpace($inputJson)) {
    Write-Error "ERROR: Empty input"
    exit 2
}

# Parse JSON (PowerShell 5.1+ compatible)
try {
    $hookData = $inputJson | ConvertFrom-Json
} catch {
    Write-Error "ERROR: Failed to parse JSON input"
    exit 2
}

# Validate JSON structure
if (-not $hookData.tool_input) {
    Write-Error "ERROR: Invalid JSON structure - missing tool_input"
    exit 2
}

if (-not $hookData.tool_input.command) {
    Write-Error "ERROR: Invalid JSON structure - missing command"
    exit 2
}

# Extract command from hook input
$command = $hookData.tool_input.command

# Validate command is string
if ($command -isnot [string]) {
    Write-Error "ERROR: Command must be string"
    exit 2
}

# Validate command not empty
if ([string]::IsNullOrWhiteSpace($command)) {
    Write-Error "ERROR: Empty command"
    exit 2
}

# Define blocked patterns (regex)
$blockedPatterns = @(
    'node_modules',
    '__pycache__',
    '\.git/',
    'dist/',
    'build/'
)

# Check if command matches any blocked pattern
foreach ($pattern in $blockedPatterns) {
    if ($command -match $pattern) {
        Write-Error "ERROR: Blocked directory pattern"
        exit 2
    }
}

# Allow command to proceed (exit 0)
exit 0
