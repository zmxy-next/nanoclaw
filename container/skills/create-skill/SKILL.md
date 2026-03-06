---
name: create-skill
description: Create a new permanent NanoClaw skill from learnings, research, or repeated workflows. Use when you've learned something reusable, completed deep research, discovered a useful pattern, or want to turn knowledge into executable skill. Triggers on "create skill", "make a skill", "skill-ify", "turn this into a skill", or after completing research sessions.
allowed-tools: Bash(ls:*), Bash(mkdir:*), Bash(cp:*)
---

# Create New Skill — Self-Improvement Engine

This skill guides the creation of new permanent NanoClaw skills. Skills are executable knowledge — they make the agent permanently better at specific tasks.

## When to Create a Skill

Create a skill when you:
- Completed deep research on a topic (e.g., UI design -> `/ui-review`)
- Notice a repeated workflow you do often (e.g., always reviewing code the same way)
- Discover a useful tool, technique, or pattern
- Learn something from Simon that's reusable
- Find yourself giving the same type of advice repeatedly

Rule of thumb: If you'd explain the same thing twice, make it a skill.

## Skill Locations

### Container Skills (Portable — Preferred)
`/workspace/nanoclaw/container-skills/<name>/SKILL.md`
- Ships with every deployment
- Available to ALL agents on ANY server
- Synced to `/home/node/.claude/skills/` at container startup
- Use this when the mount is available

### Session Skills (Fallback)
`/home/node/.claude/skills/<name>/SKILL.md`
- Persists via session mount
- Available to all agents on THIS server
- Lost on fresh deploy to new server
- Use this when container-skills mount is not available

### Project Skills (Repo-Specific)
`<repo>/.claude/skills/<name>/SKILL.md`
- Only available when working inside that specific repo
- Use for project-specific patterns only

## How to Create a Skill

### Step 1: Define the Skill Scope
Answer these questions:
- What task does this skill help with? (Be specific)
- What trigger phrases should activate it? (List 3-5)
- What tools does the skill need? (Read, Write, Edit, Bash, Glob, Grep, WebFetch, etc.)
- Is it general (container) or project-specific?

### Step 2: Write the SKILL.md
Every skill has YAML frontmatter + markdown body:

```yaml
name: skill-name-in-kebab-case
description: 1-2 sentences explaining what the skill does. Include specific trigger phrases.
allowed-tools: Bash(specific-cmd:*)
```

Frontmatter fields:
- **name** — kebab-case, unique, descriptive
- **description** — CRITICAL. This is the trigger matcher. Include what it does, when to use, trigger phrases
- **allowed-tools** — (optional) specific Bash commands the skill needs

### Step 3: Write the Skill Body
Structure: Overview -> When to Use -> Workflow (steps) -> Patterns & Templates -> Anti-Patterns -> Examples

Writing tips:
- Be specific and actionable — not vague advice
- Include checklists the AI can follow mechanically
- Add examples with concrete inputs/outputs
- Define output format so results are consistent
- List anti-patterns to prevent common mistakes
- Keep it focused — one skill, one job

### Step 4: Save the Skill
Check if container-skills mount exists (preferred), otherwise use session skills fallback.

### Step 5: Verify
- Check it appears in the available skills list
- Test it — does the description match the intended triggers?
- Is the guide clear enough that any agent could follow it?

## Quality Checklist
- [ ] Name is kebab-case and descriptive
- [ ] Description includes specific trigger phrases (3-5)
- [ ] Scope is focused — does ONE thing well
- [ ] Steps are concrete and actionable
- [ ] Output format is defined
- [ ] Examples are included
- [ ] Anti-patterns are listed
- [ ] Standalone — any agent can use without prior context
- [ ] No secrets — no API keys, tokens, or credentials

## Skill Ideas Pipeline

| Signal | Potential Skill |
|--------|----------------|
| Researched a topic deeply | `<topic>-guide` |
| Reviewed code multiple times | `<language>-review` |
| Set up the same thing twice | `<tool>-setup` |
| Explained a concept to Simon | `<concept>-explain` |
| Found a useful technique | `<technique>-howto` |
| Made a mistake and learned | `<area>-gotchas` |

## Remember
- Skills compound — each one makes you permanently better
- Quality over quantity — a well-crafted skill beats ten shallow ones
- Update skills when you learn more — skills should evolve
- Delete skills that aren't useful — prune dead weight
