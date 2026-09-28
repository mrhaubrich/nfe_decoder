import 'package:nfe_decoder/models/identifier_observation.dart';
import 'package:nfe_decoder/models/item.dart';
import 'package:test/test.dart';

void main() {
  test('round-trips raw values, unknown states, and extensions', () {
    final observation = IdentifierObservation.tryParse({
      'rawValue': '000123',
      'sourceField': 'future.field',
      'role': 'future-role',
      'presence': 'future-presence',
      'validation': 'future-validation',
      'classification': 'future-classification',
      'evidenceBasis': 'future-evidence',
      'futurePayload': {'safe': true},
    });

    expect(observation, isNotNull);
    expect(observation!.rawValue, '000123');
    expect(observation.role, 'future-role');
    expect(observation.extensions['futurePayload'], {'safe': true});
    expect(observation.toMap()['futurePayload'], {'safe': true});
  });

  test('rejects malformed maps without manufacturing an observation', () {
    expect(
      IdentifierObservation.tryParse({'sourceField': 'html.RCod'}),
      isNull,
    );
    expect(IdentifierObservation.tryParse('not-a-map'), isNull);
  });

  test('omits absent optional fields from the wire map', () {
    final observation = IdentifierObservation(
      rawValue: '',
      sourceField: 'html.RCod',
      presence: 'present-empty',
    );

    expect(observation.toMap(), {
      'rawValue': '',
      'sourceField': 'html.RCod',
      'role': 'unknown',
      'presence': 'present-empty',
      'validation': 'unchecked',
      'classification': 'unknown',
      'evidenceBasis': 'unknown',
    });
  });

  test('keeps the legacy Item constructor and map unchanged', () {
    final item = Item(
      codigo: 'legacy-code',
      descricao: 'Legacy item',
      unidade: 'UN',
    );

    expect(Item.fromMap(item.toMap()).toMap(), item.toMap());
  });
}
