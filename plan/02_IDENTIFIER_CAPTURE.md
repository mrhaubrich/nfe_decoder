# Identifier capture and compatibility

Status: 🔄 Active workstream; approved 2026-09-18; NID.2 is complete.
Contract: [identifier contract](../docs/identifier_contract.md).
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

Files or areas: Existing RS scraper/fixtures/tests; docs/identifier_contract.md.
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

Status: 🔲 | MoSCoW: MUST | RICE: 27.00
Reach: 5 | Impact: 3 | Confidence: 0.9 | Effort: 0.5 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.2
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: Source ordinal, html.RCod retailer observation and parser metadata.

Files or areas: lib/models/nfe_item.dart; lib/scraper/rs/fields/rs_item_scraper.dart; rs_items_scraper.dart; focused tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [ ] Old monetary output and codigo compatibility retained; raw field captured before lossy cleanup; no fabricated GTIN fields.
- [ ] Negative cases covered: Absent versus empty code, parentheses inside code, unknown labels and duplicate rows.
- [ ] Actual diff reviewed; task-specific failures resolved or explicitly retained as blockers.

Validation: Existing fixture tests and synthetic identifier-metadata tests.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Legacy-field parity, source order preservation and zero invented GTIN assertions.
Completion evidence: Not executed; implementation not started.

## NID.4 — Safe URL and request boundary

Status: 🔲 | MoSCoW: MUST | RICE: 17.00
Reach: 5 | Impact: 3 | Confidence: 0.85 | Effort: 0.75 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.1
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: Shared exact supported-host/route policy before initial request and every redirect; bounded errors, body and operation lifetime.

Files or areas: lib/decoder/url_state_extractor.dart; url_builder.dart; http_client.dart; decoder.dart; HTTP/URL tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [ ] Evidence-based HTTPS endpoints, no userinfo/unapproved ports; max 3 redirects, 30-second operation, 10 MiB response; disposal/cancellation.
- [ ] Negative cases covered: Host substring spoofing, HTTP downgrade, cross-host/private destinations, loops, oversized/error response and timeout.
- [ ] Actual diff reviewed; task-specific failures resolved or explicitly retained as blockers.

Validation: Injected HTTP clients only; safe exception/log tests.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Enumerated supported variants and negative request matrix; no raw fiscal URLs in tests/logs.
Completion evidence: Not executed; implementation not started.

## NID.5 — Compatibility and release gate

Status: 🔲 | MoSCoW: MUST | RICE: 25.50
Reach: 5 | Impact: 3 | Confidence: 0.85 | Effort: 0.5 person-weeks

Lock reason: N/A; dependency sequencing applies.
Unlock condition: N/A; select only after dependencies are complete in the active workstream.
Dependencies: NID.2, NID.3, NID.4
Owner: decoder implementer; architect/reviewer/validator handoff.

Objective and public contract: 0.3.0 contract and release notes; correct RS-only support statement.

Files or areas: pubspec.yaml; CHANGELOG.md; README.md; constructor/map/package tests.
Schema changes: No independent schema/version change; consume the approved schema/transport contract. Any deviation returns to architect/planner.

Acceptance criteria:
- [ ] Old constructors/maps work; unknown extensions remain non-actionable; app consuming artifact version identified; no absolute path dependency.
- [ ] Negative cases covered: Legacy caller, old maps, unsupported contract, malformed extensions, incompatible request behavior.
- [ ] Actual diff reviewed; task-specific failures resolved or explicitly retained as blockers.

Validation: D-ALL and package dry run below.

Risks: False identity, lost evidence or incompatible persistence; mitigate using the
contract invariants and listed negative cases, not heuristic fallbacks.
Out of scope: Unrelated changes, rich enrichment, unlocking S11.9 and application work
outside this task. NID tasks never own app resolution/storage; app tasks never silently
change the decoder wire contract.

Required completion evidence: Exact commit/artifact and compatibility matrix; publishing remains a separate consequential action.
Completion evidence: Not executed; implementation not started.

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
