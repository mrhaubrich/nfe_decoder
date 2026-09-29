# Identifier capture and compatibility

Status: 🔄 Active workstream; approved 2026-09-18; NID.1–NID.4 are complete; NID.5 is in validation.
Contract: [identifier contract](../doc/identifier_contract.md).
Coordination: GPreços Phase 12 I12.1 depends on NID.5; NID.6 is not required.

## Adaptive stages

1. Evidence (NID.1): enter after approval; exit with safe source/fixture map.
2. Contract/capture/security (NID.2–4): enter after evidence; exit with validated
   optional observations and bounded supported HTTP behavior.
3. Compatibility (NID.5): enter after focused evidence; exit with reviewed artifact
   and old/new map/constructor compatibility. Publishing needs a separate action.

Scope excludes app identity resolution, databases, provider enrichment and additional
XML access. Preserve raw strings and role/provenance. Never infer GTIN from codigo.
Risks: unsupported layout, numeric false positives, compatibility drift and fiscal
leakage; mitigate with synthetic fixtures and negative tests below.

D-ALL:
```sh
mise exec -- dart format --output=none --set-exit-if-changed lib test
mise exec -- dart analyze
mise exec -- dart test
mise exec -- dart pub publish --dry-run
git diff --check
```
Focused baseline: `mise exec -- dart test test/scraper/rs/fields/rs_item_scraper_test.dart test/scraper/rs/fields/rs_items_scraper_test.dart`.
Add validator/metadata/HTTP/compatibility tests as owned by each task. Record actual
SDK version (mise currently selects latest), exact results and limitations. Do not
confuse package dry run with publication or mocked HTTP with live coverage.

## NID.1 — Source evidence and fixture contract

Status: ✅ | MoSCoW: MUST | RICE: 19.00
Reach: 5 | Impact: 2 | Confidence: 0.95 | Effort: 0.5 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: Planning approval (received 2026-09-18)
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: Field-to-selector and source capability tables; synthetic fixture specification; confirmed versus inferred semantics.

Files or areas: Existing RS scraper/fixtures/tests; doc/identifier_contract.md.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [x] RCod is retailer-code evidence; no HTML GTIN claim without evidence; no real fiscal identifiers in new fixtures.
- [x] Negative cases covered: Missing RCod, valid-looking numeric code, repeated rows and unsupported/malformed layouts.
- [x] Actual diff reviewed; task-specific failures resolved or explicitly retained as blockers.

Validation: Existing RS focused tests and privacy inspection; source citations.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Aggregate fixture inventory, verified selector mapping and privacy-safe fixture specification.
Completion evidence: Added the verified current RS selector/capability map to the
identifier contract and a privacy-safe synthetic matrix covering missing/empty RCod,
numeric-looking retailer codes, repeated rows/order, and unsupported or malformed
layouts. Focused RS tests, the full test suite, analyzer, package dry run and diff
check ran on 2026-09-28. The full formatter gate remains validation-required because
the current SDK reports 13 pre-existing files as reformatted; package dry run reports
the dirty worktree and the existing plural `docs` layout warning. No live fiscal
identifiers or URLs were added. The previously reported formatter limitation was
rechecked on the committed style baseline with Dart 3.12.1; the full formatter gate
now passes.

## NID.2 — Identifier value and validation contract

Status: ✅ | MoSCoW: MUST | RICE: 18.00
Reach: 5 | Impact: 3 | Confidence: 0.9 | Effort: 0.75 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.1
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: Immutable optional observation types, tolerant map parsing, pure reusable GTIN assessment; wire v1.

Files or areas: Proposed lib/models/identifier_observation.dart; lib/identifiers/gtin.dart; model exports/tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [x] Preserve raw value/length, separate roles/statuses, valid padding and explicit unknown states; old Item contract unchanged.
- [x] Negative cases covered: Unicode digits, wrong length/checksum, all-zero, UPC-E ambiguity, checksum-valid retailer code.
- [x] Actual diff reviewed; task-specific failures resolved or explicitly retained as blockers.

Validation: Pure validator/map golden tests; analyzer.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Full identifier matrix and backwards-compatible constructor/map tests.
Completion evidence: Added immutable `IdentifierObservation` map parsing with raw
value preservation, unknown-state and extension retention, malformed-map rejection,
and additive public exports. Added pure `assessGtin` validation for 8/12/13/14-digit
ASCII inputs, exact check digits, zero padding, retailer-code classification,
Unicode/punctuation/length/checksum/all-zero rejection, and explicit UPC-E ambiguity.
Focused tests and the full 73-test suite pass; format, analyzer, and diff checks pass
on Dart 3.12.1. Analyzer reports one pre-existing `use_super_parameters` info and
the existing analyzer-plugin dependency-resolution trace; no new analyzer errors.
Package dry-run executes with the existing dirty-worktree and plural `docs` layout
warnings; publication remains a separate action.

## NID.3 — RS observation extraction

Status: ✅ | MoSCoW: MUST | RICE: 27.00
Reach: 5 | Impact: 3 | Confidence: 0.9 | Effort: 0.5 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.2
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: Source ordinal, html.RCod retailer observation and parser metadata.

Files or areas: lib/models/nfe_item.dart; lib/scraper/rs/fields/rs_item_scraper.dart; rs_items_scraper.dart; focused tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [x] Old monetary output and codigo compatibility retained; raw field captured before lossy cleanup; no fabricated GTIN fields.
- [x] Negative cases covered: Absent versus empty code, parentheses inside code, unknown labels and duplicate rows.
- [x] Actual diff reviewed; task-specific failures resolved or explicitly retained as blockers.

Validation: Existing fixture tests and synthetic identifier-metadata tests.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Legacy-field parity, source order preservation and zero invented GTIN assertions.
Completion evidence: Added additive NfeItem identifier metadata, raw `html.RCod`
observations with absent/present-empty/present-value states, explicit retailer
classification, source ordinals based on RS `<tr>` order, parser/layout metadata,
and tolerant map round-tripping while preserving legacy fields. Synthetic tests
cover absent versus empty codes, parentheses, unknown labels, duplicate rows,
ordering, metadata, and no fabricated GTIN values. Format, analyzer, full 77-test
suite, focused RS tests, and diff checks pass on Dart 3.12.1. Independent review
found blank RCod presence and unknown-label normalization issues; both were fixed,
and the reviewer confirmed the fixes with no remaining findings. Full validation
was rerun successfully. Analyzer reports the existing informational lint and
analyzer-plugin dependency trace.

## NID.4 — Safe URL and request boundary

Status: ✅ | MoSCoW: MUST | RICE: 17.00
Reach: 5 | Impact: 3 | Confidence: 0.85 | Effort: 0.75 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.1
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: Shared exact supported-host/route policy before initial request and every redirect; bounded errors, body and operation lifetime.

Files or areas: lib/decoder/url_state_extractor.dart; url_builder.dart; http_client.dart; decoder.dart; HTTP/URL tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [x] Evidence-based HTTPS endpoints, no userinfo/unapproved ports; max 3 redirects, 30-second operation, 10 MiB response; disposal/cancellation.
- [x] Negative cases covered: Host substring spoofing, HTTP downgrade, cross-host/private destinations, loops, oversized/error response and timeout.
- [x] Actual diff reviewed; findings resolved; final security review reports no remaining P1/P2 findings.

Validation: Injected HTTP clients only; safe exception/log tests.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Enumerated supported variants and negative request matrix; no raw fiscal URLs in tests/logs.
Completion evidence: Exact allowlist covers the two evidenced `www.sefaz.rs.gov.br` QR routes and the evidenced `dfe-portal.svrs.rs.gov.br` QR route. URL parsing and every manual redirect use this policy; the native default transport resolves each connection, rejects non-public IPv4/IPv6 answers, and connects to a validated numeric address without proxies. Redirects cap at three; operation timeout and response size cap at 30 seconds and 10 MiB; only successful HTML responses are accepted. Safe exceptions omit URLs/bodies. Custom injected clients are documented as trusted transports; non-I/O defaults fail closed. Synthetic request and IP-policy tests cover the negative matrix. Reviewer findings on caller-overridable caps, malformed redirect cancellation, duplicate/empty `p`, and reserved IPv6 answers were fixed; final security review reports no remaining P1/P2 findings. Independent validation (Dart 3.12.1): formatting passed for 41 files; focused tests passed (15); full suite passed (89); `git diff --check` passed; `dart analyze` exited 0 with one existing info. The analyzer printed an optional plugin setup conflict between `analysis_server_plugin` and `saropa_lints`, but the analyzer command succeeded. The package dry-run's existing plural `docs/` layout warning is tracked under NID.5 and is not a NID.4 gate. Real network DNS/socket behavior was not exercised; no live-network claim is made.

## NID.5 — Compatibility and release gate

Status: 🧪 | MoSCoW: MUST | RICE: 25.50
Reach: 5 | Impact: 3 | Confidence: 0.85 | Effort: 0.5 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.2, NID.3, NID.4
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: 0.3.0 contract and release notes; correct RS-only support statement.

Files or areas: pubspec.yaml; CHANGELOG.md; README.md; constructor/map/package tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [x] Old constructors/maps work; unknown extensions remain non-actionable at the decoder boundary; current app consumer identified as hosted 0.2.0; no absolute path dependency.
- [x] Negative cases covered: Legacy caller, old maps, unsupported contract, malformed extensions, incompatible request behavior.
- [x] Actual diff reviewed; no actionable findings; release-gate failures retained below.

Validation: D-ALL and package dry run below.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Exact commit/artifact and compatibility matrix; publishing remains a separate consequential action.
Completion evidence: See the NID.5 evidence ledger in `plan/README.md`. Exact immutable 0.3.0 commit/artifact and clean package dry-run remain outstanding; no publication was performed.

## NID.6 — Additional XML capture adapter

Status: 🔒 | MoSCoW: WON'T-YET | RICE: Unscored
Reach/Impact/Confidence/Effort: Unscored until source/access scope is approved.
Dependencies: Approved acquisition/access contract and compatible identifier contract.
Lock reason: No specific XML acquisition route or access contract is approved.
Unlock condition: Owner approves a user-supplied XML or authorized endpoint flow,
security limits and representative privacy-safe fixtures.

Reserved contract: Parse cProd, cEAN, cEANTrib and actual nItem separately; preserve
SEM GTIN, role and field presence. Prohibit external entity/network resolution.
Files/schema: No implementation areas or dependencies authorized yet; define at unlock.
Acceptance/negative cases: Missing/invalid XML fields stay explicit; no anonymous XML
assumption, authentication bypass or external-entity fetch.
Validation/evidence: Future parser/security/compatibility matrix and authorized source
proof. No current authenticated-service integration or app persistence changes.
Completion evidence: Intentionally deferred.
