import '../../wo_http.dart';

class WoDefaultRetryHttpInterceptor extends WoHttpInterceptor {
  final int maxRetries;
  final Set<int> retryableStatusCodes;
  final String retryMetadataKey;

  WoDefaultRetryHttpInterceptor({
    this.maxRetries = 2,
    this.retryableStatusCodes = const <int>{0, 408, 429, 500, 502, 503, 504},
    this.retryMetadataKey = 'x-retry-count',
  });

  @override
  Future<WoHttpResponse> onError(WoHttpErrorContext context) async {
    final statusCode = context.response.statusCode;
    if (!retryableStatusCodes.contains(statusCode)) {
      return context.response;
    }

    final retryCount =
        (context.request.metadata[retryMetadataKey] as int?) ?? 0;
    if (retryCount >= maxRetries) {
      return context.response;
    }

    final newMetadata = Map<String, dynamic>.from(context.request.metadata)
      ..[retryMetadataKey] = retryCount + 1;

    final retryRequest = context.request.copyWith(metadata: newMetadata);
    return context.retry(retryRequest);
  }
}
