import 'package:http/http.dart' as http;

import 'request_client_unsupported.dart'
    if (dart.library.io) 'request_client_io.dart'
    as platform;

/// Creates the default transport for supported runtime platforms.
http.Client createRequestClient() => platform.createRequestClient();
