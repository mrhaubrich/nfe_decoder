# Identifier observation contract v1

Approved 2026-09-18; implemented for package version 0.3.0 in NID.5; published 2026-09-29.
Decoder owns source extraction and pure structural validation. GPreços owns identity
resolution, fiscal snapshots, persistence, migrations and reversible user decisions.
Coordination: `gprecos_flutter/docs/product_identity_contract.md` and Phase 12.

## Evidence and supported capture

Inspected decoder d7ec77b (0.2.0). ScraperFactory implements RS only. RSItemScraper
reads `.RCod` into Item.codigo after label/parenthesis/whitespace cleanup; `.txtTit`
provides description and `.RUN` unit. NfeItem stores Item plus quantity/prices. Current
Item/NfeItem constructors and maps expose no separate GTIN/provenance fields.

| Source | Field | Meaning | Capture policy |
|---|---|---|---|
| Inspected RS HTML | .RCod, displayed Código | Retailer code; DANFE standard cProd semantics | Emit html.RCod / retailer; never call it xml.cProd |
| Inspected RS HTML | cEAN/cEANTrib | Not exposed by current adapter/fixtures | Capability absent, not SEM GTIN |
| Explicit future XML | cProd | Retailer code | NID.6 locked |
| Explicit future XML | cEAN | Commercial GTIN or SEM GTIN | NID.6 locked; separate role |
| Explicit future XML | cEANTrib | Taxable-unit GTIN or SEM GTIN | NID.6 locked; no inferred unit conversion |
| Package scan/manual entry | Barcode and symbology | App-origin evidence | App confirmation, reusable pure validator |

Item-only fixture files contain 53 and 9 rows with 4–7 character codes and no explicit
GTIN labels. Their observed HTML is not proof of every current RS layout. The standard
maps displayed Código to cProd; exact RS backend field equivalence remains inference
without paired evidence. NID.1 verifies and records selectors/capabilities using safe
synthetic examples; no live fiscal URLs or identifiers in new fixtures.

### NID.1 verified RS evidence map

The current adapter was checked against the repository fixtures and a synthetic
negative-case matrix. The selectors below are implementation evidence for the
current RS HTML layout, not a claim that every RS page uses the same layout.

| Selector | Legacy output | Evidence interpretation | Capability |
|---|---|---|---|
| `.txtTit` | `Item.descricao` | Item description text | Supported when present |
| `.RCod` | `Item.codigo` after label/parenthesis cleanup | Displayed `Código`; retailer-code evidence only | Supported as `html.RCod`; not GTIN |
| `.RUN` | `Item.unidade` after `UN:` cleanup | Unit text | Supported when present |
| `.Rqtd` | `NfeItem.quantidade` | Quantity text after `Qtde.:` | Supported when present |
| `.RvlUnit` | `NfeItem.valorUnitario` | Unit-price text after `Vl. Unit.:` | Supported when present |
| `.valor` | `NfeItem.valorTotal` | Total-price text | Supported when present |

The repository inventory is two existing fixture views: 9 rows in
`test/mock_data/gecepel_items.html` and 53 rows in
`test/mock_data/andreazza_items.html`. The focused NID.1 matrix additionally
asserts that a missing or empty `.RCod` stays an empty legacy code, a numeric-looking
code remains only retailer-code evidence, repeated rows remain repeated and ordered,
and an unsupported or malformed layout does not manufacture an identifier.
No new fixture contains a QR URL, access key, CNPJ/CPF, consumer data or copied
fiscal HTML.

Public consultation is not proof of anonymous XML download. The published SVRS notice
requires a related party certificate for XML download; acquisition stays a separate gate.
No provider integration, CAPTCHA bypass, credential acquisition or app identity logic.

## Additive public contract

Keep Item.codigo, descricao, unidade and old NfeItem constructor arguments unchanged.
Extend NfeItem with optional metadata (default absent; identifiers default empty):

| Field | Type/semantics |
|---|---|
| identifierContractVersion | Optional integer; 1 when metadata is emitted |
| identifiers | Immutable list of IdentifierObservation |
| rawIdentifiers | Immutable list of quarantined malformed JSON values; emitted only when non-empty |
| sourceItemNumber | Nullable actual source number; never synthesized from HTML position |
| sourceOrdinal | Nullable captured order with explicitly recorded basis |
| sourceMetadata | Layout, parser/package version and capture method; no fiscal URL |

IdentifierObservation fields:

| Field | Contract |
|---|---|
| rawValue | Original extracted field value before lossy legacy cleanup; preserve empty value |
| normalizedValue | Nullable string under named normalization rule |
| gtin14 | Nullable valid zero-padded representation, not a relationship decision |
| representationLength | Original candidate digit length when applicable |
| sourceField | e.g. html.RCod, xml.cEAN, xml.cEANTrib |
| role | retailer, commercial, taxable, package, unknown |
| presence | absent, present-empty, present-value, explicitly-no-GTIN |
| validation | unchecked, invalid-format, invalid-check-digit, valid |
| classification | retailer-code, GTIN, restricted-circulation, PLU, unknown |
| evidenceBasis | legacy, HTML-label, explicit-fiscal-field, package-scan, user-entry, provider-assertion |
| validatorVersion | Versioned rule identifier |
| source metadata | Parser/package version, selector/layout, optional capture time |

The app adds local capture IDs, decision actor/reason, timestamps and relationship
states (candidate, accepted, rejected, disputed, revoked) without changing raw evidence.
Confidence basis (unknown/source-asserted/corroborated/user-confirmed) is provenance,
not an authorization threshold. The decoder never accepts an identity relationship.

Map compatibility: old keys retain meaning; optional metadata emitted only when present;
legacy maps parse; unknown enum strings/extension payloads retain original values and
are non-actionable. Unsupported identifier-contract versions must be retained for the
app to quarantine from resolution while importing safe fiscal fields. Do not crash
solely on a future identifier enum, and do not silently convert it to trusted GTIN.
Malformed extension data must not manufacture an identifier. Document exact optional
map shape in golden tests before package release.

Malformed entries found in the input `identifiers` list remain outside the typed
`identifiers` API and round-trip in the separate `rawIdentifiers` list. Values in that
channel are JSON-only, deeply immutable, and limited to 64 KiB of aggregate UTF-8 JSON
per item with a maximum nesting depth of 128; non-JSON values, non-string map keys,
cyclic values, excessive nesting, and payloads exceeding the limit throw `FormatException`.
The channel is omitted when empty. Typed and raw list ordering is preserved
independently; their original interleaving is not represented. Values in
`rawIdentifiers` remain quarantined even if they resemble a valid observation.

RS must capture raw code before its legacy codigo cleanup, retain old codigo output,
emit only html.RCod retailer evidence and record source order independently of nItem.
The adapter's capability record says explicit GTIN fields are unavailable; missing
fields are not explicit no-GTIN declarations. SEM GTIN is a source literal only when
an actual identifier field supplies it. Never infer XML tags from a generic label.

## Pure GTIN assessment

Proposed public pure function assesses a raw string plus field role/symbology context;
it returns raw/normalized values, representation length, validation and classification.
No I/O, database, provider call or app identity selection. The app reuses this function.

- Accept ASCII digits of lengths 8, 12, 13, 14 after permitted outer whitespace trim.
- Check digit: alternate weights 3 and 1 from rightmost payload digit; expected final
  digit is (10 - sum modulo 10) modulo 10.
- Retain strings/leading zeros. Zero-pad valid representation to 14; no integer casts.
- Nonzero packaging indicator stays significant. Padding is not a new pack/product.
- Reject all-zero identity placeholders. Wrong check digit remains invalid evidence.
- Do not repair punctuation, Unicode digits or scientific notation.
- Eight-digit UPC-E needs trustworthy symbology and expansion; never assume GTIN-8.
- Valid-looking retailer code remains classified retailer-code/candidate in the app.
- Restricted-circulation/PLU values are not globally unique GTIN assertions. Do not
  split price/weight segments without an independently verified retailer format.
- Commercial and taxable GTIN roles never imply product equality or unit conversion.

## Request boundary (NID.4)

isNfeUrl and actual request execution use the same evidence-based exact host/route
policy. Validate before network I/O and on every redirect. HTTPS only; no userinfo or
unapproved ports; reject substring spoofing, downgrade, nonapproved/private destinations,
loops and invalid response types/status. Support only enumerated verified endpoint
variants; do not invent paths. Bound at 3 redirects, 30 seconds per operation and
10 MiB response body initially. Test cancellation and client disposal. Redact errors:
no QR URL, access key, CNPJ/CPF, consumer name or response body in diagnostics.
The default native transport resolves every connection, rejects non-public IP
answers, and connects to the validated numeric address directly without a proxy,
so DNS rebinding cannot change the destination between validation and connection.
Caller-supplied HTTP clients are trusted transports and must enforce equivalent
destination controls. Runtimes without the guarded socket API reject network
requests. Injected HTTP tests use synthetic inputs, never live fiscal links.

## Compatibility and release

Version 0.3.0 introduced the observation contract and stricter request behavior; 0.4.0
adds the quarantined malformed-payload channel. Old constructors/maps remain supported.
NID.5 requires golden map, validator, scraper and injected HTTP tests, format/analyzer/
full-suite/package dry run. A dry run does not publish. GPreços I12.1 consumes the
identified artifact and explicitly preserves metadata through its adapter.
The handoff may be a published version or tested immutable package artifact/commit;
publication is not a hidden prerequisite for app work. Use reproducible dependency
resolution against the approved version. No committed absolute local dependency overrides. Record actual Dart SDK version because
mise currently selects latest. Unsupported state/layout remains explicit; do not claim
support for states absent from ScraperFactory.

## Test and evidence matrix

| Area | Positive/negative cases |
|---|---|
| Source extraction | Current fixture parity, empty/missing code, parentheses, repeated lines, unknown layout |
| GTIN | All lengths, padding equivalence, nonzero indicator, wrong checksum/length, all-zero, Unicode/punctuation, UPC-E ambiguity |
| False matches | Checksum-valid retailer code, PLU/restricted number, explicit commercial/taxable differences |
| Maps | Legacy constructors/maps, optional serialization, unknown enum/version, malformed extension |
| HTTP | Verified variants, spoofed host, redirects, private target, timeout/cancel, oversize/error response, redaction |
| Cross-repository | Decoder map -> app model without loss; package version and app dependency identified |

NID.1 defines synthetic fixtures; no sensitive originals in source control. If live
inspection is needed, keep temporary captures permission-restricted, report aggregates
and delete them after use. Supplied historic corpus counts are not fresh test evidence.

## Sources (reviewed 2026-09-17)

- [DANFE Código/cProd](https://www.nfe.fazenda.gov.br/PORTAl/exibirArquivo.aspx?AspxAutoDetectCookieSupport=1&conteudo=k%2FIuuaW4YiY%3D)
- [MOC identifier fields](https://www.nfe.fazenda.gov.br/PORTAl/exibirArquivo.aspx?conteudo=J+I+v4eN00E%3D)
- [GS1 representations](https://ref.gs1.org/guidelines/2d-in-retail/)
- [GS1 checksum](https://www.gs1.org.sa/services/check-digit-calculator)
- [GS1 restricted circulation](https://ref.gs1.org/standards/genspecs/21.0.1/)
- [SVRS XML access](https://dfe-portal.svrs.rs.gov.br/Nfce/Noticias/2976)
