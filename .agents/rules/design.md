---
description: Visual and interaction constraints. Load before any change that renders to a screen.
globs: ["**/components/**", "**/app/**", "**/pages/**", "**/styles/**", "**/*.css", "**/*.tsx", "**/*.jsx"]
---

# Design

> Load this when the change affects anything a user looks at. The design system is not decoration — it is a spec, and deviating from it silently is the same class of error as ignoring a type.

## Trigger

Load when the change involves any of:

- A new component, page, screen, or view.
- Colors, spacing, typography, border radii, shadows, or motion.
- Layout changes: grid, flex, breakpoints, responsive behavior.
- Empty states, loading states, error states, disabled states.
- Icons, imagery, or illustration.
- Anything you'd describe as "making it look right."

## The first rule

**Find the design source of truth before you write a line of CSS.**

> **TODO when adopting:** name the file. Common locations: `DESIGN.md`, `docs/design-system.md`, `tailwind.config.*`, a Figma link in the README.

If this project has a design file, read it. If it doesn't, the existing components *are* the spec — read three of them before adding a fourth. Do not invent a new visual language mid-codebase.

## Tokens, not values

- [ ] Colors come from the palette. No new hex codes. If you need a color that doesn't exist, that's a design decision — escalate, don't improvise.
- [ ] Spacing comes from the scale. No arbitrary `13px`. If the scale doesn't have what you need, use the nearest value and note it.
- [ ] Type comes from the defined ramp — family, size, weight, line-height. No one-off font sizes.
- [ ] Radii, shadows, and borders come from the defined set.
- [ ] Motion uses the defined durations and easings.

A magic number in a stylesheet is a bug report from the future.

## Semantic color

Color carries meaning. Using an accent decoratively destroys its ability to signal.

- [ ] Is the accent color reserved for a specific job (primary action, active state, critical value)? Then use it only for that job.
- [ ] Destructive actions look destructive. Non-destructive actions do not.
- [ ] Disabled states are visibly disabled without relying on color alone.
- [ ] Information is never conveyed by color alone — pair it with text, icon, weight, or position.

## Every state, not just the happy one

A component is not done when it renders with good data. Check:

- [ ] **Empty** — no data yet. Does it explain what goes here and how to get it?
- [ ] **Loading** — is there a skeleton or spinner, and does the layout hold its shape so nothing jumps?
- [ ] **Error** — does it say what went wrong and what to do next?
- [ ] **Partial** — some data, some missing.
- [ ] **Overflow** — the longest realistic string. A 60-character name. A 12-digit number.
- [ ] **Interactive states** — hover, focus, active, disabled. Focus especially: keyboard users need a visible ring.

## Responsive and environment

- [ ] Works at the smallest supported width without horizontal scroll.
- [ ] Touch targets are at least 44×44px on touch devices.
- [ ] Respects the project's light/dark handling. If dark mode is primary, design there first and check light second.
- [ ] Honors `prefers-reduced-motion` for any non-trivial animation.

> **TODO when adopting:** note any environment this project is actually used in that changes the calculus — direct sunlight, one-handed mobile, a desk with two monitors, a cold garage with gloves on. Design for the real context, not the design review.

## Accessibility floor

Non-negotiable, not a follow-up ticket:

- [ ] Text contrast meets WCAG AA (4.5:1 body, 3:1 large text).
- [ ] Every interactive element is reachable and operable by keyboard.
- [ ] Focus order follows visual order.
- [ ] Images have alt text; decorative images have empty alt.
- [ ] Form inputs have associated labels — placeholder is not a label.
- [ ] Semantic HTML before ARIA. A `<button>` beats a `<div role="button">` every time.

## Smells

- A hex code that appears in exactly one file.
- Two components that do the same thing and look slightly different.
- Spacing that reads as "eyeballed" — 15px next to 16px next to 14px.
- A new component that duplicates one that already exists with a different name.
- Inline styles in a codebase that uses a styling system.
- `!important`.
- A layout that only works at the one width you tested.
- Animation that fires on every render.

## When the design system doesn't cover it

Say so explicitly, then pick the option most consistent with what already exists, and flag it in the PR:

> "The design system has no pattern for a multi-select filter. I followed the single-select dropdown's spacing and border treatment. Worth a real decision before this pattern spreads."

Do not silently invent. Invented patterns become permanent by accident.
