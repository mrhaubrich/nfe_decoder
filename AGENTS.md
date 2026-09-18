# Agent guidance — nfe_decoder

## Purpose and map

Small Dart library for supported invoice URL decoding. Current implemented state is
RS. `lib/decoder/` owns requests/orchestration; `lib/scraper/` owns layout extraction;
`lib/models/` owns public transport values; `test/` owns deterministic fixtures/tests.
Read `plan/README.md` before selecting work and `docs/identifier_contract.md` before
identifier changes. Do not claim support absent from ScraperFactory.

## Boundaries and compatibility

The decoder extracts observations and performs pure structural identifier validation.
GPreços resolves identities and owns persistence, migration, aliases and user decisions.
Never infer GTIN from a numeric Item.codigo or checksum alone. Preserve raw strings,
leading zeros, field roles, missing-versus-empty/SEM GTIN and parser provenance.
Keep legacy constructors/map fields compatible under the approved contract. Unknown
metadata stays preserved and non-actionable. Public contract/version changes require
architect review and explicit compatibility tests. Do not add app database/UI logic,
provider enrichment or unauthenticated XML assumptions.

## Privacy and source evidence

Use synthetic fixtures. Never expose QR URLs, access keys, consumer names, CPF/CNPJ or
raw fiscal payloads in new fixtures/logs. Permission-restrict temporary sensitive
captures and remove them after aggregate analysis. Request policy must validate exact
supported HTTPS endpoints and redirects with bounded response/time. No authentication
bypass or live-network-dependent unit tests. Preserve unrelated working-tree changes.

## Commands

```sh
mise exec -- dart format --output=none --set-exit-if-changed lib test
mise exec -- dart analyze
mise exec -- dart test
mise exec -- dart pub publish --dry-run
git diff --check
```

Record actual SDK version; mise currently selects latest. A dry run is not publishing.
Do not change dependency constraints or generate unrelated files to silence failures.
Follow existing Dart naming/lints; document new public APIs. Do not hand-edit generated
output if introduced later; document its generator before adopting it.

## Planning, roles and handoff

Use 🔲 planned, 🟢 ready, 🔄 in progress, 🧪 validation-required, ⛔ blocked, ✅ complete,
🔒 locked. Priority is MUST/SHOULD/COULD/WON'T-YET/LOCKED; it is not execution order.
Choose the highest-RICE dependency-ready task in the active workstream. Mark 🔄 before
implementation. Tests, review and task-specific evidence are required before ✅.
Locks require concrete Lock reason and observable Unlock condition. Never invent
historical evidence or unlock app S11.9 through decoder completion.

Roles are responsibilities, not a required parallel agent hierarchy: planner scopes
and scores; architect reviews contracts/compatibility; implementer owns one bounded
task; reviewer checks actual diff; validator records real evidence; plan-maintainer
updates status/risks/traceability only from evidence. Security review is required for
request/privacy boundaries. Keep these roles in this file rather than duplicating a
large agent/skill tree. Handoff: planner/architect -> implementer -> reviewer ->
validator -> plan-maintainer. Return to planning for material scope/contract changes.

Approval on 2026-09-18 covers planning documents. Source implementation, package
publication and device modifications are not authorized by that documentation approval.
