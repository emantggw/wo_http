/// Contract for converting backend error payloads into a normalized map.
abstract class WoHttpErrorAdapter {
  /// Returns a normalized error object, usually containing a `message` field.
  String? adaptError(dynamic error);
}
