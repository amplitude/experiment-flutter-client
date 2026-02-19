/// Controls the verbosity of SDK logging output.
enum LogLevel {
  /// No logging.
  none,

  /// Errors only.
  error,

  /// Errors and warnings.
  warn,

  /// Errors, warnings, and informational messages.
  info,

  /// All messages including debug output.
  debug,
}

/// Determines where the SDK reads flag and variant data from.
enum Source {
  /// Read from the local storage cache.
  localStorage,

  /// Read from the initial variants provided in [ExperimentConfig].
  initialVariants,
}

/// The Amplitude data center region.
enum ServerZone { us, eu }
