import 'package:flutter/foundation.dart';

/// Professional logging system with
///  [security features and flexible configuration]
class CustomLogs {
  static final Map<LogLevel, String> _logStyles = {
    LogLevel.debug: '\x1B[38;5;243m',
    LogLevel.info: '\x1B[38;5;51m',
    LogLevel.success: '\x1B[38;5;40m',
    LogLevel.warning: '\x1B[38;5;226m',
    LogLevel.error: '\x1B[38;5;196m',
    LogLevel.verbose: '\x1B[38;5;129m',
  };

  static final Map<LogLevel, String> _logEmojis = {
    LogLevel.debug: '🐛',
    LogLevel.info: 'ℹ️',
    LogLevel.success: '✅',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
    LogLevel.verbose: '📢',
  };

  /// Sensitive data patterns to redact (case-insensitive)
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'password["\s:=]+[^\s,}"]+', caseSensitive: false),
    RegExp(r'token["\s:=]+[^\s,}"]+', caseSensitive: false),
    RegExp(r'api[_-]?key["\s:=]+[^\s,}"]+', caseSensitive: false),
    RegExp(r'secret["\s:=]+[^\s,}"]+', caseSensitive: false),
    RegExp(r'authorization["\s:=]+[^\s,}"]+', caseSensitive: false),
    RegExp(r'bearer\s+[^\s,}"]+', caseSensitive: false),
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
    RegExp(r'\b(?:\d{4}[-\s]?){3}\d{4}\b'),
  ];

  /// Configuration for logging behavior
  static LogConfig _config = LogConfig();

  /// Initialize logger with custom configuration
  static void configure(LogConfig config) {
    _config = config;
  }

  /// Main logging method with security features
  static void log(
    String message, {
    String tag = 'APP',
    LogLevel level = LogLevel.info,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    // Check if logging is enabled for this level
    if (!_shouldLog(level)) return;

    final time = DateTime.now().toIso8601String().substring(11, 23);
    final style = _logStyles[level]!;
    final emoji = _logEmojis[level]!;

    // Sanitize message and error
    final sanitizedMessage = _sanitize(message);
    final sanitizedError = error != null ? _sanitize(error.toString()) : null;

    final buffer = StringBuffer()
      ..write('$style┌─ ${emoji.padRight(3)} [$tag] ')
      ..write('\x1B[0m$style$time')
      ..write('\x1B[0m\n')
      ..write('$style├ \x1B[0m$style$sanitizedMessage\x1B[0m');

    // Add metadata if present
    if (metadata != null && metadata.isNotEmpty && _config.includeMetadata) {
      final sanitizedMetadata = _sanitizeMap(metadata);
      buffer.write('\n$style├─ Metadata: \x1B[0;96m$sanitizedMetadata\x1B[0m');
    }

    // Add error information
    if (sanitizedError != null) {
      final errorStr = truncateLongLog(
        sanitizedError,
        maxLength: _config.maxLogLength,
      );
      buffer.write('\n$style├─ Error: \x1B[0;91m$errorStr\x1B[0m');
    }

    // Add stack trace if available and enabled
    if (stackTrace != null && _config.includeStackTrace) {
      final stackStr = _formatStackTrace(stackTrace);
      buffer.write('\n$style├─ Stack Trace:\x1B[0;90m\n$stackStr\x1B[0m');
    }

    buffer.write('\n$style└───\x1B[0m');

    // Output log
    debugPrint(buffer.toString());

    // Optional: Send to external logging service
    if (_config.onLog != null) {
      _config.onLog!(
        LogEntry(
          level: level,
          tag: tag,
          message: sanitizedMessage,
          error: sanitizedError,
          stackTrace: stackTrace,
          metadata: metadata,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Check if logging should occur based on configuration
  static bool _shouldLog(LogLevel level) {
    // In release mode, only log warnings and errors by default
    if (kReleaseMode && !_config.enableInRelease) {
      return level == LogLevel.warning || level == LogLevel.error;
    }

    // Check minimum log level
    return level.index >= _config.minLevel.index;
  }

  /// Sanitize sensitive data from strings
  static String _sanitize(String input) {
    if (!_config.sanitizeSensitiveData) return input;

    String sanitized = input;
    for (final pattern in _sensitivePatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) =>
            '${match.group(0)?.split(RegExp(r'[:=\s]')).first ?? ''}${_config.redactedPlaceholder}',
      );
    }

    // Additional custom patterns
    for (final pattern in _config.customSensitivePatterns) {
      sanitized = sanitized.replaceAll(pattern, _config.redactedPlaceholder);
    }

    return sanitized;
  }

  /// Sanitize map data recursively
  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    if (!_config.sanitizeSensitiveData) return data;

    return data.map((key, value) {
      // Check if key contains sensitive words
      final lowerKey = key.toLowerCase();
      final isSensitiveKey = [
        'password',
        'token',
        'secret',
        'key',
        'auth',
      ].any((word) => lowerKey.contains(word));

      if (isSensitiveKey) {
        return MapEntry(key, _config.redactedPlaceholder);
      }

      if (value is String) {
        return MapEntry(key, _sanitize(value));
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeMap(value));
      }

      return MapEntry(key, value);
    });
  }

  /// Format stack trace for better readability
  static String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    final relevantLines = lines.take(_config.maxStackTraceLines).toList();
    return truncateLongLog(
      relevantLines.join('\n'),
      maxLength: _config.maxLogLength,
    );
  }

  /// Truncate long logs to prevent overflow
  static String truncateLongLog(String? log, {int? maxLength}) {
    if (log == null) return '';
    final limit = maxLength ?? _config.maxLogLength;
    return log.length > limit
        ? '${log.substring(0, limit)}...[truncated]'
        : log;
  }

  // Shortcut methods
  static void debug(
    String message, {
    String tag = 'APP',
    Map<String, dynamic>? metadata,
  }) => log(message, tag: tag, level: LogLevel.debug, metadata: metadata);

  static void info(
    String message, {
    String tag = 'APP',
    Map<String, dynamic>? metadata,
  }) => log(message, tag: tag, level: LogLevel.info, metadata: metadata);

  static void success(
    String message, {
    String tag = 'APP',
    Map<String, dynamic>? metadata,
  }) => log(message, tag: tag, level: LogLevel.success, metadata: metadata);

  static void warning(
    String message, {
    String tag = 'APP',
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => log(
    message,
    tag: tag,
    level: LogLevel.warning,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  static void error(
    String message, {
    String tag = 'APP',
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) => log(
    message,
    tag: tag,
    level: LogLevel.error,
    error: error,
    stackTrace: stackTrace,
    metadata: metadata,
  );

  static void verbose(
    String message, {
    String tag = 'APP',
    Map<String, dynamic>? metadata,
  }) => log(message, tag: tag, level: LogLevel.verbose, metadata: metadata);

  /// Log API calls with sanitization
  static void api(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    String tag = 'API',
  }) {
    final sanitizedHeaders = headers != null ? _sanitizeMap(headers) : null;
    final sanitizedBody = body is String ? _sanitize(body) : body;

    log(
      '$method $endpoint',
      tag: tag,
      level: statusCode != null && statusCode >= 400
          ? LogLevel.error
          : LogLevel.info,
      metadata: {
        if (sanitizedHeaders != null) 'headers': sanitizedHeaders,
        if (sanitizedBody != null) 'body': sanitizedBody,
        if (statusCode != null) 'status': statusCode,
      },
    );
  }
}

/// Log level enumeration
enum LogLevel { debug, info, success, warning, error, verbose }

/// Configuration class for logger
class LogConfig {
  /// Enable logging in release mode
  final bool enableInRelease;

  /// Minimum log level to display
  final LogLevel minLevel;

  /// Sanitize sensitive data (passwords, tokens, etc.)
  final bool sanitizeSensitiveData;

  /// Placeholder for redacted sensitive data
  final String redactedPlaceholder;

  /// Include stack traces in logs
  final bool includeStackTrace;

  /// Maximum number of stack trace lines to show
  final int maxStackTraceLines;

  /// Maximum log message length before truncation
  final int maxLogLength;

  /// Include metadata in logs
  final bool includeMetadata;

  /// Custom sensitive data patterns to redact
  final List<RegExp> customSensitivePatterns;

  /// Callback for external logging (Firebase, Sentry, etc.)
  final void Function(LogEntry entry)? onLog;

  LogConfig({
    this.enableInRelease = false,
    this.minLevel = LogLevel.debug,
    this.sanitizeSensitiveData = true,
    this.redactedPlaceholder = '[REDACTED]',
    this.includeStackTrace = true,
    this.maxStackTraceLines = 10,
    this.maxLogLength = 2000,
    this.includeMetadata = true,
    this.customSensitivePatterns = const [],
    this.onLog,
  });
}

/// Log entry model for external logging services
class LogEntry {
  final LogLevel level;
  final String tag;
  final String message;
  final String? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
    this.metadata,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'tag': tag,
    'message': message,
    if (error != null) 'error': error,
    if (metadata != null) 'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
  };
}
