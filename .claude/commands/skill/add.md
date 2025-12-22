---
description: Add new reference files or scripts to a skill
argument-hint: [skill-name] [reference-or-script-prompt]
---

Think harder.
Use `skill-creator` and `claude-code` skills.
Use `docs-seeker` skills to search for documentation if needed.

## Arguments
$1: skill name (required, default: "")
$2: reference or script prompt (required, default: "")
If $1 or $2 is not provided, ask the user to provide it.

## Your mission
Add new reference files or scripts to a skill at `.claude/skills/$1` directory.

## Requirements
<reference-or-script-prompt>
$2
</reference-or-script-prompt>

## Rules of Skill Creation:
Base on the requirements:
- Always keep in mind that `SKILL.md` and reference files should be token consumption efficient, so that **progressive disclosure** can be leveraged at best.
- If you're given an URL, it's documentation page, use `Explore` subagent to explore every internal link and report back to main agent, don't skip any link.
- If you receive a lot of URLs, use multiple `Explore` subagents to explore them in parallel, then report back to main agent.
- If you receive a lot of files, use multiple `Explore` subagents to explore them in parallel, then report back to main agent.
- If you're given a Github URL, use [`repomix`](https://repomix.com/guide/usage) command to summarize ([install it](https://repomix.com/guide/installation) if needed) and spawn multiple `Explore` subagents to explore it in parallel, then report back to main agent.
