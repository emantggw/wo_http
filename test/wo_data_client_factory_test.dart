import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wo_http/src/opinionated/wo_default_http_logging_interceptor.dart';
import 'package:wo_http/wo_http.dart';

void main() {
  group('WoDataClientFactory', () {
    test('does not run request or response logging when logging is disabled',
        () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final serverDone = server.listen((request) {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write('{"ok":true}')
          ..close();
      }).asFuture<void>();

      final logger = _CollectingLogger();
      final factory = WoDataClientFactory.fromDefinitions([
        WoDataClientDefinition(
          name: 'test',
          baseUrl: 'http://${server.address.host}:${server.port}',
          enableLogging: false,
          interceptors: [
            WoDefaultHttpLoggingInterceptor(logger: logger),
          ],
        ),
      ]);

      try {
        await factory.client('test').get('/ping');
      } finally {
        factory.closeAll();
        await server.close(force: true);
        await serverDone;
      }

      expect(logger.entries, isEmpty);
    });
  });
}

class _CollectingLogger implements WoLogger {
  final entries = <String>[];

  @override
  void error(String tag, String message) => entries.add('error $tag $message');

  @override
  void info(String tag, String message) => entries.add('info $tag $message');

  @override
  void log(String tag, String message) => entries.add('log $tag $message');

  @override
  void warning(String tag, String message) =>
      entries.add('warning $tag $message');
}
