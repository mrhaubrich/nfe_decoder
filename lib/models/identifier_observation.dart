/// An identifier observation captured from a source without resolving identity.
class IdentifierObservation {
  /// Creates an immutable source observation.
  IdentifierObservation({
    required this.rawValue,
    required this.sourceField,
    this.normalizedValue,
    this.gtin14,
    this.representationLength,
    this.role = 'unknown',
    this.presence = 'present-value',
    this.validation = 'unchecked',
    this.classification = 'unknown',
    this.evidenceBasis = 'unknown',
    this.validatorVersion,
    Map<String, dynamic> extensions = const {},
  }) : extensions = _freezeMap(extensions);

  /// The exact value observed before lossy normalization.
  final String rawValue;

  /// The value after an explicitly named normalization rule, if any.
  final String? normalizedValue;

  /// A valid zero-padded GTIN representation, if independently assessed.
  final String? gtin14;

  /// The original candidate digit length, when applicable.
  final int? representationLength;

  /// The source field role, such as `retailer` or `commercial`.
  final String role;

  /// The source presence state.
  final String presence;

  /// The structural validation state.
  final String validation;

  /// The conservative classification of the observed value.
  final String classification;

  /// The provenance basis for this observation.
  final String evidenceBasis;

  /// The version of the pure validator, when validation was performed.
  final String? validatorVersion;

  /// Unknown extension fields preserved without making them actionable.
  final Map<String, dynamic> extensions;

  /// The field or selector that produced this observation.
  final String sourceField;

  /// Parses a well-formed observation, returning `null` for malformed input.
  ///
  /// Unknown enum-like strings and extension payloads are retained verbatim.
  /// A malformed map never creates an observation.
  static IdentifierObservation? tryParse(Object? value) {
    if (value is! Map) return null;

    final map = Map<String, dynamic>.fromEntries(
      value.entries
          .where((entry) => entry.key is String)
          .map((entry) => MapEntry(entry.key as String, entry.value)),
    );
    final rawValue = map['rawValue'];
    final sourceField = map['sourceField'];
    if (rawValue is! String || sourceField is! String) return null;

    final extensions = <String, dynamic>{};
    for (final entry in map.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extensions[entry.key] = entry.value;
      }
    }

    return IdentifierObservation(
      rawValue: rawValue,
      sourceField: sourceField,
      normalizedValue: _stringOrNull(map['normalizedValue']),
      gtin14: _stringOrNull(map['gtin14']),
      representationLength: _intOrNull(map['representationLength']),
      role: _stringOrDefault(map['role'], 'unknown'),
      presence: _stringOrDefault(map['presence'], 'present-value'),
      validation: _stringOrDefault(map['validation'], 'unchecked'),
      classification: _stringOrDefault(map['classification'], 'unknown'),
      evidenceBasis: _stringOrDefault(map['evidenceBasis'], 'unknown'),
      validatorVersion: _stringOrNull(map['validatorVersion']),
      extensions: extensions,
    );
  }

  /// Converts this observation to the additive wire-map shape.
  Map<String, dynamic> toMap() {
    return {
      ...extensions,
      'rawValue': rawValue,
      'sourceField': sourceField,
      if (normalizedValue != null) 'normalizedValue': normalizedValue,
      if (gtin14 != null) 'gtin14': gtin14,
      if (representationLength != null)
        'representationLength': representationLength,
      'role': role,
      'presence': presence,
      'validation': validation,
      'classification': classification,
      'evidenceBasis': evidenceBasis,
      if (validatorVersion != null) 'validatorVersion': validatorVersion,
    };
  }
}

const _knownKeys = {
  'rawValue',
  'normalizedValue',
  'gtin14',
  'representationLength',
  'sourceField',
  'role',
  'presence',
  'validation',
  'classification',
  'evidenceBasis',
  'validatorVersion',
};

String? _stringOrNull(Object? value) => value is String ? value : null;

String _stringOrDefault(Object? value, String fallback) {
  return value is String ? value : fallback;
}

int? _intOrNull(Object? value) => value is int ? value : null;

Map<String, dynamic> _freezeMap(Map<String, dynamic> value) {
  return Map.unmodifiable(
    value.map((key, item) => MapEntry(key, _freezeValue(item))),
  );
}

Object? _freezeValue(Object? value) {
  if (value is Map) {
    return Map.unmodifiable(
      value.map((key, item) => MapEntry(key.toString(), _freezeValue(item))),
    );
  }
  if (value is List) return List.unmodifiable(value.map(_freezeValue));
  return value;
}
