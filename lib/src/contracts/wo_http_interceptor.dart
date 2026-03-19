import '../../wo_http.dart';

/// Callback used by interceptors to retry a request.
typedef RetryRequest = Future<WoHttpResponse> Function(WoHttpRequest request);

/// Context passed to `onError`, including the failed request and retry helper.
class WoHttpErrorContext {
  /// Request that produced the current error response.
  final WoHttpRequest request;

  /// Response produced by the client before retry interception.
  final WoHttpResponse response;

  /// Function to re-run the request, typically after mutation.
  final RetryRequest retry;

  const WoHttpErrorContext({
    required this.request,
    required this.response,
    required this.retry,
  });
}

/// Interceptor contract for request/response/error pipeline hooks.
abstract class WoHttpInterceptor {
  /// Called before request is sent. Return modified request if needed.
  Future<WoHttpRequest> onRequest(WoHttpRequest request) async => request;

  /// Called for successful responses (2xx by default client behavior).
  Future<WoHttpResponse> onResponse(WoHttpResponse response) async => response;

  /// Called for non-success responses; may return retried response.
  Future<WoHttpResponse> onError(WoHttpErrorContext context) async =>
      context.response;
}
