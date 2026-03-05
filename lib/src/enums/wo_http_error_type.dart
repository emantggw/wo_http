enum WoHttpErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  server,
  unknown,
}

extension HttpErrorTypeByStatus on WoHttpErrorType {
  static WoHttpErrorType fromStatusCode(int statusCode) {
    if (statusCode == 401) return WoHttpErrorType.unauthorized;
    if (statusCode == 403) return WoHttpErrorType.forbidden;
    if (statusCode == 404) return WoHttpErrorType.notFound;
    if (statusCode >= 500) return WoHttpErrorType.server;
    return WoHttpErrorType.unknown;
  }
}
