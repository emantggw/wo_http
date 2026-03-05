import '../../wo_http.dart';

/// Standard failure payload returned in [WoResult.error].
class WoDataFailure {
  /// Human-readable error message suitable for UI.
  final String message;

  /// Normalized error category derived from HTTP status/exception.
  final WoHttpErrorType? errorType;

  /// Raw exception or source object when available.
  final Object? cause;

  const WoDataFailure(this.message, {this.errorType, this.cause});

  @override
  String toString() =>
      'WoDataFailure(message: $message, errorType: $errorType, cause: $cause)';
}
