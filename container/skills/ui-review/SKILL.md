---
name: ui-review
description: Review UI components, pages, or designs against modern UX/UI best practices (2024-2026). Use when reviewing frontend code, designing new components, checking accessibility, or auditing a user interface. Triggers on "review UI", "check design", "UX audit", "accessibility check", "is this good UX", or when working on frontend components.
tools: Read, Glob, Grep, Bash, WebFetch
---

# UI/UX Design Review

Review any UI component, page, or design against modern best practices. This skill applies knowledge of current design trends, UX laws, component patterns, and accessibility requirements.

## When to Use
- Reviewing a Vue/React component's template/JSX
- Auditing a page layout for UX issues
- Checking accessibility compliance
- Evaluating design decisions against best practices
- Suggesting improvements to existing UI

## Review Framework

### Phase 1: Understand Context
Read the component/page code. Identify:
- **Framework**: Vue, React, Svelte, etc.
- **Component type**: Navigation, form, data display, feedback, layout
- **UI library**: shadcn/ui, Radix, Ant Design, custom, Tailwind
- **Current state**: New component, refactor, or bug fix

### Phase 2: Apply Design Review Checklist
Score each area (Pass / Needs Work / Fail):

#### Visual Design
- **Visual hierarchy**: Is importance communicated through size, weight, color, position?
- **Spacing consistency**: Does it follow a spacing scale (4px/8px grid)?
- **Color usage**: Restrained palette? Semantic colors (not arbitrary)?
- **Typography**: Proper scale? Max 2 font families? Clear hierarchy?
- **Dark mode**: Works in both themes? Uses CSS variables/tokens?

#### UX Principles
- **Progressive disclosure**: Shows only what's needed?
- **Cognitive load**: Max 7+/-2 items in groups?
- **Fitts's Law**: Primary actions large enough?
- **Hick's Law**: Too many choices?
- **Jakob's Law**: Follows familiar patterns?
- **Doherty Threshold**: Loading states for anything >400ms?
- **Feedback**: User gets clear feedback for every action?

#### Component Patterns
- Correct pattern for the job?
- Loading state with skeleton/spinner?
- Empty state with guidance + CTA?
- Error state with what/why/how-to-fix?
- Responsive on mobile?

#### Accessibility (WCAG 2.2 AA)
- Contrast meets 4.5:1 ratio?
- All interactive elements keyboard navigable?
- Visible focus rings?
- ARIA labels on icon-only buttons?
- Screen reader friendly?
- Respects `prefers-reduced-motion`?
- Color independence?

#### Code Quality
- Semantic HTML?
- Component composition (small, reusable)?
- CSS approach (utility or scoped)?
- Performance (virtualized lists, lazy loading)?

### Phase 3: Output Review
Format as:
```
## UI/UX Review: [Component/Page Name]
**Summary**: [1-2 sentence assessment]
**Score**: [A/B/C/D]
**Findings**: What's Good / Needs Improvement / Critical Issues
**Recommended Changes**: [Prioritized list]
**Quick Wins**: [1-3 easy improvements]
```

## Component-Specific Checks

- **Data Tables**: sort, filter, pagination, responsive card view, bulk actions, URL state
- **Forms**: inline validation, labels on every field, progress indicator, disabled submit during loading
- **Navigation**: active state, max 7-8 items, mobile drawer, Cmd+K search
- **Modals**: focus trap, escape to close, not for long content
- **Toasts**: not for form errors, auto-dismiss, undo for destructive actions, max 3-5 stacked

## Reference

Draws from: Linear, Vercel, Stripe, Notion, Raycast design patterns; shadcn/ui + Tailwind CSS; Nielsen Norman Group UX principles; WCAG 2.2 guidelines.
