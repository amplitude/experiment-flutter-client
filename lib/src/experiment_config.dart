import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/constants.dart';
import 'package:amplitude_experiment/src/providers.dart';

abstract class ExperimentConfigDefaults {
  static const LogLevel logLevel = LogLevel.warn;
  static const String instanceName = Constants.instanceName;
  static const Source source = Source.localStorage;
  static const ServerZone serverZone = ServerZone.us;
  static const String serverUrl = Constants.serverUrl;
  static const String flagsServerUrl = Constants.flagsServerUrl;
  static const int fetchTimeoutMillis = Constants.fetchTimeoutMillis;
  static const bool retryFetchOnFailure = true;
  static const bool automaticExposureTracking = true;
  static const bool fetchOnStart = true;
  static const bool pollOnStart = false;
  static const bool automaticFetchOnAmplitudeIdentityChange = false;
  static const Map<String, Variant> initialVariants = {};
}

class ExperimentConfig {
  final String instanceName;
  final LogLevel logLevel;
  final Variant? fallbackVariant;
  final String? initialFlags;
  final Map<String, Variant> initialVariants;
  final Source source;
  final ServerZone serverZone;
  final String serverUrl;
  final String flagsServerUrl;
  final int fetchTimeoutMillis;
  final bool retryFetchOnFailure;
  final bool automaticExposureTracking;
  final bool fetchOnStart;
  final bool pollOnStart;
  final bool automaticFetchOnAmplitudeIdentityChange;
  final ExposureTrackingProvider? trackingProvider;
  final UserProvider? userProvider;
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

  ExperimentConfigData get pigeonConfig {
    return ExperimentConfigData(
      instanceName: instanceName,
      logLevel: logLevel,
      fallbackVariant: fallbackVariant ?? Variant(),
      initialFlags: initialFlags,
      initialVariants: initialVariants,
      source: source,
      serverZone: serverZone,
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
      hasUserProvider: userProvider != null,
    );
  }
}
