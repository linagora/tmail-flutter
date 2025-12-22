# Claude Code Notification Hooks

This directory contains notification hooks for Claude Code sessions. These hooks send real-time notifications to Discord and Telegram when Claude completes tasks.

## Overview

Claude Code hooks automate notifications and actions at specific points in your development workflow. This project includes notification systems for Discord and Telegram:

| Hook | File | Type | Description |
|------|------|------|-------------|
| **Scout Block** | `scout-block.js` | Automated | Cross-platform hook blocking heavy directories (node_modules, .git, etc.) |
| **Modularization** | `modularization-hook.js` | Automated | Non-blocking suggestions for files >200 LOC to encourage code modularization |
| **Discord (Auto)** | `discord_notify.sh` | Automated | Auto-sends rich embeds on session/subagent completion |
| **Discord (Manual)** | `send-discord.sh` | Manual | Sends custom messages to Discord channel |
| **Telegram** | `telegram_notify.sh` | Automated | Auto-sends detailed notifications on session/subagent completion |

### Cross-Platform Support

**Scout Block Hook** now supports both Windows and Unix systems:
- **Windows**: Uses PowerShell (`scout-block.ps1`)
- **Linux/macOS/WSL**: Uses Bash (`scout-block.sh`)
- **Automatic detection**: `scout-block.js` dispatcher selects the correct implementation

No manual configuration needed - the Node.js dispatcher handles platform detection automatically.

## Quick Start

### Current Setup
Check **[SETUP-SUMMARY.md](./SETUP-SUMMARY.md)** for current configuration and quick reference.

### Scout Block Hook (Cross-Platform)
Automatically blocks Claude Code from accessing heavy directories to improve performance.

**Configuration:** Already enabled in `.claude/settings.json`

**Blocked Patterns:**
- `node_modules/` - NPM dependencies
- `__pycache__/` - Python cache
- `.git/` - Git internal files
- `dist/` - Distribution builds
- `build/` - Build artifacts

**Testing:**
```bash
# Linux/macOS/WSL
bash tests/test-scout-block.sh

# Windows PowerShell
pwsh tests/test-scout-block.ps1
```

**Requirements:**
- Node.js >=18.0.0 (already required by project)

### Modularization Hook (Automated)
Automatically analyzes files after Write/Edit operations and suggests modularization for large files.

**Configuration:** Already enabled in `.claude/settings.json`

**Behavior:**
- Triggers on Write/Edit tool usage
- Analyzes file line count (LOC)
- Suggests modularization if >200 LOC
- **Non-blocking**: Claude continues main task automatically
- Provides context-aware guidance using `additionalContext`

**Testing:**
```bash
# Create test file with 205 lines
for i in {1..205}; do echo "console.log('Line $i');"; done > /tmp/test-large.js

# Test hook (should output modularization suggestion)
echo '{"tool_input":{"file_path":"/tmp/test-large.js"}}' | node .claude/hooks/modularization-hook.js

# Test with small file (should be silent)
echo "console.log('test');" > /tmp/test-small.js
echo '{"tool_input":{"file_path":"/tmp/test-small.js"}}' | node .claude/hooks/modularization-hook.js
```

**Requirements:**
- Node.js >=18.0.0 (already required by project)

**How It Works:**
1. Hook receives file path from Write/Edit tool
2. Counts lines in modified file
3. If >200 LOC, injects suggestion into Claude's context
4. Claude receives guidance but continues without blocking
5. Exit code 0 ensures non-blocking behavior

### Discord Hook (Automated)
Automatic notifications on Claude Code session events with rich embeds.

**Setup:** [discord-hook-setup.md](./discord-hook-setup.md)

**Quick Test:**
```bash
echo '{"hookType":"Stop","projectDir":"'$(pwd)'","sessionId":"test","toolsUsed":[{"tool":"Read","parameters":{"file_path":"test.ts"}}]}' | ./.claude/hooks/discord_notify.sh
```

### Discord Hook (Manual)
Send custom notifications to Discord with your own messages.

**Quick Test:**
```bash
./.claude/hooks/send-discord.sh 'Test notification'
```

### Telegram Hook
Automatic notifications on Claude Code session events.

**Setup:** [telegram-hook-setup.md](./telegram-hook-setup.md)

**Quick Test:**
```bash
echo '{"hookType":"Stop","projectDir":"'$(pwd)'","sessionId":"test","toolsUsed":[]}' | ./.claude/hooks/telegram_notify.sh
```

## Documentation

### Quick Reference
- **[Setup Summary](./SETUP-SUMMARY.md)** - Current configuration, testing, and troubleshooting

### Detailed Setup Guides

- **[Discord Hook Setup](./discord-hook-setup.md)** - Complete Discord webhook configuration
- **[Telegram Hook Setup](./telegram-hook-setup.md)** - Complete Telegram bot configuration

### What's Included in Each Guide

**Discord Hook Guide:**
- Discord webhook creation
- Environment configuration
- Manual & automated usage
- Message formatting
- Troubleshooting
- Advanced customization

**Telegram Hook Guide:**
- Telegram bot creation
- Chat ID retrieval
- Global vs project config
- Hook event configuration
- Testing procedures
- Security best practices

## Features Comparison

| Feature | Discord (Auto) | Discord (Manual) | Telegram |
|---------|----------------|------------------|----------|
| **Trigger Type** | Automatic on events | Manual invocation | Automatic on events |
| **Message Style** | Rich embeds | Rich embeds | Markdown formatted |
| **Setup Complexity** | Simple (webhook only) | Simple (webhook only) | Medium (bot + chat ID) |
| **Use Case** | Session monitoring | Custom messages | Session monitoring |
| **Events** | Stop, SubagentStop | On-demand | Stop, SubagentStop |
| **Tool Tracking** | Yes | No | Yes |
| **File Tracking** | Yes | No | Yes |

## Scripts

### modularization-hook.js
PostToolUse hook for automated code modularization suggestions.

**Triggers:**
- `Write` - File creation
- `Edit` - File modification

**Required:** None (standalone Node.js script)

**Features:**
- LOC (Lines of Code) analysis
- Non-blocking execution (exit code 0)
- Context injection via `additionalContext`
- Kebab-case naming guidance
- Automatic continuation after suggestion

### discord_notify.sh
Automated Discord notification hook for Claude Code events with rich embeds.

**Triggers:**
- `Stop` - Main session completion
- `SubagentStop` - Subagent task completion

**Required:** `DISCORD_WEBHOOK_URL` environment variable

**Features:**
- Rich embeds with session details
- Tool usage statistics (with counts)
- File modification tracking
- Session ID and timestamps
- Color-coded by event type

### send-discord.sh
Manual Discord notification script with rich embed formatting.

**Usage:**
```bash
./.claude/hooks/send-discord.sh 'Your message here'
```

**Required:** `DISCORD_WEBHOOK_URL` environment variable

### telegram_notify.sh
Automated Telegram notification hook for Claude Code events.

**Triggers:**
- `Stop` - Main session completion
- `SubagentStop` - Subagent task completion

**Required:** `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` environment variables

## Configuration

### Environment Variables

Environment variables are loaded with the following priority (highest to lowest):
1. **process.env** - System/shell environment variables
2. **.claude/.env** - Project-level Claude configuration
3. **.claude/hooks/.env** - Hook-specific configuration

Create environment files based on your needs:

**Project Root `.env`** (recommended for general use):
```bash
# Discord
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN

# Telegram
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_CHAT_ID=987654321
```

**OR `.claude/.env`** (for project-specific overrides):
```bash
# Same variables as above
```

**OR `.claude/hooks/.env`** (for hook-only configuration):
```bash
# Same variables as above
```

See `.env.example` files in each location for templates.

### Claude Code Hooks Config

Hooks are configured in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/telegram_notify.sh"
      }]
    }],
    "SubagentStop": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/telegram_notify.sh"
      }]
    }]
  }
}
```

## Security

**⚠️ Important Security Practices:**

1. **Never commit tokens/webhooks:**
   ```bash
   # Add to .gitignore
   .env
   .env.*
   ```

2. **Use environment variables** - Never hardcode credentials

3. **Rotate tokens regularly** - Regenerate periodically

4. **Limit permissions** - Minimum required access only

5. **Monitor usage** - Check for unauthorized activity

See individual setup guides for detailed security recommendations.

## Troubleshooting

### Scout Block Hook

**"Node.js not found"**
- Install Node.js >=18.0.0 from [nodejs.org](https://nodejs.org)
- Verify installation: `node --version`

**Hook not blocking directories**
- Verify `.claude/settings.json` uses `node .claude/hooks/scout-block.js`
- Test manually: `echo '{"tool_input":{"command":"ls node_modules"}}' | node .claude/hooks/scout-block.js`
- Should exit with code 2 and error message

**Windows PowerShell execution policy errors**
- Run: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
- Or use bypass flag (already included in dispatcher)

**Testing the hook**
- Linux/macOS/WSL: `bash tests/test-scout-block.sh`
- Windows: `pwsh tests/test-scout-block.ps1`

### Notification Hooks

**"Environment variable not set"**
- Verify `.env` file exists and is properly formatted
- Reload shell after updating profile files (`source ~/.bashrc`)

**"jq: command not found"** (Legacy - no longer needed)
- All hooks now use Node.js for JSON parsing
- No jq dependency required

**No messages received**
- Verify tokens/webhooks are valid
- Check network connectivity
- Ensure proper permissions

### Getting Help

- Check individual setup guides for detailed troubleshooting
- Review [Claude Code Documentation](https://docs.claude.com/claude-code)
- Report issues at [Claude Code GitHub](https://github.com/anthropics/claude-code/issues)

## Additional Resources

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Code Hooks Reference](https://docs.claude.com/claude-code/hooks)
- [Discord Webhooks Guide](https://discord.com/developers/docs/resources/webhook)
- [Telegram Bot API](https://core.telegram.org/bots/api)

---

**Last Updated:** 2025-11-04
