#!/usr/bin/env node

/**
 * scout-block.js - Cross-platform hook dispatcher
 *
 * Blocks access to heavy directories: node_modules, __pycache__, .git/, dist/, build/
 *
 * Platform Detection:
 * - Windows (win32): Uses PowerShell via scout-block.ps1
 * - Unix (linux/darwin): Uses Bash via scout-block.sh
 * - WSL: Automatically detects and uses bash implementation
 *
 * Exit Codes:
 * - 0: Command allowed
 * - 2: Command blocked or error occurred
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

try {
  // Read stdin synchronously
  const hookInput = fs.readFileSync(0, 'utf-8');

  // Validate input not empty
  if (!hookInput || hookInput.trim().length === 0) {
    console.error('ERROR: Empty input');
    process.exit(2);
  }

  // Validate JSON structure (basic check)
  try {
    const data = JSON.parse(hookInput);
    if (!data.tool_input || typeof data.tool_input.command !== 'string') {
      console.error('ERROR: Invalid JSON structure');
      process.exit(2);
    }
  } catch (parseError) {
    console.error('ERROR: JSON parse failed:', parseError.message);
    process.exit(2);
  }

  // Determine platform
  const platform = process.platform;
  const scriptDir = __dirname;

  if (platform === 'win32') {
    // Windows: Use PowerShell implementation
    const psScript = path.join(scriptDir, 'scout-block.ps1');

    // Check if PowerShell script exists
    if (!fs.existsSync(psScript)) {
      console.error(`ERROR: PowerShell script not found: ${psScript}`);
      process.exit(2);
    }

    // Execute PowerShell script with stdin piped
    execSync(`powershell -NoProfile -ExecutionPolicy Bypass -File "${psScript}"`, {
      input: hookInput,
      stdio: ['pipe', 'inherit', 'inherit'],
      encoding: 'utf-8'
    });
  } else {
    // Unix (Linux, macOS, WSL): Use bash implementation
    const bashScript = path.join(scriptDir, 'scout-block.sh');

    // Check if bash script exists
    if (!fs.existsSync(bashScript)) {
      console.error(`ERROR: Bash script not found: ${bashScript}`);
      process.exit(2);
    }

    // Execute bash script with stdin piped
    execSync(`bash "${bashScript}"`, {
      input: hookInput,
      stdio: ['pipe', 'inherit', 'inherit'],
      encoding: 'utf-8'
    });
  }
} catch (error) {
  // Log error details for debugging
  if (error.message) {
    console.error('ERROR:', error.message);
  }

  // Exit with error code from child process, or 2 if undefined
  process.exit(error.status || 2);
}
