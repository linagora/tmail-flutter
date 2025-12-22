---
description: ⚡⚡⚡⚡ Research & create an implementation plan with 2 approaches
argument-hint: [task]
---

Think harder.
Activate `planning` skill.

## Your mission
Use the `planner` subagent to create 2 detailed implementation plans for this following task:
<task>
 $ARGUMENTS
</task>

## Workflow
1. First: Create a directory named `plans/YYYYMMDD-HHmm-plan-name` (eg. `plans/20251101-1505-authentication-and-profile-implementation`).
   Make sure you pass the directory path to every subagent during the process.
2. Follow strictly to the "Plan Creation & Organization" rules of `planning` skill.
3. Use multiple `researcher` agents in parallel to research for this task, each agent research for a different aspect of the task and perform max 5 researches (max 5 tool calls).
4. Use `scout` agent to search the codebase for files needed to complete the task.
5. Main agent gathers all research and scout report filepaths, and pass them to `planner` subagent with the detailed instructions prompt to create an implementation plan of this task.
  **Output:** Provide at least 2 implementation approaches with clear trade-offs, and explain the pros and cons of each approach, and provide a recommended approach.
1. Main agent receives the implementation plan from `planner` subagent, and ask user to review the plan

## Important Notes
**IMPORTANT:** Analyze the skills catalog and activate the skills that are needed for the task during the process.
**IMPORTANT:** Sacrifice grammar for the sake of concision when writing reports.
**IMPORTANT:** Ensure token efficiency while maintaining high quality.
**IMPORTANT:** In reports, list any unresolved questions at the end, if any.
**IMPORTANT**: **Do not** start implementing.