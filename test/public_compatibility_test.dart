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
      expect(assessGtin('00012345').classification, 'unknown');
    });

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
