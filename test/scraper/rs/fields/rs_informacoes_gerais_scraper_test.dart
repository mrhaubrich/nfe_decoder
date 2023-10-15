import 'package:html/dom.dart';
import 'package:nfe_decoder/scraper/rs/fields/rs_informacoes_gerais_scraper.dart';
import 'package:test/test.dart';

void main() {
  test('RSInformacoesGeraisScraper -> test Irmaos Andreazza Ltda', () {
    final html =
        '''<li class="ui-li-static ui-body-inherit ui-first-child ui-last-child"><strong>EMISSÃO NORMAL</strong><br><br><strong>Número: </strong>12890<strong> Série: </strong>441<strong> Emissão: </strong>08/07/2022 17:38:39
								- Via Consumidor 2
								<br><br><strong>Protocolo de Autorização: </strong>143221012775368       08/07/2022 
        às
      17:38:40<br><br><strong>
										Ambiente de Produção -
									
									Versão XML:
									4.00
									- Versão XSLT: 2.07
								</strong></li>''';

    final element = Element.html(html);
    final estabelecimentoScraper = RSInformacoesGeraisScraper(element);
    final informacoesGerais = estabelecimentoScraper.scrapeInformacoesGerais();

    expect(informacoesGerais.dataEmissao, DateTime(2022, 7, 8, 17, 38, 39));
  });
}
