#!/usr/bin/env node

/**
 * Modularization Hook - PostToolUse Command Hook
 *
 * Analyzes files modified via Write/Edit tools and suggests modularization
 * for files exceeding 200 lines of code. Non-blocking implementation.
 *
 * Exit Codes:
 *   0 - Success (non-blocking, allows continuation)
 *   1 - Error (logs but doesn't block)
 */

const fs = require('fs');
const path = require('path');

// Constants
const LOC_THRESHOLD = 200;
const DEBUG = process.env.MODULARIZATION_HOOK_DEBUG === 'true';

/**
 * Conditionally log diagnostic information to stderr without breaking JSON stdout parsing.
 * Keeping logs opt-in avoids noisy transcripts while still letting us validate hook flow.
 */
function debugLog(message) {
  if (DEBUG) {
    console.error(`[modularization-hook] ${message}`);
  }
}

/**
 * Main hook execution
 */
async function main() {
  try {
    // Read hook payload from stdin
    const stdin = fs.readFileSync(0, 'utf-8').trim();

    if (!stdin) {
      // No input, skip silently
      process.exit(0);
    }

    const payload = JSON.parse(stdin);
    debugLog(`Hook triggered for tool: ${payload.tool_name ?? 'unknown'}`);

    // Extract file path from tool input
    const filePath = payload.tool_input?.file_path;

    if (!filePath) {
      debugLog('No file path in payload; skipping.');
      // No file path in payload, skip
      process.exit(0);
    }

    // Check if file exists and is readable
    if (!fs.existsSync(filePath)) {
      debugLog(`File not found at path: ${filePath}`);
      process.exit(0);
    }

    // Read file and count lines
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const lines = fileContent.split('\n').length;
    debugLog(`File ${filePath} has ${lines} LOC.`);

    // Check if modularization suggestion is warranted
    if (lines > LOC_THRESHOLD) {
      const fileName = path.basename(filePath);
      const relativePath = path.relative(process.cwd(), filePath);
      debugLog(`LOC threshold exceeded for ${relativePath}.`);

      // Output non-blocking context injection
      const output = {
        continue: true,
        hookSpecificOutput: {
          hookEventName: "PostToolUse",
          additionalContext: [
            `📊 File ${relativePath} has ${lines} LOC (threshold: ${LOC_THRESHOLD}).`,
            `Consider modularization:`,
            `- Analyze logical separation boundaries (functions, classes, concerns)`,
            `- Use kebab-case naming with descriptive names (e.g., user-authentication-service.ts, data-validation-helpers.ts)`,
            `- Ensure file names are self-documenting for LLM tools (Grep, Glob)`,
            `- After modularization, continue with main task`
          ].join('\n')
        }
      };

      console.log(JSON.stringify(output));
    }

    // Always exit with 0 (non-blocking)
    process.exit(0);

  } catch (error) {
    // Log error but don't block execution
    console.error(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: `Modularization hook error: ${error.message}`
      }
    }));

    process.exit(0); // Still non-blocking even on error
  }
}

main();
