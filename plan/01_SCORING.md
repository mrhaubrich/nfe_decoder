# Identifier workstream scoring

Approved 2026-09-18. RICE = Reach × Impact × Confidence / Effort.
Reach: 1–5 (isolated path to most users); Impact: .25–3 (convenience to data-loss/
security/release stop); Confidence: .5–1; Effort: person-weeks including review and
validation. These match GPreços for dependency coordination, not delivery promises.
Priority, dependency order, status and evidence are distinct. Highest-score ready task
wins within the active workstream; hard compatibility/security gates always override.

| ID | MoSCoW | Reach | Impact | Confidence | Effort (person-weeks) | RICE | Status | Dependencies |
|---|---|---:|---:|---:|---:|---:|---|---|
| NID.1 | MUST | 5 | 2 | 0.95 | 0.5 | 19.00 | ✅ | Planning approval (received 2026-09-18) |
| NID.2 | MUST | 5 | 3 | 0.9 | 0.75 | 18.00 | ✅ | NID.1 |
| NID.3 | MUST | 5 | 3 | 0.9 | 0.5 | 27.00 | ✅ | NID.2 |
| NID.4 | MUST | 5 | 3 | 0.85 | 0.75 | 17.00 | ✅ | NID.1 |
| NID.5 | MUST | 5 | 3 | 0.85 | 0.5 | 25.50 | 🧪 | NID.2, NID.3, NID.4 |
| NID.6 | WON'T-YET | — | — | — | — | Unscored | 🔒 | Explicit acquisition/source approval |

NID.1 is first because evidence bounds all later contracts. When it finishes NID.2
precedes NID.4 by score, unless a recorded dependency discovery requires a change.
NID.3 follows NID.2; NID.5 is mandatory despite any ranking. All current tasks reach
most decoder users; evidence work has impact 2 while identity/security/compatibility
have impact 3. Confidence reflects inspected contracts and implementation uncertainty.
Recalculate after phase exits, major evidence or approved scope changes; record the
reason in README decisions. Locked work is excluded; do not assign speculative scores.
Validation tasks get their own scores and require actual evidence.
