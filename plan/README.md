# Adaptive identifier-capture roadmap

Approved 2026-09-18. Active workstream: identifier observations and compatibility.
NID.1–NID.4 are ✅; NID.5 is the next required compatibility/release gate.
Planning approval does not publish packages or modify devices.

## Tree and ownership

- `01_SCORING.md`: complete MoSCoW/RICE matrix, scales and recalculation.
- `02_IDENTIFIER_CAPTURE.md`: stage gates, dependencies and atomic task contracts.
- `../docs/identifier_contract.md`: authoritative decoder wire/source contract.
- `../AGENTS.md`: boundaries, commands and lightweight role handoff.
- This file: decisions, risks, traceability and execution checklist.

GPreços owns app identity/storage in `plan/14_PHASE12_PRODUCT_IDENTITY.md` and
`docs/product_identity_contract.md`. Coordinate by task IDs and tested package artifact;
no absolute local dependency paths. NID.5 precedes GPreços I12.1. NID.6 is not a gate
for current capture. No duplicated agent tree or generic skills are needed.

## Task checklist

| Task | Scope | MoSCoW | RICE | Status | Dependencies |
|---|---|---|---:|---|---|
| NID.1 | Source evidence/fixture contract | MUST | 19.00 | ✅ | Planning approval received |
| NID.2 | Identifier value/validation | MUST | 18.00 | ✅ | NID.1 |
| NID.3 | RS observations | MUST | 27.00 | ✅ | NID.2 |
| NID.4 | Safe request boundary | MUST | 17.00 | ✅ | NID.1 |
| NID.5 | Compatibility/release gate | MUST | 25.50 | 🔲 | NID.2, NID.3, NID.4 |
| NID.6 | Additional XML adapter | WON'T-YET | Unscored | 🔒 | Explicit acquisition approval |

NID.6 Lock reason: no specific XML acquisition or access contract is approved.
Unlock condition: owner approves a user-supplied XML or authorized endpoint flow,
security limits and representative safe fixtures. Public consultation is insufficient.

## Selection, status and release rules

Use RICE only among dependency-ready tasks in this workstream; security, compatibility,
privacy and explicit locks override score. Statuses: 🔲 planned, 🟢 ready, 🔄 in progress,
🧪 validation-required, ⛔ blocked, ✅ complete, 🔒 locked. Mark 🔄 before source edits.
Do not start dependent work before prerequisite evidence. No compilation-only completion.
Recalculate on phase exit, major discovery or approved scope changes and record why.

- [ ] Read source contract, task, scoring, risks and git status.
- [ ] Confirm bounded selection and preserve unrelated changes.
- [ ] Implement only selected scope; synthetic focused tests.
- [ ] Review real diff and fix findings.
- [ ] Run task commands and full release gates where required.
- [ ] Record exact evidence/failures; update status and cross-repository handoff.

Release gates: D-ALL commands in the phase file; old/new constructors and maps; raw
value/role preservation; injected HTTP/security tests; documented RS support; identified
artifact/commit. Publication remains a separate action. Runtime/live source claims
need actual evidence. No provider or additional XML integration is required for exit.

## Decisions

| ID | Approved decision (2026-09-18) | Rationale / rejected alternative |
|---|---|---|
| ND-001 | Small capture roadmap coordinated with I12 | Contract/version ownership adds value; reject copied agent bureaucracy |
| ND-002 | Optional observation contract v1, proposed 0.3.0 | Preserve legacy Item/maps; reject code-as-GTIN and app resolution in library |
| ND-003 | Pure validator plus explicit source provenance | Checksum is structural, not assignment proof; raw evidence survives |
| ND-004 | Bounded verified HTTPS requests and synthetic tests | Prevent fiscal leaks/unsafe redirects; do not assume current substring validation is safe |
| ND-005 | XML adapter remains locked | Public consultation does not prove an approved downloadable source |

## Risks

| Risk | Likelihood | Impact | Mitigation | Owner | Tasks | Trigger | Status |
|---|---|---|---|---|---|---|---|
| Numeric retailer code becomes false GTIN | High | High | Explicit role/classification; negative tests | architect | NID.1–3 | Accepted GTIN without source evidence | Open |
| Layout silently changes | Medium | High | Capabilities/selector fixtures; unknown states | implementer | NID.1/3 | Missing or shifted field | Open |
| Legacy consumer breaks or drops metadata | Medium | High | Constructor/map fixtures and app handoff | architect | NID.2/5 | Old caller fails or adapter loses fields | Open |
| Fiscal data escapes through HTTP/errors | Medium | Critical | Exact endpoints, redirect bounds, redaction; synthetic tests pass, but live DNS/socket behavior remains unexercised | security reviewer | NID.4/5 | Raw URL/body logged or unsafe target requested | Open |
| XML scope expands into unsupported access | Medium | High | Explicit lock and acquisition review | planner | NID.6 | Assumed public XML or credential requirement | Locked |

## Traceability and evidence

| Goal | Tasks | Code area | Evidence |
|---|---|---|---|
| Correct source semantics | NID.1/3 | RS fields/fixtures | Selector map, safe fixtures, field parity |
| Reusable identifier observations | NID.2/3 | models and pure validator | Golden maps and GTIN negative matrix |
| Safe capture | NID.4 | decoder HTTP/URL | Injected request/redirect/redaction tests |
| App compatibility | NID.5 -> I12.1 | public exports/package/maps | Released or approved artifact/commit; app adapter fixture |
| Optional XML | NID.6 | Future approved adapter | No completion evidence; locked |

Evidence ledger (2026-09-29): NID.4 implementation and final security review are complete; final review reports no remaining P1/P2 findings. Validation used Dart 3.12.1: formatting passed for 41 files, focused tests passed (15), full suite passed (89), `git diff --check` passed, and `dart analyze` exited 0 with one existing informational lint. The analyzer also printed an optional analyzer-plugin setup conflict between `analysis_server_plugin` and `saropa_lints`; this did not fail the analyzer command. `dart pub publish --dry-run` exited 65 on the pre-existing plural `docs/` layout warning; this compatibility/release check belongs to NID.5 and does not block NID.4. Synthetic tests do not prove real network DNS/socket behavior, which was not exercised; no runtime-network claim is made. Package publication and live-source validation have not occurred.
