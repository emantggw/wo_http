/// Logging contract used by interceptors and clients.
abstract class WoLogger {
  /// Writes a generic log event.
  void log(String tag, String message);

  /// Writes an informational event.
  void info(String tag, String message);

  /// Writes a warning event.
  void warning(String tag, String message);

  /// Writes an error event.
  void error(String tag, String message);
}
