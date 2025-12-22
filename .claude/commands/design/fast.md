---
description: Create a quick design
argument-hint: [tasks]
---

Think hard to plan & start working on these tasks follow the Orchestration Protocol, Core Responsibilities, Subagents Team and Development Rules: 
<tasks>$ARGUMENTS</tasks>

**IMPORTANT**: Activate `aesthetic` and `frontend-design` skills.
**IMPORTANT**: Analyze the list of skills  at `.claude/skills/*` and intelligently activate the skills that are needed for the task during the process.
**Ensure token efficiency while maintaining high quality.**

## Workflow:
2. Use `ui-ux-designer` subagent to start the design process.
3. If user doesn't specify, create the design in pure HTML/CSS/JS.
4. Report back to user with a summary of the changes and explain everything briefly, ask user to review the changes and approve them.
5. If user approves the changes, update the `./docs/design-guidelines.md` docs if needed.

## Notes:
- Remember that you have the capability to generate images, videos, edit images, etc. with `ai-multimodal` skills. Use them to create the design and real assets.
- Always review, analyze and double check generated assets with `ai-multimodal` skills to verify quality.
- Maintain and update `./docs/design-guidelines.md` docs if needed.