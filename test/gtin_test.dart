import 'package:nfe_decoder/identifiers/gtin.dart';
import 'package:test/test.dart';

void main() {
  group('assessGtin', () {
    test(
      'validates every accepted length and pads without integer conversion',
      () {
        final cases = {
          '96385074': '00000096385074',
          '036000291452': '00036000291452',
          '4006381333931': '04006381333931',
          '10012345678902': '10012345678902',
        };

        for (final entry in cases.entries) {
          final assessment = assessGtin('  ${entry.key}  ');

          expect(assessment.validation, 'valid', reason: entry.key);
          expect(assessment.representationLength, entry.key.length);
          expect(assessment.gtin14, entry.value);
        }
      },
    );

    test('classifies a checksum-valid retailer code conservatively', () {
      final assessment = assessGtin('036000291452', role: 'retailer');

      expect(assessment.validation, 'valid');
      expect(assessment.classification, 'retailer-code');
    });

    test(
      'rejects Unicode digits and punctuation instead of repairing them',
      () {
        expect(assessGtin('０３６０００２９１４５２').validation, 'invalid-format');
        expect(assessGtin('036000-291452').validation, 'invalid-format');
      },
    );

    test('rejects wrong length, checksum, and all-zero placeholders', () {
      expect(assessGtin('1234567').validation, 'invalid-format');
      expect(assessGtin('036000291453').validation, 'invalid-check-digit');
      expect(assessGtin('000000000000').validation, 'invalid-format');
    });

    test('does not assume an eight-digit UPC-E is GTIN-8', () {
      final assessment = assessGtin('04210005', symbology: 'upc-e');

      expect(assessment.validation, 'invalid-format');
      expect(assessment.gtin14, isNull);
    });
  });
}
