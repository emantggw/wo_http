import '../contracts/wo_http_interceptor.dart';
import '../contracts/wo_logger.dart';
import '../models/wo_auth_strategy.dart';
import '../models/wo_http_request.dart';
import '../models/wo_http_response.dart';
import 'wo_default_logger.dart';

class WoDefaultAuthInterceptor extends WoHttpInterceptor {
  final WoAuthStrategy authStrategy;
  final WoLogger logger;
  final Set<String> excludedExactPaths;
  final Set<String> excludedPathPrefixes;
  final String authorizationHeaderName;
  final String retryMetadataKey;
  final String skipAuthMetadataKey;
  final String Function(String accessToken, WoHttpRequest request)?
      authorizationHeaderValueBuilder;

  Future<String?>? _refreshInFlight;

  WoDefaultAuthInterceptor({
    required this.authStrategy,
    WoLogger? logger,
    this.excludedExactPaths = const <String>{},
    this.excludedPathPrefixes = const <String>{},
    this.authorizationHeaderName = 'Authorization',
    this.retryMetadataKey = 'x-refresh-retried',
    this.skipAuthMetadataKey = 'x-skip-auth',
    this.authorizationHeaderValueBuilder,
  }) : logger = logger ?? WoDefaultLogger();

  @override
  Future<WoHttpRequest> onRequest(WoHttpRequest request) async {
    if (_shouldSkipAuth(request)) {
      final headers = Map<String, String>.from(request.headers)
        ..remove(authorizationHeaderName);
      return request.copyWith(headers: headers);
    }

    final accessToken = await authStrategy.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return request;
    }

    final headers = Map<String, String>.from(request.headers)
      ..[authorizationHeaderName] =
          _buildAuthorizationHeaderValue(accessToken, request);
    return request.copyWith(headers: headers);
  }

  @override
  Future<WoHttpResponse> onError(WoHttpErrorContext context) async {
    if (context.response.statusCode != 401) {
      return context.response;
    }

    if (_shouldSkipAuth(context.request)) {
      logger.log(
        'AUTH REFRESH',
        'Skipping refresh for excluded request ${context.request.path}',
      );
      return context.response;
    }

    if (context.request.metadata[retryMetadataKey] == true) {
      logger.warning(
        'AUTH REFRESH',
        'Refresh already attempted for ${context.request.path}',
      );
      return context.response;
    }

    final newAccessToken = await _refreshAccessToken(context);
    if (newAccessToken == null || newAccessToken.isEmpty) {
      logger.warning(
        'AUTH REFRESH',
        'Refresh failed for ${context.request.path}',
      );
      return context.response;
    }

    final retryHeaders = Map<String, String>.from(context.request.headers)
      ..[authorizationHeaderName] = _buildAuthorizationHeaderValue(
        newAccessToken,
        context.request,
      );

    final retryMetadata = Map<String, dynamic>.from(context.request.metadata)
      ..[retryMetadataKey] = true;

    final retryRequest = context.request.copyWith(
      headers: retryHeaders,
      metadata: retryMetadata,
    );

    logger.info(
      'AUTH REFRESH',
      'Retrying ${retryRequest.method.name.toUpperCase()} ${retryRequest.path} with refreshed token ${_maskToken(newAccessToken)}',
    );

    return context.retry(retryRequest);
  }

  @override
  Future<WoHttpResponse> onResponse(WoHttpResponse response) async => response;

  Future<String?> _refreshAccessToken(WoHttpErrorContext context) async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture =
        authStrategy.refreshAccessToken().catchError((Object error) {
      logger.error('AUTH REFRESH', 'Refresh error: $error');
      return null;
    });

    _refreshInFlight = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_refreshInFlight, refreshFuture)) {
        _refreshInFlight = null;
      }
    }
  }

  bool _shouldSkipAuth(WoHttpRequest request) {
    if (request.metadata[skipAuthMetadataKey] == true) {
      return true;
    }

    if (excludedExactPaths.contains(request.path)) {
      return true;
    }

    for (final prefix in excludedPathPrefixes) {
      if (request.path.startsWith(prefix)) {
        return true;
      }
    }

    return false;
  }

  String _buildAuthorizationHeaderValue(
    String accessToken,
    WoHttpRequest request,
  ) {
    final builder = authorizationHeaderValueBuilder;
    if (builder != null) {
      return builder(accessToken, request);
    }
    return 'Bearer $accessToken';
  }

  String _maskToken(String token) {
    if (token.isEmpty) return '<empty>';
    if (token.length <= 10) return '***';
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}

typedef WoDefaultAuthIntercptor = WoDefaultAuthInterceptor;
