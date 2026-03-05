import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../wo_http.dart';

class WoDefaultLogger implements WoLogger {
  static Logger? _logger;
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _violet = '\x1B[35m';

  static Logger get _log {
    _logger ??= Logger(
      filter: _WoLogFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      output: _WoLogOutput(),
    );
    return _logger!;
  }

  @override
  void log(String tag, String message) {
    _log.t(_compose(
      tag: tag,
      message: message,
      color: '$_bold$_violet',
      level: 'LOG',
    ));
  }

  @override
  void info(String tag, String message) {
    _log.i(_compose(
      tag: tag,
      message: message,
      color: '$_bold$_green',
      level: 'INFO',
    ));
  }

  @override
  void warning(String tag, String message) {
    _log.w(_compose(
      tag: tag,
      message: message,
      color: '$_bold$_yellow',
      level: 'WARN',
    ));
  }

  @override
  void error(String tag, String message) {
    _log.e(_compose(
      tag: tag,
      message: message,
      color: '$_bold$_red',
      level: 'ERROR',
    ));
  }

  String _compose({
    required String tag,
    required String message,
    required String color,
    required String level,
  }) {
    return '$color[$level] $tag$_reset\n$color$message$_reset';
  }
}

class _WoLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => !kReleaseMode;
}

class _WoLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      log(line);
    }
  }
}
