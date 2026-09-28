/// Structural validation result for a candidate barcode value.
class GtinAssessment {
  /// Creates an immutable GTIN assessment.
  const GtinAssessment({
    required this.rawValue,
    required this.normalizedValue,
    required this.representationLength,
    required this.validation,
    required this.classification,
    this.gtin14,
  });

  /// The exact input value supplied to the assessment.
  final String rawValue;

  /// The candidate after permitted outer-whitespace trimming.
  final String? normalizedValue;

  /// The original candidate digit length, when it is an accepted length.
  final int? representationLength;

  /// `unchecked`, `invalid-format`, `invalid-check-digit`, or `valid`.
  final String validation;

  /// `gtin`, `retailer-code`, or `unknown`.
  final String classification;

  /// A valid zero-padded 14-digit representation.
  final String? gtin14;
}

/// Assesses GTIN structure without selecting or resolving a product identity.
GtinAssessment assessGtin(String rawValue, {String? role, String? symbology}) {
  final normalizedValue = rawValue.trim();
  final representationLength = normalizedValue.length;

  if (symbology == 'upc-e') {
    return GtinAssessment(
      rawValue: rawValue,
      normalizedValue: normalizedValue,
      representationLength: representationLength == 8
          ? representationLength
          : null,
      validation: 'invalid-format',
      classification: 'unknown',
    );
  }

  if (!_isAsciiDigits(normalizedValue) ||
      !{8, 12, 13, 14}.contains(representationLength)) {
    return GtinAssessment(
      rawValue: rawValue,
      normalizedValue: normalizedValue,
      representationLength: null,
      validation: 'invalid-format',
      classification: 'unknown',
    );
  }

  if (RegExp(r'^0+$').hasMatch(normalizedValue)) {
    return GtinAssessment(
      rawValue: rawValue,
      normalizedValue: normalizedValue,
      representationLength: representationLength,
      validation: 'invalid-format',
      classification: 'unknown',
    );
  }

  if (!_hasValidCheckDigit(normalizedValue)) {
    return GtinAssessment(
      rawValue: rawValue,
      normalizedValue: normalizedValue,
      representationLength: representationLength,
      validation: 'invalid-check-digit',
      classification: 'unknown',
    );
  }

  return GtinAssessment(
    rawValue: rawValue,
    normalizedValue: normalizedValue,
    representationLength: representationLength,
    validation: 'valid',
    classification: role == 'retailer' ? 'retailer-code' : 'gtin',
    gtin14: normalizedValue.padLeft(14, '0'),
  );
}

bool _isAsciiDigits(String value) {
  return value.isNotEmpty &&
      value.codeUnits.every((unit) => unit >= 0x30 && unit <= 0x39);
}

bool _hasValidCheckDigit(String value) {
  var sum = 0;
  for (var index = value.length - 2; index >= 0; index--) {
    final distanceFromRight = value.length - 2 - index;
    final weight = distanceFromRight.isEven ? 3 : 1;
    sum += int.parse(value[index]) * weight;
  }
  final expected = (10 - sum % 10) % 10;
  return expected == int.parse(value[value.length - 1]);
}
