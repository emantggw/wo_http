import '../../wo_http.dart';

class WoDefaultHttpErrorAdapter implements WoHttpErrorAdapter {
  const WoDefaultHttpErrorAdapter();

  @override
  String? adaptError(dynamic errorBody) {
    if (errorBody == null) return _fallback;

    if (errorBody is String && errorBody.trim().isNotEmpty) {
      return errorBody;
    }

    if (errorBody is Map<String, dynamic>) {
      return _extractFromMap(errorBody);
    }

    return _fallback;
  }

  String _extractFromMap(Map<String, dynamic> map) {
    const keys = ['message', 'detail', 'error', 'msg', 'description'];

    for (final key in keys) {
      final value = map[key];

      if (value is String && value.isNotEmpty) {
        return value;
      }

      if (value is Map<String, dynamic>) {
        return _extractFromMap(value);
      }
    }

    return _fallback;
  }

  String get _fallback => 'Something went wrong, please try again later.';
}
