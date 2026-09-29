# NFE Decoder

NFE Decoder is a Dart library designed to scrape and extract information from Nota Fiscal Eletrônica (NFE) URLs, providing a structured way to access invoice details.

## Features

- Decode NFE URLs and retrieve detailed invoice data.
- Supports Rio Grande do Sul (RS) NFC-e URLs only.
- Provides a clean API for integration into larger projects or use as a standalone library.

## Installation

To use the NFE Decoder in your project, add it to your `pubspec.yaml`:

```yaml
dependencies:
  nfe_decoder: ^0.4.0
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

For the identifier observation and compatibility contract, see
[the decoder contract](doc/identifier_contract.md).

## Available Decoders
- [Rio Grande do Sul](https://www.sefaz.rs.gov.br/NFE/NFE-CCC.aspx)

## Documentation

Only the RS scraper is implemented. Other state-specific formats are not
supported by this package.

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/fooBar`).
3. Commit your changes (`git commit -am 'Add some fooBar'`).
4. Push to the branch (`git push origin feature/fooBar`).
5. Create a new pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
