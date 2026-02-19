import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart'
    as pigeon;
import 'package:amplitude_experiment/src/constants.dart';
import 'package:amplitude_experiment/src/providers.dart';
import 'package:amplitude_experiment/src/models/variant.dart';
import 'package:amplitude_experiment/src/models/enums.dart';
import 'package:amplitude_experiment/src/pigeon_mappers.dart';

/// Default values for [ExperimentConfig] fields.
abstract class ExperimentConfigDefaults {
  /// Default log level: [LogLevel.warn].
  static const LogLevel logLevel = LogLevel.warn;

  /// Default instance name.
  static const String instanceName = Constants.instanceName;

  /// Default source: [Source.localStorage].
  static const Source source = Source.localStorage;

  /// Default server zone: [ServerZone.us].
  static const ServerZone serverZone = ServerZone.us;

  /// Default server URL.
  static const String serverUrl = Constants.serverUrl;

  /// Default flags server URL.
  static const String flagsServerUrl = Constants.flagsServerUrl;

  /// Default fetch timeout in milliseconds.
  static const int fetchTimeoutMillis = Constants.fetchTimeoutMillis;

  /// Whether to retry fetch on failure by default.
  static const bool retryFetchOnFailure = true;

  /// Whether automatic exposure tracking is enabled by default.
  static const bool automaticExposureTracking = true;

  /// Whether to fetch flags on start by default.
  static const bool fetchOnStart = true;

  /// Whether to poll on start by default.
  static const bool pollOnStart = false;

  /// Whether to automatically fetch on Amplitude identity change by default.
  static const bool automaticFetchOnAmplitudeIdentityChange = false;

  /// Default initial variants (empty).
  static const Map<String, Variant> initialVariants = {};
}

/// Configuration for the Amplitude Experiment SDK client.
///
/// Pass to [Experiment.initialize] or [Experiment.initializeWithAmplitude]
/// to customize SDK behavior. All fields have sensible defaults defined
/// in [ExperimentConfigDefaults].
class ExperimentConfig {
  /// The name for this client instance, used to distinguish multiple clients.
  final String instanceName;

  /// The log verbosity level.
  final LogLevel logLevel;

  /// The fallback variant returned when a flag has no assigned value.
  final Variant? fallbackVariant;

  /// JSON string of initial flag configurations to use before fetching.
  final String? initialFlags;

  /// Initial variant assignments, keyed by flag key.
  final Map<String, Variant> initialVariants;

  /// Where to read flag data from: local storage or initial variants.
  final Source source;

  /// The Amplitude data center region.
  final ServerZone serverZone;

  /// The server URL for remote evaluation.
  final String serverUrl;

  /// The server URL for local evaluation flag data.
  final String flagsServerUrl;

  /// The fetch timeout in milliseconds.
  final int fetchTimeoutMillis;

  /// Whether to retry fetch requests on failure.
  final bool retryFetchOnFailure;

  /// Whether to automatically track exposures when [ExperimentClient.variant]
  /// is called.
  final bool automaticExposureTracking;

  /// Whether to fetch flags when [ExperimentClient.start] is called.
  final bool fetchOnStart;

  /// Whether to start polling for flag updates on start.
  final bool pollOnStart;

  /// Whether to automatically re-fetch flags when the Amplitude identity
  /// changes.
  final bool automaticFetchOnAmplitudeIdentityChange;

  /// The exposure tracking provider for receiving exposure events.
  final ExposureTrackingProvider? trackingProvider;

  /// The user provider for automatic user context resolution.
  final UserProvider? userProvider;

  /// Creates an [ExperimentConfig] with optional overrides.
  ExperimentConfig({
    this.instanceName = ExperimentConfigDefaults.instanceName,
    this.logLevel = ExperimentConfigDefaults.logLevel,
    this.fallbackVariant,
    this.initialFlags,
    this.initialVariants = ExperimentConfigDefaults.initialVariants,
    this.source = ExperimentConfigDefaults.source,
    this.serverZone = ExperimentConfigDefaults.serverZone,
    this.serverUrl = ExperimentConfigDefaults.serverUrl,
    this.flagsServerUrl = ExperimentConfigDefaults.flagsServerUrl,
    this.fetchTimeoutMillis = ExperimentConfigDefaults.fetchTimeoutMillis,
    this.retryFetchOnFailure = ExperimentConfigDefaults.retryFetchOnFailure,
    this.automaticExposureTracking =
        ExperimentConfigDefaults.automaticExposureTracking,
    this.fetchOnStart = ExperimentConfigDefaults.fetchOnStart,
    this.pollOnStart = ExperimentConfigDefaults.pollOnStart,
    this.automaticFetchOnAmplitudeIdentityChange =
        ExperimentConfigDefaults.automaticFetchOnAmplitudeIdentityChange,
    this.trackingProvider,
    this.userProvider,
  });

  pigeon.ExperimentConfigData get pigeonConfig {
    return pigeon.ExperimentConfigData(
      instanceName: instanceName,
      logLevel: logLevelToPigeon(logLevel),
      fallbackVariant: fallbackVariant?.toPigeon() ?? pigeon.Variant(),
      initialFlags: initialFlags,
      initialVariants:
          initialVariants.map((k, v) => MapEntry(k, v.toPigeon())),
      source: sourceToPigeon(source),
      serverZone: serverZoneToPigeon(serverZone),
      serverUrl: serverUrl,
      flagsServerUrl: flagsServerUrl,
      fetchTimeoutMillis: fetchTimeoutMillis,
      retryFetchOnFailure: retryFetchOnFailure,
      automaticExposureTracking: automaticExposureTracking,
      fetchOnStart: fetchOnStart,
      pollOnStart: pollOnStart,
      automaticFetchOnAmplitudeIdentityChange:
          automaticFetchOnAmplitudeIdentityChange,
      hasTrackingProvider: trackingProvider != null,
    );
  }
}
