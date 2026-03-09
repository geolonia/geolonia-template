# ADR-0000: Architecture Decision Record Template

**Status**: Template (not a decision itself)
**Date**: YYYY-MM-DD
**Author**: @your-github-handle

---

## Context

> What is the situation or problem that motivated this decision?
> Describe the forces at play: technical, business, organizational.
> Be specific about constraints and requirements.

## Decision

> What was decided?
> State it clearly and concisely.
> Use active voice: "We will use X" rather than "X was chosen".

## Options Considered

### Option A: [Name]

**Pros:**
- ...

**Cons:**
- ...

### Option B: [Name]

**Pros:**
- ...

**Cons:**
- ...

## Rationale

> Why was this option chosen over the alternatives?
> Reference benchmarks, team experience, community support, or other evidence.
> Be honest about trade-offs.

## Consequences

### Positive
- ...

### Negative / Trade-offs
- ...

### Risks
- ...

## Implementation Notes

> Any specific implementation details, migration steps, or gotchas.

## References

- [Link to relevant issue, PR, or external resource]

---

## How to Use This Template

1. Copy this file: `cp 0000-template.md NNNN-short-title.md`
2. Fill in all sections
3. Set Status to `Proposed`
4. Submit as PR for team review
5. After approval, change Status to `Accepted`

### Status Values

| Status | Meaning |
|--------|---------|
| `Proposed` | Under discussion, not yet decided |
| `Accepted` | Team agreed, in effect |
| `Deprecated` | No longer applicable |
| `Superseded by ADR-NNNN` | Replaced by a newer decision |

### Immutability Rule

**ADRs are immutable.** Never edit an accepted ADR.
Instead, create a new ADR that supersedes it and update the old one's status to `Superseded by ADR-NNNN`.

This preserves the decision history and shows how thinking evolved over time.
