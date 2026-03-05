/// Contract used by [WoDefaultAuthInterceptor] to resolve/refresh auth tokens.
abstract class WoAuthStrategy {
  /// Protected constructor to enforce subclassing.
  const WoAuthStrategy._();

  /// Returns the current access token to be attached on outgoing requests.
  Future<String?> readAccessToken();

  /// Refreshes and returns a new access token after auth failure.
  Future<String?> refreshAccessToken();
}
