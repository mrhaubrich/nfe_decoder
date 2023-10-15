# NFE Decoder

NFE Decoder is a Dart library designed to scrape and extract information from Nota Fiscal Eletrônica (NFE) URLs, providing a structured way to access invoice details.

## Features

- Decode NFE URLs and retrieve detailed invoice data.
- Supports multiple state-specific NFE formats.
- Provides a clean API for integration into larger projects or use as a standalone library.

## Installation

To use the NFE Decoder in your project, add it to your `pubspec.yaml`:

```yaml
dependencies:
  nfe_decoder: ^latest_version
```

Then, run:

```
pub get
```

## Usage

Here's a basic example of how to use the `Decoder` class to extract information from an NFE URL:

```dart
import 'package:nfe_decoder/nfe_decoder.dart';

void main() async {
  var decoder = Decoder('some_nfe_url');
  var nfe = await decoder.scrapeNfe();
  print(nfe);
}
```

For more detailed examples and advanced configurations, please refer to the [documentation](#documentation-link).

## Available Decoders
- [ ] [Acre](https://www.sefaznet.ac.gov.br/nfce/consulta)
- [ ] [Alagoas](https://www.sefaz.al.gov.br/portal/consultaNFCe.jsp)
- [ ] [Amapá](https://www.sefaz.ap.gov.br/nfce/portal/consultaNFCe.jsp)
- [ ] [Amazonas](https://sistemas.sefaz.am.gov.br/nfceweb/consultarNFCe.jsp)
- [ ] [Bahia](http://nfe.sefaz.ba.gov.br/servicos/nfce/Modulos/Geral/NFCEC_consulta_chave_acesso.aspx)
- [ ] [Ceará](https://nfce.sefaz.ce.gov.br/pages/ShowNFCe.html)
- [ ] [Distrito Federal](https://dec.fazenda.df.gov.br/ConsultarNFCe.aspx)
- [ ] [Espírito Santo](https://internet.sefaz.es.gov.br/informacoes/nfe.aspx)
- [ ] [Goiás](https://www.sefaz.go.gov.br/ccn/)
- [ ] [Maranhão](https://www.sefaz.ma.gov.br/portalsefaz/jsp/pagina/pagina.jsf?codigo=167)
- [ ] [Mato Grosso do Sul](https://www.dfe.ms.gov.br/nfce)
- [ ] [Mato Grosso](https://www.sefaz.mt.gov.br/nfce/portal/consultaNFCe.jsp)
- [ ] [Minas Gerais](https://www.fazenda.mg.gov.br/empresas/obtenha_sua_nota_fiscal_eletronica.html)
- [ ] [Paraná](https://www.fazenda.pr.gov.br/nfe/)
- [ ] [Paraíba](https://www.receita.pb.gov.br/ser/info/nfc-e)
- [ ] [Pará](https://appnfc.sefa.pa.gov.br/portal/view/consultas/nfce/nfceForm.seam)
- [ ] [Pernambuco](https://nfce.sefaz.pe.gov.br/nfce-web/consultarNFCe)
- [ ] [Piauí](https://www.sefaz.pi.gov.br/nfce/consulta)
- [ ] [Rio Grande do Norte](https://www.set.rn.gov.br/nfce)
- [x] [Rio Grande do Sul](https://www.sefaz.rs.gov.br/NFE/NFE-CCC.aspx)
- [ ] [Rio de Janeiro](https://www4.fazenda.rj.gov.br/consultaNFCe/QRCode)
- [ ] [Rondônia](https://www.nfce.sefin.ro.gov.br/portal/consultaNFCe.jsp)
- [ ] [Roraima](https://www.sefaz.rr.gov.br/nfce/servlet/qrcode?chNFe=)
- [ ] [Santa Catarina](https://nfe.sef.sc.gov.br/nfe/consulta)
- [ ] [Sergipe](https://www.sefaz.se.gov.br/nfce/consulta)
- [ ] [São Paulo](https://www.nfe.fazenda.sp.gov.br/NF3/nf3.aspx)
- [ ] [Tocantins](https://www.sefaz.to.gov.br/nfce/consulta)

## Documentation

Detailed documentation can be found [here](#documentation-link).

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/fooBar`).
3. Commit your changes (`git commit -am 'Add some fooBar'`).
4. Push to the branch (`git push origin feature/fooBar`).
5. Create a new pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.