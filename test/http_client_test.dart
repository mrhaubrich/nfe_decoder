import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nfe_decoder/decoder/http_client.dart';
import 'package:test/test.dart';

const _start =
    'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=synthetic-fixture';
const _redirect =
    'https://dfe-portal.svrs.rs.gov.br/Dfe/QrCodeNFce?p=synthetic-fixture';

void main() {
  test('follows the enumerated RS portal redirect', () async {
    final fake = _ScriptedClient([
      _Reply(302, headers: {'location': _redirect}),
      _Reply(200, body: '<html><body>synthetic</body></html>'),
    ]);
    final client = HTTPClient(client: fake);

    final response = await client.get(_start);

    expect(response.realUri.host, 'dfe-portal.svrs.rs.gov.br');
    expect(response.realUri.path, '/Dfe/QrCodeNFce');
    expect(fake.requests, hasLength(2));
    expect(response.body, contains('synthetic'));
    client.close();
  });

  test('rejects unsupported initial URL before network I/O', () async {
    final fake = _ScriptedClient([]);
    final client = HTTPClient(client: fake);

    await expectLater(
      client.get('https://sefaz.rs.gov.br.attacker.invalid/NFCE?p=x'),
      throwsA(isA<NfeRequestException>()),
    );
    expect(fake.requests, isEmpty);
    client.close();
  });

  test(
    'rejects a redirect to an unapproved or downgraded destination',
    () async {
      for (final target in [
        'http://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=x',
        'https://127.0.0.1/NFCE/NFCE-COM.aspx?p=x',
        'https://www.sefaz.rs.gov.br.attacker.invalid/NFCE?p=x',
        'https://user@www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?p=x',
      ]) {
        final fake = _ScriptedClient([
          _Reply(302, headers: {'location': target}),
        ]);
        final client = HTTPClient(client: fake);
        await expectLater(
          client.get(_start),
          throwsA(isA<NfeRequestException>()),
        );
        expect(fake.requests, hasLength(1));
        client.close();
      }
    },
  );

  test('rejects non-default ports and unsupported paths', () async {
    final fake = _ScriptedClient([]);
    final client = HTTPClient(client: fake);
    for (final url in [
      'https://www.sefaz.rs.gov.br:8443/NFCE/NFCE-COM.aspx?p=x',
      'https://www.sefaz.rs.gov.br/other?p=x',
      'https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx',
    ]) {
      await expectLater(client.get(url), throwsA(isA<NfeRequestException>()));
    }
    expect(fake.requests, isEmpty);
    client.close();
  });

  test('rejects redirect loops after the documented limit', () async {
    final fake = _ScriptedClient(
      List.generate(4, (_) => _Reply(302, headers: {'location': _start})),
    );
    final client = HTTPClient(client: fake);
    await expectLater(client.get(_start), throwsA(isA<NfeRequestException>()));
    expect(fake.requests, hasLength(4));
    client.close();
  });

  test(
    'cancels a response stream when the redirect URI is malformed',
    () async {
      final cancelled = Completer<void>();
      final controller = StreamController<List<int>>(
        onCancel: cancelled.complete,
      );
      final fake = _ScriptedClient([
        _Reply(
          302,
          headers: {'location': 'http://['},
          stream: controller.stream,
        ),
      ]);
      final client = HTTPClient(client: fake);

      await expectLater(
        client.get(_start),
        throwsA(isA<NfeRequestException>()),
      );
      await cancelled.future;
      client.close();
    },
  );

  test(
    'rejects oversized and unsuccessful responses without leaking details',
    () async {
      final large = _ScriptedClient([_Reply(200, body: '12345')]);
      final client = HTTPClient(client: large, maxResponseBytes: 4);
      await expectLater(
        client.get(_start),
        throwsA(
          isA<NfeRequestException>().having(
            (error) => error.toString(),
            'message',
            isNot(contains('synthetic-fixture')),
          ),
        ),
      );
      client.close();

      final errorResponse = _ScriptedClient([
        _Reply(503, body: 'sensitive response body'),
      ]);
      final errorClient = HTTPClient(client: errorResponse);
      await expectLater(
        errorClient.get(_start),
        throwsA(
          isA<NfeRequestException>().having(
            (error) => error.toString(),
            'message',
            isNot(contains('sensitive')),
          ),
        ),
      );
      errorClient.close();
    },
  );

  test('enforces operation timeout and closes transport', () async {
    final fake = _ScriptedClient.pending();
    final client = HTTPClient(
      client: fake,
      timeout: const Duration(milliseconds: 10),
    );
    await expectLater(client.get(_start), throwsA(isA<NfeRequestException>()));
    expect(fake.closed, isTrue);
    client.close();
  });

  test('requires HTML content type', () async {
    final fake = _ScriptedClient([
      _Reply(200, headers: {'content-type': 'application/json'}),
    ]);
    final client = HTTPClient(client: fake);
    await expectLater(client.get(_start), throwsA(isA<NfeRequestException>()));
    client.close();
  });

  test('rejects non-positive injected limits', () {
    expect(() => HTTPClient(timeout: Duration.zero), throwsArgumentError);
    expect(() => HTTPClient(maxResponseBytes: 0), throwsArgumentError);
  });
}

class _Reply {
  final int status;
  final String body;
  final Map<String, String> headers;
  final Stream<List<int>>? stream;

  const _Reply(
    this.status, {
    this.body = '',
    this.headers = const {'content-type': 'text/html; charset=utf-8'},
    this.stream,
  });
}

class _ScriptedClient extends http.BaseClient {
  final List<_Reply> replies;
  final Completer<http.StreamedResponse>? pendingResponse;
  final List<Uri> requests = [];
  bool closed = false;

  _ScriptedClient(this.replies) : pendingResponse = null;

  _ScriptedClient.pending()
    : replies = const [],
      pendingResponse = Completer<http.StreamedResponse>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request.url);
    if (pendingResponse case final pending?) return pending.future;
    final reply = replies.removeAt(0);
    return Future.value(
      http.StreamedResponse(
        reply.stream ?? Stream.value(utf8.encode(reply.body)),
        reply.status,
        request: request,
        headers: reply.headers,
      ),
    );
  }

  @override
  void close() {
    closed = true;
    if (pendingResponse case final pending? when !pending.isCompleted) {
      pending.completeError(StateError('closed'));
    }
  }
}
