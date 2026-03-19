import '../enums/wo_http_error_type.dart';
import 'wo_http_request.dart';
import 'dart:async';
import 'dart:io';

/// Internal normalized HTTP response model.
class WoHttpResponse {
  /// HTTP status code. `0` is used for transport-level failures.
  final int statusCode;

  /// Decoded body (JSON map/list/string/null).
  final dynamic body;

  /// Response headers.
  final Map<String, String> headers;

  /// Original request that produced this response.
  final WoHttpRequest request;

  /// Optional low-level exception captured by the client.
  final Object? exception;

  const WoHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.request,
    this.exception,
  });

  /// True when [statusCode] is in the 2xx range.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Best-effort mapping from status/exception to [WoHttpErrorType].
  WoHttpErrorType get errorType {
    if (exception is TimeoutException) return WoHttpErrorType.timeout;
    if (exception is SocketException) return WoHttpErrorType.network;
    if (statusCode == 0) return WoHttpErrorType.network;
    return HttpErrorTypeByStatus.fromStatusCode(statusCode);
  }
}
