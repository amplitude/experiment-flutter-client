import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'amplitude_experiment',
    dartOut: 'lib/src/generated/amplitude_experiment_api.g.dart',
    dartOptions: DartOptions(
      copyrightHeader: <String>['dart format off', 'coverage:ignore-file'],
    ),
    swiftOut: 'ios/amplitude_experiment/Sources/amplitude_experiment/AmplitudeExperimentApi.g.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/amplitude/experiment/flutter/AmplitudeExperimentApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.amplitude.experiment.flutter'),
  ),
)
// Enums (must be defined before use in classes)
enum LogLevel { none, error, warn, info, debug }

enum Source { localStorage, initialVariants }

enum ServerZone { us, eu }

class ExperimentUser {
  final String? deviceId;
  final String? userId;
  final String? country;
  final String? city;
  final String? region;
  final String? dma;
  final String? language;
  final String? platform;
  final String? version;
  final String? os;
  final String? deviceModel;
  final String? deviceBrand;
  final String? deviceManufacturer;
  final String? carrier;
  final String? library;
  final String? ipAddress;
  final Map<String, Object?>? userProperties;
  final Map<String, List<String>>? groups;
  final Map<String, Map<String, Map<String, Object?>>>? groupProperties;

  ExperimentUser({
    this.deviceId,
    this.userId,
    this.country,
    this.city,
    this.region,
    this.dma,
    this.language,
    this.platform,
    this.version,
    this.os,
    this.deviceModel,
    this.deviceBrand,
    this.deviceManufacturer,
    this.carrier,
    this.library,
    this.ipAddress,
    this.userProperties,
    this.groups,
    this.groupProperties,
  });
}

class Variant {
  final String? key;
  final String? value;
  final Object? payload;
  final String? expKey;
  final Map<String, Object?>? metadata;

  const Variant({
    this.key,
    this.value,
    this.payload,
    this.expKey,
    this.metadata,
  });
}

class ExperimentConfigData {
  String instanceName;
  LogLevel logLevel;
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
  bool hasTrackingProvider;

  ExperimentConfigData({
    required this.instanceName,
    required this.logLevel,
    required this.fallbackVariant,
    this.initialFlags,
    required this.initialVariants,
    required this.source,
    required this.serverZone,
    required this.serverUrl,
    required this.flagsServerUrl,
    required this.fetchTimeoutMillis,
    required this.retryFetchOnFailure,
    required this.automaticExposureTracking,
    required this.fetchOnStart,
    required this.pollOnStart,
    required this.automaticFetchOnAmplitudeIdentityChange,
    required this.hasTrackingProvider,
  });
}

@HostApi()
abstract class AmplitudeExperimentHostApi {
  @SwiftFunction('initializeExperiment(apiKey:config:)')
  void init(String apiKey, ExperimentConfigData config);

  @SwiftFunction('initializeExperimentWithAmplitude(apiKey:config:)')
  void initWithAmplitude(String apiKey, ExperimentConfigData config);

  @async
  void start(String instanceName, ExperimentUser? user);

  void stop(String instanceName);

  @async
  void fetch(String instanceName, ExperimentUser? user, FetchOptions? options);

  Variant variant(
    String instanceName,
    ExperimentUser? user,
    String flagKey,
    Variant? fallbackVariant,
  );
  Map<String, Variant> all(String instanceName, ExperimentUser? user);

  void clear(String instanceName);

  void exposure(String instanceName, String key);

  ExperimentUser getUser(String instanceName);

  void setUser(String instanceName, ExperimentUser user);

  void setTracksAssignment(String instanceName, bool tracksAssignment);
}

class Exposure {
  late String flagKey;
  String? variant;
  String? experimentKey;
  Map<String, Object?>? metadata;
  int? time;
}

class FetchOptions {
  List<String>? flagKeys;
}

@FlutterApi()
abstract class CustomProviderApi {
  void track(String instanceName, Exposure exposure);
}
