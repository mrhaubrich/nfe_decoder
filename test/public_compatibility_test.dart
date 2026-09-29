import 'package:nfe_decoder/nfe_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('public package compatibility', () {
    test('keeps legacy Item and NfeItem constructors and maps', () {
      final item = Item(
        codigo: 'legacy-code',
        descricao: 'Legacy description',
        unidade: 'UN',
      );
      final nfeItem = NfeItem(
        item: item,
        quantidade: 2,
        valorUnitario: 3.5,
        valorTotal: 7,
      );

      expect(item.toMap(), {
        'codigo': 'legacy-code',
        'descricao': 'Legacy description',
        'unidade': 'UN',
      });
      expect(nfeItem.toMap(), {
        'item': item.toMap(),
        'quantidade': 2,
        'valorUnitario': 3.5,
        'valorTotal': 7,
      });
      expect(NfeItem.fromMap(nfeItem.toMap()).toMap(), nfeItem.toMap());
    });

    test('keeps the legacy NFE constructor and nested map shape', () {
      final nfe = NFE(
        estabelecimento: Estabelecimento(
          nome: 'Synthetic store',
          cnpj: '00000000000000',
          endereco: Endereco(
            logradouro: 'Synthetic street',
            numero: '1',
            complemento: '',
            bairro: 'Synthetic neighborhood',
            cidade: 'Synthetic city',
            estado: 'RS',
          ),
        ),
        nfeChave: 'synthetic-key',
        dataEmissao: DateTime.utc(2026),
        valorTotal: 7,
        valorDesconto: 0,
        formasPagamento: [
          NfeFormaPagamento(
            formaPagamento: FormaPagamento(descricao: 'synthetic'),
            valor: 7,
          ),
        ],
        valorPago: 7,
        items: [
          NfeItem(
            item: Item(
              codigo: 'legacy-code',
              descricao: 'Synthetic item',
              unidade: 'UN',
            ),
            quantidade: 1,
            valorUnitario: 7,
            valorTotal: 7,
          ),
        ],
        valorTributos: 0,
      );

      final map = nfe.toMap();
      expect(
        map.keys,
        containsAll([
          'estabelecimento',
          'nfeChave',
          'dataEmissao',
          'valorTotal',
          'valorDesconto',
          'formasPagamento',
          'valorPago',
          'items',
          'url',
          'valorTributos',
        ]),
      );
      expect(NFE.fromMap(map).toMap(), map);
    });

    test('preserves future contract data without treating it as a GTIN', () {
      final legacyFiscalFields = <String, dynamic>{
        'item': {
          'codigo': '00012345',
          'descricao': 'Legacy description',
          'unidade': 'UN',
        },
        'quantidade': 1.0,
        'valorUnitario': 2.0,
        'valorTotal': 2.0,
      };
      final futureMap = {
        ...legacyFiscalFields,
        'identifierContractVersion': 99,
        'identifiers': [
          {
            'rawValue': '00012345',
            'sourceField': 'future.field',
            'role': 'future-role',
            'classification': 'future-classification',
            'futureDecision': {'accepted': true},
          },
          {'sourceField': 'malformed-without-raw-value'},
        ],
      };

      final parsed = NfeItem.fromMap(futureMap);

      expect(parsed.item.toMap(), legacyFiscalFields['item']);
      expect(parsed.identifierContractVersion, 99);
      expect(parsed.identifiers, hasLength(1));
      expect(parsed.identifiers.single.classification, 'future-classification');
      expect(parsed.identifiers.single.extensions['futureDecision'], {
        'accepted': true,
      });
      expect(parsed.toMap()['identifiers'], hasLength(1));
      expect(parsed.toMap()['rawIdentifiers'], [
        {'sourceField': 'malformed-without-raw-value'},
      ]);
      expect(assessGtin('00012345').classification, 'unknown');
    });

    test('round-trips malformed and non-string raw values separately', () {
      final malformed = <Object?>[
        {'sourceField': 'missing-raw-value', 'extra': 'kept'},
        {'rawValue': 42, 'sourceField': 'numeric-raw-value'},
        {'rawValue': null, 'sourceField': 'null-raw-value'},
      ];
      final parsed = NfeItem.fromMap({
        ..._legacyItemMap,
        'identifiers': malformed,
      });

      expect(parsed.identifiers, isEmpty);
      expect(parsed.rawIdentifiers, malformed);
      expect(parsed.toMap()['identifiers'], isNull);
      expect(parsed.toMap()['rawIdentifiers'], malformed);
      expect(NfeItem.fromMap(parsed.toMap()).toMap(), parsed.toMap());
    });

    test(
      'preserves valid and raw order independently and never reparses raw',
      () {
        final validFirst = {'rawValue': 'first', 'sourceField': 'first-field'};
        final validSecond = {
          'rawValue': 'second',
          'sourceField': 'second-field',
        };
        final rawFirst = {'sourceField': 'malformed-first'};
        final rawSecond = {
          'rawValue': 'looks-valid',
          'sourceField': 'still-quarantined',
        };
        final parsed = NfeItem.fromMap({
          ..._legacyItemMap,
          'identifiers': [validFirst, rawFirst, validSecond],
          'rawIdentifiers': [rawSecond],
        });

        expect(parsed.identifiers.map((value) => value.rawValue), [
          'first',
          'second',
        ]);
        expect(parsed.rawIdentifiers, [rawFirst, rawSecond]);
        final serializedValid = parsed.toMap()['identifiers'] as List;
        expect(
          serializedValid.map((value) => (value as Map)['rawValue']).toList(),
          ['first', 'second'],
        );
        expect(parsed.toMap()['rawIdentifiers'], [rawFirst, rawSecond]);
      },
    );

    test('deep-copies and freezes nested raw JSON payloads', () {
      final nestedList = <Object?>[
        1,
        <String, Object?>{'value': 'before'},
      ];
      final raw = <String, Object?>{
        'sourceField': 'nested',
        'payload': nestedList,
      };
      final parsed = NfeItem.fromMap({
        ..._legacyItemMap,
        'identifiers': [raw],
      });

      nestedList.add('after');
      (nestedList[1] as Map<String, Object?>)['value'] = 'changed';

      final retained = parsed.rawIdentifiers.single as Map;
      expect(retained['payload'], [
        1,
        {'value': 'before'},
      ]);
      expect(
        () => (retained['payload'] as List).add('mutation'),
        throwsUnsupportedError,
      );
      expect(
        () => (retained['payload'] as List)[1]['value'] = 'mutation',
        throwsUnsupportedError,
      );
    });

    test(
      'rejects non-JSON values, non-string keys, and oversized payloads',
      () {
        final oversizedMalformedMap = <String, Object?>{
          for (var index = 0; index < 20_000; index++)
            'field$index': 'value$index',
        };
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': [
              {'sourceField': 'unsupported', 'rawValue': DateTime.utc(2026)},
            ],
          }),
          throwsFormatException,
        );
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': [
              <Object?, Object?>{1: 'not-json'},
            ],
          }),
          throwsFormatException,
        );
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': [
              {'sourceField': 'large', 'payload': List.filled(65_536, 'x')},
            ],
          }),
          throwsFormatException,
        );
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': List<Object?>.filled(70_000, null),
          }),
          throwsFormatException,
        );
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': [oversizedMalformedMap],
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'enforces the exact JSON byte limit and rejects cyclic/deep values',
      () {
        final atLimit = NfeItem.fromMap({
          ..._legacyItemMap,
          'identifiers': [List.filled(65_532, 'x').join()],
        });
        expect(atLimit.rawIdentifiers.single, hasLength(65_532));

        final cyclic = <Object?>[];
        cyclic.add(cyclic);
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': [cyclic],
          }),
          throwsFormatException,
        );

        Object? deeplyNested = 'leaf';
        for (var depth = 0; depth < 130; depth++) {
          deeplyNested = [deeplyNested];
        }
        expect(
          () => NfeItem.fromMap({
            ..._legacyItemMap,
            'identifiers': [deeplyNested],
          }),
          throwsFormatException,
        );
      },
    );

    test('exports observation and GTIN APIs from the package entry point', () {
      final observation = IdentifierObservation(
        rawValue: '036000291452',
        sourceField: 'test.synthetic',
      );

      expect(observation.rawValue, '036000291452');
      expect(assessGtin('036000291452').validation, 'valid');
    });
  });
}

const _legacyItemMap = <String, dynamic>{
  'item': {'codigo': 'legacy-code', 'descricao': 'Legacy', 'unidade': 'UN'},
  'quantidade': 1.0,
  'valorUnitario': 2.0,
  'valorTotal': 2.0,
};
