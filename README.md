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