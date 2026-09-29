import 'dart:async';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'request_client.dart';
import 'url_state_extractor.dart';

const _maxRedirects = 3;
const _maxResponseBytes = 10 * 1024 * 1024;
const _operationTimeout = Duration(seconds: 30);

/// A deliberately non-sensitive request failure. It never includes a URL/body.
class NfeRequestException implements Exception {
  final String message;

  const NfeRequestException(this.message);

  @override
  String toString() => 'NfeRequestException: $message';
}

/// HTTP boundary for fetching supported NFC-e QR-code pages.
///
/// The default native transport pins each connection to a validated public DNS
/// answer. A caller-supplied [client] is treated as a trusted transport and is
/// responsible for enforcing equivalent destination controls.
class HTTPClient {
  final http.Client _client;
  final Duration _timeout;
  final int _responseLimit;
  bool _closed = false;
  bool _transportClosed = false;

  HTTPClient({
    http.Client? client,
    Duration timeout = _operationTimeout,
    int maxResponseBytes = _maxResponseBytes,
  }) : _client = client ?? createRequestClient(),
       _timeout = _boundedTimeout(timeout),
       _responseLimit = _boundedResponseLimit(maxResponseBytes);

  Future<HTTPResponse> get(String url) async {
    if (_closed || _transportClosed) {
      throw const NfeRequestException('Client is closed');
    }

    Uri current;
    try {
      current = Uri.parse(url);
    } on FormatException {
      throw const NfeRequestException('Unsupported request URL');
    }
    if (!URLStateExtractor.isSupportedUri(current)) {
      throw const NfeRequestException('Unsupported request URL');
    }

    final deadline = DateTime.now().add(_timeout);
    var redirects = 0;
    while (true) {
      final request = http.Request('GET', current)..followRedirects = false;
      http.StreamedResponse streamed;
      try {
        streamed = await _withinDeadline(_client.send(request), deadline);
      } on TimeoutException {
        _closeTransport();
        throw const NfeRequestException('Request timed out');
      } on Object {
        throw const NfeRequestException('Request failed');
      }

      final status = streamed.statusCode;
      if (_isRedirect(status)) {
        if (redirects >= _maxRedirects) {
          await streamed.stream.listen(null).cancel();
          throw const NfeRequestException('Too many redirects');
        }
        final location = streamed.headers['location'];
        if (location == null) {
          await streamed.stream.listen(null).cancel();
          throw const NfeRequestException('Invalid redirect');
        }
        await streamed.stream.listen(null).cancel();
        Uri next;
        try {
          next = current.resolve(location);
        } on FormatException {
          throw const NfeRequestException('Invalid redirect');
        }
        if (!URLStateExtractor.isSupportedUri(next)) {
          throw const NfeRequestException('Unsupported redirect target');
        }
        current = next;
        redirects++;
        continue;
      }

      if (status < 200 || status >= 300) {
        await streamed.stream.listen(null).cancel();
        throw const NfeRequestException(
          'Request returned an unsuccessful status',
        );
      }
      final contentType = streamed.headers['content-type']
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      if (contentType != 'text/html') {
        await streamed.stream.listen(null).cancel();
        throw const NfeRequestException('Unsupported response content type');
      }

      try {
        final bytes = await _withinDeadline(
          _readBounded(streamed.stream, _responseLimit),
          deadline,
        );
        final response = http.Response.bytes(
          bytes,
          status,
          headers: streamed.headers,
          request: streamed.request,
        );
        final realUri = switch (streamed) {
          http.BaseResponseWithUrl(:final url) => url,
          _ => current,
        };
        return HTTPResponse(response: response, realUri: realUri);
      } on _BodyTooLarge {
        throw const NfeRequestException('Response body exceeds the limit');
      } on TimeoutException {
        _closeTransport();
        throw const NfeRequestException('Request timed out');
      } on NfeRequestException {
        rethrow;
      } on Object {
        throw const NfeRequestException('Response could not be read');
      }
    }
  }

  Future<Document> fetchDocumentFromLink(String link) async {
    final response = await get(link);
    return parse(response.body);
  }

  /// Closes the underlying transport and aborts the in-flight request, if any.
  void close() {
    if (_closed) return;
    _closed = true;
    _closeTransport();
  }

  void _closeTransport() {
    if (_transportClosed) return;
    _transportClosed = true;
    _client.close();
  }
}

Duration _boundedTimeout(Duration requested) {
  if (requested <= Duration.zero) {
    throw ArgumentError.value(requested, 'timeout', 'Must be positive');
  }
  return requested > _operationTimeout ? _operationTimeout : requested;
}

int _boundedResponseLimit(int requested) {
  if (requested <= 0) {
    throw ArgumentError.value(
      requested,
      'maxResponseBytes',
      'Must be positive',
    );
  }
  return requested > _maxResponseBytes ? _maxResponseBytes : requested;
}

bool _isRedirect(int status) =>
    status == 301 ||
    status == 302 ||
    status == 303 ||
    status == 307 ||
    status == 308;

Future<T> _withinDeadline<T>(Future<T> future, DateTime deadline) {
  final remaining = deadline.difference(DateTime.now());
  if (remaining <= Duration.zero) {
    throw TimeoutException('deadline elapsed');
  }
  return future.timeout(remaining);
}

Future<Uint8List> _readBounded(
  Stream<List<int>> stream,
  int maxResponseBytes,
) async {
  final builder = BytesBuilder(copy: false);
  var length = 0;
  await for (final chunk in stream) {
    length += chunk.length;
    if (length > maxResponseBytes) throw const _BodyTooLarge();
    builder.add(chunk);
  }
  return builder.takeBytes();
}

class _BodyTooLarge implements Exception {
  const _BodyTooLarge();
}

class HTTPResponse {
  final http.Response response;
  final Uri realUri;

  HTTPResponse({required this.response, required this.realUri});

  String get body => response.body;

  String get data => body;

  int get statusCode => response.statusCode;

  Map<String, String> get headers => response.headers;
}
