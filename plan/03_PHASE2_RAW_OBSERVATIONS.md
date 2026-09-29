# Phase 2 — Malformed Raw Observation Retention

Status: 🔲 Planned follow-up; inactive until GPreços I12.1 is complete.
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
- Unknown: maximum retained payload size and rejection/handling of non-JSON
  runtime objects. NID.7 design must settle and document these before coding.
- Unknown: whether `null` `rawValue` can occur from actual decoder/app data; the
  synthetic compatibility test must cover it regardless.

## Entry and exit criteria

- Entry: GPreços I12.1 is `✅`; its typed adapter and compatibility evidence
  establish the current consumer behavior. The published 0.3.0 source commit
  and behavior remain unchanged. NID.7 is a later, separate change and is not
  authorized or published by this plan.
- Exit: NID.7 acceptance and validation below pass on a new decoder change;
  decoder tests/API fixtures demonstrate malformed raw payload round-trip and
  exclusion from the typed `identifiers` API; independent review finds no
  unresolved actionable findings. App consumption confirmation belongs to
  GPreços I12.2 and is not a NID.7 exit gate.
- This phase does not publish a package. Any publication or release requires
  its normal separate approval/workflow.

## NID.7 — Preserve malformed raw observation payloads

Status: 🔲 | MoSCoW: MUST | RICE: 6.40
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
strict typed parsing unchanged, immutable JSON-compatible values, and explicit
negative tests. Payload size limits and rejection behavior for non-JSON runtime
objects are unknown and must be decided and documented during NID.7 design
before source implementation.

Out of scope: changing 0.3.0, publishing, parser/source changes, accepting
malformed values as identifiers, identity resolution, persistence implementation,
additional XML capture (NID.6), and any change to I12.1 acceptance or scope.

Completion evidence: Not started.
