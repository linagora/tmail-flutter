#!/usr/bin/env node
'use strict';

/**
 * Custom Claude Code statusline for Node.js
 * Cross-platform support: Windows, macOS, Linux
 * Theme: detailed | Colors: true | Features: directory, git, model, usage, session, tokens
 * No external dependencies - uses only Node.js built-in modules
 */

const { stdin, stdout, env } = require('process');
const { execSync } = require('child_process');
const os = require('os');

// Configuration
const USE_COLOR = !env.NO_COLOR && stdout.isTTY;

// Color helpers
const color = (code) => USE_COLOR ? `\x1b[${code}m` : '';
const reset = () => USE_COLOR ? '\x1b[0m' : '';

// Color definitions
const DirColor = color('1;36');      // cyan
const GitColor = color('1;32');      // green
const ModelColor = color('1;35');    // magenta
const VersionColor = color('1;33');  // yellow
const UsageColor = color('1;35');    // magenta
const CostColor = color('1;36');     // cyan
const Reset = reset();

/**
 * Safe command execution wrapper
 */
function exec(cmd) {
    try {
        return execSync(cmd, {
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'ignore'],
            windowsHide: true
        }).trim();
    } catch (err) {
        return '';
    }
}

/**
 * Convert ISO8601 timestamp to Unix epoch
 */
function toEpoch(timestamp) {
    try {
        const date = new Date(timestamp);
        return Math.floor(date.getTime() / 1000);
    } catch (err) {
        return 0;
    }
}

/**
 * Format epoch timestamp as HH:mm
 */
function formatTimeHM(epoch) {
    try {
        const date = new Date(epoch * 1000);
        const hours = date.getHours().toString().padStart(2, '0');
        const minutes = date.getMinutes().toString().padStart(2, '0');
        return `${hours}:${minutes}`;
    } catch (err) {
        return '00:00';
    }
}

/**
 * Get session color based on remaining percentage
 */
function getSessionColor(sessionPercent) {
    if (!USE_COLOR) return '';

    const remaining = 100 - sessionPercent;
    if (remaining <= 10) {
        return '\x1b[1;31m';  // red
    } else if (remaining <= 25) {
        return '\x1b[1;33m';  // yellow
    } else {
        return '\x1b[1;32m';  // green
    }
}

/**
 * Expand home directory to ~
 */
function expandHome(path) {
    const homeDir = os.homedir();
    if (path.startsWith(homeDir)) {
        return path.replace(homeDir, '~');
    }
    return path;
}

/**
 * Read stdin asynchronously
 */
async function readStdin() {
    return new Promise((resolve, reject) => {
        const chunks = [];
        stdin.setEncoding('utf8');

        stdin.on('data', (chunk) => {
            chunks.push(chunk);
        });

        stdin.on('end', () => {
            resolve(chunks.join(''));
        });

        stdin.on('error', (err) => {
            reject(err);
        });
    });
}

/**
 * Main function
 */
async function main() {
    try {
        // Read and parse JSON input
        const input = await readStdin();
        if (!input.trim()) {
            console.error('No input provided');
            process.exit(1);
        }

        const data = JSON.parse(input);

        // Extract basic information
        let currentDir = 'unknown';
        if (data.workspace?.current_dir) {
            currentDir = data.workspace.current_dir;
        } else if (data.cwd) {
            currentDir = data.cwd;
        }
        currentDir = expandHome(currentDir);

        const modelName = data.model?.display_name || 'Claude';
        const modelVersion = data.model?.version && data.model.version !== 'null' ? data.model.version : '';

        // Git branch detection
        let gitBranch = '';
        const gitCheck = exec('git rev-parse --git-dir');
        if (gitCheck) {
            gitBranch = exec('git branch --show-current');
            if (!gitBranch) {
                gitBranch = exec('git rev-parse --short HEAD');
            }
        }

        // ccusage integration
        let sessionText = '';
        let sessionPercent = 0;
        let costUSD = '';
        let costPerHour = '';
        let totalTokens = '';

        try {
            // Try npx first, then ccusage
            let blocksOutput = exec('npx ccusage@latest blocks --json');
            if (!blocksOutput) {
                blocksOutput = exec('ccusage blocks --json');
            }

            if (blocksOutput) {
                const blocks = JSON.parse(blocksOutput);
                const activeBlock = blocks.blocks?.find(b => b.isActive === true);

                if (activeBlock) {
                    costUSD = activeBlock.costUSD || '';
                    costPerHour = activeBlock.burnRate?.costPerHour || '';
                    totalTokens = activeBlock.totalTokens || '';

                    // Session time calculation
                    const resetTimeStr = activeBlock.usageLimitResetTime || activeBlock.endTime;
                    const startTimeStr = activeBlock.startTime;

                    if (resetTimeStr && startTimeStr) {
                        const startSec = toEpoch(startTimeStr);
                        const endSec = toEpoch(resetTimeStr);
                        const nowSec = Math.floor(Date.now() / 1000);

                        let total = endSec - startSec;
                        if (total < 1) total = 1;

                        let elapsed = nowSec - startSec;
                        if (elapsed < 0) elapsed = 0;
                        if (elapsed > total) elapsed = total;

                        sessionPercent = Math.floor(elapsed * 100 / total);
                        let remaining = endSec - nowSec;
                        if (remaining < 0) remaining = 0;

                        const rh = Math.floor(remaining / 3600);
                        const rm = Math.floor((remaining % 3600) / 60);
                        const endHM = formatTimeHM(endSec);

                        sessionText = `${rh}h ${rm}m until reset at ${endHM}`;
                    }
                }
            }
        } catch (err) {
            // Silent fail - ccusage not available or error
        }

        // Render statusline
        let output = '';

        // Directory
        output += `📁 ${DirColor}${currentDir}${Reset}`;

        // Git branch
        if (gitBranch) {
            output += `  🌿 ${GitColor}${gitBranch}${Reset}`;
        }

        // Model
        output += `  🤖 ${ModelColor}${modelName}${Reset}`;

        // Model version
        if (modelVersion) {
            output += `  🏷️ ${VersionColor}${modelVersion}${Reset}`;
        }

        // Session time
        if (sessionText) {
            const sessionColorCode = getSessionColor(sessionPercent);
            output += `  ⌛ ${sessionColorCode}${sessionText}${Reset}`;
        }

        // Cost
        if (costUSD && /^\d+(\.\d+)?$/.test(costUSD)) {
            const costUSDNum = parseFloat(costUSD);
            if (costPerHour && /^\d+(\.\d+)?$/.test(costPerHour)) {
                const costPerHourNum = parseFloat(costPerHour);
                output += `  💵 ${CostColor}$${costUSDNum.toFixed(2)} ($${costPerHourNum.toFixed(2)}/h)${Reset}`;
            } else {
                output += `  💵 ${CostColor}$${costUSDNum.toFixed(2)}${Reset}`;
            }
        }

        // Tokens
        if (totalTokens && /^\d+$/.test(totalTokens.toString())) {
            output += `  📊 ${UsageColor}${totalTokens} tok${Reset}`;
        }

        console.log(output);
    } catch (err) {
        console.error('Error:', err.message);
        process.exit(1);
    }
}

main().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
