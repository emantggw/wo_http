import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../wo_http.dart';

class WoDefaultHttpLoggingInterceptor extends WoHttpInterceptor {
  final bool enabled;
  final WoLogger logger;
  final String _tag = 'WoDefaultHttpLoggingInterceptor';

  WoDefaultHttpLoggingInterceptor({
    this.enabled = true,
    WoLogger? logger,
  }) : logger = logger ?? WoDefaultLogger();

  @override
  Future<WoHttpRequest> onRequest(WoHttpRequest request) async {
    if (!enabled || !kDebugMode) return request;

    logger.log(_tag, '${request.method.value} ${request.uri}');
    if (request.headers.isNotEmpty) {
      logger.log('HTTP Request Headers', request.headers.toString());
    }
    if (request.formFields != null && request.formFields!.isNotEmpty) {
      logger.log('HTTP Request Fields', request.formFields.toString());
    }
    if (request.body != null) {
      logger.log('HTTP Request Body', _safeEncode(request.body));
    }

    return request;
  }

  @override
  Future<WoHttpResponse> onResponse(WoHttpResponse response) async {
    if (!enabled || !kDebugMode) return response;

    logger.info('HTTP Response',
        '${response.statusCode} ${response.request.method.value} ${response.request.path}');
    if (response.body != null) {
      logger.info('HTTP Response Body', _safeEncode(response.body));
    }
    return response;
  }

  @override
  Future<WoHttpResponse> onError(WoHttpErrorContext context) async {
    if (!enabled || !kDebugMode) return context.response;

    logger.error('HTTP Error',
        '${context.response.statusCode} ${context.request.method.value} ${context.request.path}');
    logger.error('HTTP Error Body', _safeEncode(context.response.body));
    return context.response;
  }

  String _safeEncode(dynamic value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value?.toString() ?? 'null';
    }
  }
}
