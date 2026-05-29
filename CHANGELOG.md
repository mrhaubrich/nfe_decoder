## 0.2.0 (2026-05-29)

- Breaking: Removed the direct `dio` dependency and replaced the HTTP client implementation with `package:http`.
- Breaking: Removed the direct `intl` dependency and replaced `DateFormat` usage with strict local parsing for RS emission dates.
- Fix: Preserved redirected response URI handling in `HTTPClient` after moving away from Dio.
- Test: Replaced live SEFAZ HTTP calls in HTTP client tests with an injected fake client to avoid flaky network failures.

## 0.1.3 (2023-10-17)

- Fix: Changed dependencies constraints to allow newer versions.
 
## 0.1.2 (2023-10-17)

- Feature: Add `isNfeUrl` method to `Decoder`.
 
## 0.1.1 (2023-10-15)

- Feature: Add `toMap` and `fromMap` methods to models.
- Feature: Publicly expose all models.

## 0.1.0 (2023-10-15)

- Initial version.
