import '../../wo_http.dart';

class WoDataClientDefinition {
  final String name;
  final String baseUrl;
  final bool enableLogging;
  final WoLogger? logger;
  final int maxRetries;
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
    this.requestTimeout = const Duration(seconds: 30),
    this.errorAdapter = const WoDefaultHttpErrorAdapter(),
    this.interceptors = const <WoHttpInterceptor>[],
    this.defaultHeaders,
  });
}
