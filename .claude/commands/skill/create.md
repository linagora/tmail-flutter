---
description: Create a new agent skill
argument-hint: [prompt-or-llms-or-github-url]
---

Ultrathink.
Use `skill-creator` and `claude-code` skills.
Use `docs-seeker` skills to search for documentation if needed.

## Your mission
Create a new skill in `.claude/skills/` directory.

## Requirements
<user-prompt>$ARGUMENTS</user-prompt>

## Rules of Skill Creation:
Base on the requirements:
- Always keep in mind that `SKILL.md` and reference files should be token consumption efficient, so that **progressive disclosure** can be leveraged at best.
- If you're given an URL, it's documentation page, use `Explore` subagent to explore every internal link and report back to main agent, don't skip any link.
- If you receive a lot of URLs, use multiple `Explore` subagents to explore them in parallel, then report back to main agent.
- If you receive a lot of files, use multiple `Explore` subagents to explore them in parallel, then report back to main agent.
- If you're given a Github URL, use [`repomix`](https://repomix.com/guide/usage) command to summarize ([install it](https://repomix.com/guide/installation) if needed) and spawn multiple `Explore` subagents to explore it in parallel, then report back to main agent.
