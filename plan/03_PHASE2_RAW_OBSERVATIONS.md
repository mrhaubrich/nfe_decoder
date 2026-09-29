# Phase 2 — Malformed Raw Observation Retention

Status: ✅ Decoder implementation and validation complete; 0.4.0 publication
user-confirmed on 2026-09-29.
Owner: nfe_decoder. Cross-repository consumer: GPreços Phase 12.
Published contract baseline: immutable nfe_decoder 0.3.0, confirmed as latest on Pub, commit
`758785d3fba531a8851f516c963e4ab29837d1c0`.

## Objective and boundaries

Retain malformed identifier-observation map entries supplied to the decoder's
typed map API as inert, lossless raw payload evidence, including entries whose
`rawValue` is missing or is not a string. The typed `IdentifierObservation`
collection continues to include only entries that pass its existing parsing
rules. Retained malformed data is not a candidate identifier, GTIN assertion,
or input to validation/resolution.

The decoder owns this additive transport/map behavior. GPreços owns quarantine,
storage, display, and all identity decisions. No parser/source extraction,
network behavior, fiscal item fields, or existing valid observation semantics
are in scope.

## Assumptions and unknowns

- Assumption: the boundary receives a Dart map shaped by JSON decoding; only
  JSON-compatible malformed payload values are promised lossless round trips.
- Assumption: additive output is acceptable to consumers that ignore unknown
  map keys, while callers of the typed `identifiers` API must keep seeing only
  successfully parsed observations.
- Decision (2026-09-29): malformed raw payloads are limited to 64 KiB of
  aggregate UTF-8 JSON encoding per `NfeItem`; exceeding the limit throws
  `FormatException` without truncation. Maximum nesting depth is 128. Non-JSON
  runtime values, cyclic values, excessive nesting, and maps with non-string
  keys are explicitly rejected with `FormatException`.
- Decision (2026-09-29): typed and malformed entries are serialized in
  separate `identifiers` and `rawIdentifiers` lists. Each list preserves its
  own input order; cross-list interleaving is not retained.
- Unknown: whether `null` `rawValue` can occur from actual decoder/app data; the
  synthetic compatibility test must cover it regardless.

## Entry and exit criteria

- Entry: GPreços I12.1 is `✅`; its typed adapter and compatibility evidence
  establish the current consumer behavior. The published 0.3.0 source commit
  and behavior remain unchanged. This plan's earlier approval covered planning
  only; the user's explicit 2026-09-29 request separately authorizes NID.7
  implementation, not package publication.
- Exit: NID.7 acceptance and validation below pass on a new decoder change;
  decoder tests/API fixtures demonstrate malformed raw payload round-trip and
  exclusion from the typed `identifiers` API; independent review finds no
  unresolved actionable findings. App consumption confirmation belongs to
  GPreços I12.2 and is not a NID.7 exit gate.
- This phase does not publish a package. Any publication or release requires
  its normal separate approval/workflow.

## NID.7 — Preserve malformed raw observation payloads

Status: ✅ | MoSCoW: MUST | RICE: 6.40
Reach: 4 | Impact: 2 | Confidence: 0.8 | Effort: 1 person-week

Lock reason: N/A; this task is dependency-sequenced, not deliberately locked.
Unlock condition: GPreços I12.1 is recorded `✅` with its adapter compatibility
evidence.
Dependencies: GPreços I12.1.
Owner: decoder implementer; reviewer and validator. GPreços adapter/storage
owner reviews the cross-repository contract only; no overlapping source edits.

Objective: add an optional, additive raw/quarantined payload channel to the
decoder's typed map representation. `fromMap` retains malformed entries from
the `identifiers` collection as JSON-compatible raw values; `toMap` round trips
them without coercing types, dropping fields, or converting them into typed
observations. Existing valid observations continue to use the existing typed
collection and map shape.

Compatibility: keep existing `NfeItem`, `IdentifierObservation`, and legacy
`Item` constructors usable without new required arguments. Existing callers
that only read `identifiers` continue to see only successfully parsed typed
observations. Legacy maps without malformed entries retain their current
serialized shape. The new raw channel is omitted when empty. Do not change,
backdate, or claim the immutable 0.3.0 behavior includes this capability.

Files or areas: public `NfeItem` map model/export and public compatibility tests;
package documentation/changelog for a future release line. No parser source or
network changes.

Acceptance criteria:
- [ ] A malformed observation missing `rawValue` survives `fromMap` -> `toMap`
  with its original JSON-compatible fields and remains absent from the typed
  `identifiers` collection.
- [ ] An observation with non-string `rawValue` (at minimum a number, plus null
  where representable) survives round trip with its original type/value and
  remains absent from the typed collection.
- [ ] Mixed valid and malformed entries preserve both typed-valid content and
  malformed raw payloads independently, in their original order within each
  representation; malformed content never enters GTIN assessment or any
  actionable typed API.
- [ ] Existing constructor call sites, legacy map shape, and valid observation
  map compatibility remain covered and unchanged in behavior.
- [ ] No mutation through returned raw payload structures can alter retained
  state; nested JSON maps/lists are defensively copied/frozen consistently with
  the existing metadata treatment.
- [ ] Independent review and focused compatibility validation are recorded.

Validation:
- Add focused public API tests for missing, numeric and null `rawValue`, mixed
  valid/malformed entries, nested payload round trip, and non-actionability.
- Run decoder format check, focused public compatibility tests, full decoder
  suite, analyzer, package dry-run, and `git diff --check`; record exact results
  and tool versions in the evidence ledger.
- Record app consumption and persistence confirmation under GPreços I12.2;
  NID.7 completion makes no claim that the app has integrated the new field.

Risks: arbitrary malformed payloads could be treated as trusted identifiers or
altered during serialization. Mitigate by a distinct raw/quarantine field,
strict typed parsing unchanged, immutable JSON-compatible values, a 64 KiB
aggregate UTF-8 JSON limit, explicit rejection of non-JSON values, and negative
tests.

Out of scope: changing 0.3.0, publishing, parser/source changes, accepting
malformed values as identifiers, identity resolution, persistence implementation,
additional XML capture (NID.6), and any change to I12.1 acceptance or scope.

Completion evidence (2026-09-29, Dart SDK 3.12.1): public compatibility tests
cover missing, numeric and null `rawValue`, mixed valid/malformed entries,
independent ordering, raw values that resemble valid observations, nested
round-trip and immutability, exact 64 KiB boundary, oversized/deep/cyclic and
non-JSON rejection, and legacy constructor/map compatibility. `dart format
--output=none --set-exit-if-changed lib test` passed (42 files); focused public
compatibility suite passed (9 tests); full suite passed (98 tests); `dart
analyze` exited 0 with one existing `use_super_parameters` info plus an analyzer
plugin dependency-resolution diagnostic (`analysis_server_plugin` versus
`saropa_lints 9.10.0`); `git diff --check` passed. Package dry-run from a clean
temporary copy with the six changed files overlaid exited 0 with zero warnings;
the in-checkout attempt exited 65 solely because the working tree was modified.
Independent review found no actionable issues. At NID.7 completion, no package
had been published; the user later confirmed 0.4.0 publication on 2026-09-29.
No app integration/persistence claim is made; those remain downstream GPreços
I12.2 evidence.
