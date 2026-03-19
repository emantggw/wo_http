import '../../wo_http.dart';
import 'wo_default_http_logging_interceptor.dart';

class WoDataClientFactory {
  final Map<String, WoHttpClient> _clients;

  WoDataClientFactory._(this._clients);

  factory WoDataClientFactory.fromDefinitions(
    List<WoDataClientDefinition> definitions,
  ) {
    final clients = <String, WoHttpClient>{};

    for (final definition in definitions) {
      if (clients.containsKey(definition.name)) {
        throw ArgumentError(
          'Duplicate client name: ${definition.name}. Each client name must be unique.',
        );
      }

      final httpClient = _createClient(definition: definition);

      clients[definition.name] = httpClient;
    }

    return WoDataClientFactory._(clients);
  }

  WoHttpClient client(String name) {
    final resolved = _clients[name];
    if (resolved == null) {
      throw StateError('Client "$name" is not registered.');
    }
    return resolved;
  }

  bool hasClient(String name) => _clients.containsKey(name);

  Map<String, WoHttpClient> get all => Map.unmodifiable(_clients);

  void closeAll() {
    for (final client in _clients.values) {
      client.close();
    }
  }

  static WoHttpClient _createClient({
    required WoDataClientDefinition definition,
  }) {
    final resolvedLogger = definition.logger ?? WoDefaultLogger();
    final interceptors = <WoHttpInterceptor>[];

    if (definition.enableLogging) {
      interceptors.add(WoDefaultHttpLoggingInterceptor(logger: resolvedLogger));
    }

    interceptors
        .add(WoDefaultRetryHttpInterceptor(maxRetries: definition.maxRetries));

    interceptors.addAll(definition.interceptors);

    return WoDefaultHttpApiClient(
      baseUrl: definition.baseUrl,
      interceptors: interceptors,
      defaultHeaders: definition.defaultHeaders,
      requestTimeout: definition.requestTimeout,
      errorAdapter: definition.errorAdapter,
    );
  }
}
