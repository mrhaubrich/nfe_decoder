import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_total_nota_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('RSTotalNotaScraper', () {
    test('test Irmaos Andreazza Ltda', () {
      final html = '''<div id="totalNota" class="txtRight">
	<div id="linhaTotal"><label>Qtd. total de itens:</label><span class="totalNumb">53</span></div>
	<div id="linhaTotal"><label>Valor total R\$:</label><span class="totalNumb">455,06</span></div>
	<div id="linhaTotal"><label>Descontos R\$:</label><span class="totalNumb">1,52</span></div>
	<div id="linhaTotal" class="linhaShade"><label>Valor a pagar R\$:</label><span
			class="totalNumb txtMax">453,54</span></div>
	<div id="linhaForma"><label>Forma de pagamento:</label><span class="totalNumb txtTitR">Valor pago R\$:</span></div>
	<div id="linhaTotal"><label class="tx">
			Cartão de Débito
		</label><span class="totalNumb">453,54</span></div>
	<div id="linhaTotal"><label class="tx">Troco </label><span class="totalNumb">0,00</span></div>
	<div id="linhaTotal" class="spcTop"><label class="txtObs">Informação dos Tributos Totais Incidentes
			(Lei Federal 12.741/2012)&nbsp;R\$</label><span class="totalNumb txtObs">102,21</span></div>
</div>''';

      final element = Element.html(html);
      final totalNotaScraper = RSTotalNotaScraper(element);
      final totalNota = totalNotaScraper.scrapeTotalNota();

      expect(totalNota.totalItens, 53);
      expect(totalNota.valorTotal, 455.06);
      expect(totalNota.valorDesconto, 1.52);
      expect(totalNota.valorPago, 453.54);
      expect(totalNota.formasPagamento.length, 2);
      expect(totalNota.formasPagamento.first.formaPagamento.descricao,
          'Cartão de Débito');
      expect(totalNota.formasPagamento.first.valor, 453.54);
      expect(totalNota.formasPagamento.last.formaPagamento.descricao, 'Troco');
      expect(totalNota.formasPagamento.last.valor, 0.0);
      expect(totalNota.tributos, 102.21);
    });

    test('test Supermercado Gecepel Ltda', () {
      final html = '''<div id="totalNota" class="txtRight">
	<div id="linhaTotal"><label>Qtd. total de itens:</label><span class="totalNumb">9</span></div>
	<div id="linhaTotal" class="linhaShade"><label>Valor a pagar R\$:</label><span class="totalNumb txtMax">45,75</span>
	</div>
	<div id="linhaForma"><label>Forma de pagamento:</label><span class="totalNumb txtTitR">Valor pago R\$:</span></div>
	<div id="linhaTotal"><label class="tx">
			Cartão de Débito
		</label><span class="totalNumb">45,75</span></div>
	<div id="linhaTotal"></div>
</div>''';

      final element = Element.html(html);
      final totalNotaScraper = RSTotalNotaScraper(element);
      final totalNota = totalNotaScraper.scrapeTotalNota();

      expect(totalNota.totalItens, 9);
      expect(totalNota.valorTotal, isNull);
      expect(totalNota.valorDesconto, 0.0);
      expect(totalNota.valorPago, 45.75);
      expect(totalNota.formasPagamento.length, 1);
      expect(totalNota.formasPagamento.first.formaPagamento.descricao,
          'Cartão de Débito');
      expect(totalNota.formasPagamento.first.valor, 45.75);
      expect(totalNota.tributos, 0.0);
    });
  });
}
