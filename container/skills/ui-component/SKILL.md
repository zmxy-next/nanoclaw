---
name: ui-component
description: Generate modern UI components following best practices. Creates accessible, responsive components using shadcn/ui patterns with Tailwind CSS. Use when building new components, pages, or layouts. Triggers on "create component", "build UI", "new page", "design component", "make a form", "add a table", "build dashboard".
tools: Read, Write, Edit, Glob, Grep, Bash
---

# UI Component Generator

Generate production-ready UI components following modern best practices (2024-2026 patterns).

## Principles

Every generated component MUST:
- **Be accessible** — WCAG 2.2 AA, keyboard navigable, screen reader friendly
- **Be responsive** — Mobile-first, works at all breakpoints
- **Support dark mode** — Via CSS variables/tokens, never hardcoded colors
- **Have loading states** — Skeleton placeholders for async data
- **Have error states** — Graceful failure with actionable message
- **Have empty states** — Guidance + CTA when no data
- **Follow composition** — Small, reusable pieces composed together

## Workflow

### Step 1: Understand Requirements
- What type of component? (navigation, form, data display, layout, feedback)
- What framework? (Vue 3, React, etc.) — check existing codebase
- What UI library? (shadcn/ui, custom, etc.) — check existing dependencies
- What data does it display/collect?
- What interactions does it need?

### Step 2: Check Existing Patterns
Match the project's existing patterns. Don't introduce new libraries without asking.

### Step 3: Generate Component

#### Data Table
- TanStack Table, sort/filter/pagination/row selection
- Mobile: card view, Loading: skeleton rows, Empty: illustration + CTA
- Persist state in URL params, Virtual scroll if >100 rows

#### Form
- Zod + react-hook-form / vee-validate
- Inline validation on blur, Labels on every field
- Error messages with `aria-describedby`
- Multi-step: progress indicator, validate per step
- Submit: loading state, disabled during submission

#### Dashboard Layout
- Sidebar + header + main content
- F-pattern: most important KPI top-left
- Widget grid, global date range filter
- Responsive: sidebar collapses to drawer on mobile

#### Command Palette (Cmd+K)
- Fuzzy search, recent items, keyboard shortcuts, categories
- Use shadcn Command component pattern (cmdk)

#### Card Grid
- CSS Grid responsive columns, consistent heights
- Hover: subtle elevation, Skeleton matching card shape
- Click target: entire card

#### Modal / Dialog
- Focus trap, Escape to close, Click overlay to close
- Return focus to trigger on close
- For confirmations only — long content use Drawer/Sheet

#### Toast / Notification
- Top-right or bottom-right, auto-dismiss 5s
- Undo for destructive actions, max 3-5 visible
- NEVER use for form validation errors

### Step 4: Quality Checklist
- [ ] All interactive elements keyboard accessible
- [ ] Focus indicators visible
- [ ] Color contrast meets 4.5:1
- [ ] No layout shift on load
- [ ] Animations respect `prefers-reduced-motion`
- [ ] Semantic HTML
- [ ] No `any` types in TypeScript
- [ ] Component is composable

## CSS Patterns
- Container queries for reusable components
- Semantic color tokens (`--color-background`, `--color-primary`, etc.)
- Smooth transitions (150ms ease-out)
- Respect `prefers-reduced-motion`

## Anti-Patterns to Avoid
- `div onClick` instead of `button`
- `outline: none` without focus replacement
- Color as only indicator
- Placeholder as label
- Nested modals
- Full-screen modal on desktop
- Toasts for form errors
- Loading spinners without skeleton
- Hardcoded colors
- `!important` overrides
- Inline styles for theming
