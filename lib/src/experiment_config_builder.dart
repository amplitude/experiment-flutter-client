import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/constants.dart';

abstract class ExperimentConfigDefaults {
  static const LogLevel logLevel = LogLevel.warn;
  static const String instanceName = r'$default_instance';
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

  static Variant get fallbackVariant => Variant();
  static Map<String, Variant> get initialVariants => const {};
}

ExperimentConfig createExperimentConfig({
  LogLevel? logLevel,
  String? instanceName,
  Variant? fallbackVariant,
  String? initialFlags,
  Map<String, Variant>? initialVariants,
  Source? source,
  ServerZone? serverZone,
  String? serverUrl,
  String? flagsServerUrl,
  int? fetchTimeoutMillis,
  bool? retryFetchOnFailure,
  bool? automaticExposureTracking,
  bool? fetchOnStart,
  bool? pollOnStart,
  bool? automaticFetchOnAmplitudeIdentityChange,
}) {
  return ExperimentConfig(
    logLevel: logLevel ?? ExperimentConfigDefaults.logLevel,
    instanceName: instanceName ?? ExperimentConfigDefaults.instanceName,
    fallbackVariant:
        fallbackVariant ?? ExperimentConfigDefaults.fallbackVariant,
    initialFlags: initialFlags,
    initialVariants:
        initialVariants ?? ExperimentConfigDefaults.initialVariants,
    source: source ?? ExperimentConfigDefaults.source,
    serverZone: serverZone ?? ExperimentConfigDefaults.serverZone,
    serverUrl: serverUrl ?? ExperimentConfigDefaults.serverUrl,
    flagsServerUrl: flagsServerUrl ?? ExperimentConfigDefaults.flagsServerUrl,
    fetchTimeoutMillis:
        fetchTimeoutMillis ?? ExperimentConfigDefaults.fetchTimeoutMillis,
    retryFetchOnFailure:
        retryFetchOnFailure ?? ExperimentConfigDefaults.retryFetchOnFailure,
    automaticExposureTracking:
        automaticExposureTracking ??
        ExperimentConfigDefaults.automaticExposureTracking,
    fetchOnStart: fetchOnStart ?? ExperimentConfigDefaults.fetchOnStart,
    pollOnStart: pollOnStart ?? ExperimentConfigDefaults.pollOnStart,
    automaticFetchOnAmplitudeIdentityChange:
        automaticFetchOnAmplitudeIdentityChange ??
        ExperimentConfigDefaults.automaticFetchOnAmplitudeIdentityChange,
  );
}
