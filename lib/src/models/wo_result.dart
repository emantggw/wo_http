import '../../wo_http.dart';

/// Result wrapper returned by [WoHttpClient] methods.
class WoResult<T> {
  /// Parsed success payload when [isSuccess] is true.
  final T? data;

  /// Reserved/legacy response field kept for compatibility.
  final T? onResponse;

  /// HTTP status code (if available).
  final int? statusCode;

  /// Failure payload when request fails.
  final WoDataFailure? failure;

  const WoResult._({this.data, this.onResponse, this.statusCode, this.failure});

  factory WoResult.success(T data, {int? statusCode}) =>
      WoResult._(data: data, statusCode: statusCode);

  factory WoResult.error(WoDataFailure failure, {int? statusCode}) =>
      WoResult._(failure: failure, statusCode: statusCode);

  factory WoResult.fromHttpResponse(
    WoHttpResponse response, {
    T Function(dynamic raw)? parser,
    required WoHttpErrorAdapter errorAdapter,
  }) {
    if (response.isSuccess) {
      final parsed =
          parser != null ? parser(response.body) : response.body as T;

      return WoResult.success(parsed, statusCode: response.statusCode);
    }

    final shouldAdaptErrorBody = response.statusCode < 500;
    final errorMessage = shouldAdaptErrorBody
        ? errorAdapter.adaptError(response.body) ?? _unknownErrorMessage
        : _serverErrorMessage;

    return WoResult.error(
      WoDataFailure(
        errorMessage,
        errorType: response.errorType,
      ),
      statusCode: response.statusCode,
    );
  }

  /// True when [failure] is null.
  bool get isSuccess => failure == null;

  static const String _unknownErrorMessage = 'An unknown error occurred.';
  static const String _serverErrorMessage =
      'Something went wrong, please try again later.';
}
