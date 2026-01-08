import 'models/variant.dart';
import 'constants.dart';

enum LogLevel { none, error, warn, info, debug }

enum Source { localStorage, initialVariants }

class Defaults {
  static const LogLevel logLevel = LogLevel.warn;
  static const String instanceName = '\$default_instance';
  static const Variant fallbackVariant = Variant();
  static const String? initialFlags = null;
  static const Map<String, Variant> initialVariants = {};
  static const Source source = Source.localStorage;
  static const ServerZone serverZone = ServerZone.us;
  static const String serverUrl = Constants.serverUrl;
  static const String flagsServerUrl = Constants.flagsServerUrl;
  static const int fetchTimeoutMillis = Constants.fetchTimeoutMillis;
  static const bool retryFetchOnFailure = true;
  static const bool automaticExposureTracking = true;
  static const bool pollOnStart = false;
  static const bool fetchOnStart = true;
  static const bool automaticFetchOnAmplitudeIdentityChange = false;
}

class ExperimentConfig {
  LogLevel logLevel;
  String instanceName;
  Variant fallbackVariant;
  String? initialFlags;
  Map<String, Variant> initialVariants;
  Source source;
  ServerZone serverZone;
  String serverUrl;
  String flagsServerUrl;
  int fetchTimeoutMillis;
  bool retryFetchOnFailure;
  bool automaticExposureTracking;
  bool fetchOnStart;
  bool pollOnStart;
  bool automaticFetchOnAmplitudeIdentityChange;

  ExperimentConfig({
    this.logLevel = Defaults.logLevel,
    this.instanceName = Defaults.instanceName,
    this.fallbackVariant = Defaults.fallbackVariant,
    this.initialFlags = Defaults.initialFlags,
    this.initialVariants = Defaults.initialVariants,
    this.source = Defaults.source,
    this.serverZone = Defaults.serverZone,
    this.serverUrl = Defaults.serverUrl,
    this.flagsServerUrl = Defaults.flagsServerUrl,
    this.fetchTimeoutMillis = Defaults.fetchTimeoutMillis,
    this.retryFetchOnFailure = Defaults.retryFetchOnFailure,
    this.automaticExposureTracking = Defaults.automaticExposureTracking,
    this.fetchOnStart = Defaults.fetchOnStart,
    this.pollOnStart = Defaults.pollOnStart,
    this.automaticFetchOnAmplitudeIdentityChange =
        Defaults.automaticFetchOnAmplitudeIdentityChange,
  });

  Map<String, dynamic> toMap() {
    return {
      'logLevel': logLevel.name,
      'instanceName': instanceName,
      'fallbackVariant': fallbackVariant.toMap(),
      'initialFlags': initialFlags,
      'initialVariants': initialVariants.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'source': source.name,
      'serverZone': serverZone.name,
      'serverUrl': serverUrl,
      'flagsServerUrl': flagsServerUrl,
      'fetchTimeoutMillis': fetchTimeoutMillis,
      'retryFetchOnFailure': retryFetchOnFailure,
      'automaticExposureTracking': automaticExposureTracking,
      'fetchOnStart': fetchOnStart,
      'pollOnStart': pollOnStart,
      'automaticFetchOnAmplitudeIdentityChange':
          automaticFetchOnAmplitudeIdentityChange,
    };
  }
}
