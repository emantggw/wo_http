import '../../wo_http.dart';

class WoDataClientDefinition {
  final String name;
  final String baseUrl;
  final bool enableLogging;
  final WoLogger? logger;
  final int maxRetries;
  final bool retryOnlyGet;
  final Set<int> retryableStatusCodes;
  final Duration requestTimeout;
  final WoHttpErrorAdapter errorAdapter;
  final List<WoHttpInterceptor> interceptors;
  final Map<String, String>? defaultHeaders;

  const WoDataClientDefinition({
    required this.name,
    required this.baseUrl,
    this.enableLogging = true,
    this.logger,
    this.maxRetries = 2,
    this.retryOnlyGet = true,
    this.retryableStatusCodes = const <int>{0, 408, 429, 500, 502, 503, 504},
    this.requestTimeout = const Duration(seconds: 30),
    this.errorAdapter = const WoDefaultHttpErrorAdapter(),
    this.interceptors = const <WoHttpInterceptor>[],
    this.defaultHeaders,
  });
}
