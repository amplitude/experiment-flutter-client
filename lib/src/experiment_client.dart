import 'experiment_platform_interface.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/providers.dart';

class ExperimentClient {
  final String apiKey;
  final ExperimentConfig config;
  late Future<void> isBuilt;
  late String _instanceName;
  UserProvider? _userProvider;
  ExperimentUser? _user;

  ExperimentClient({
    required this.apiKey,
    required this.config,
    required bool withAnalytics,
  }) {
    _instanceName = config.instanceName;
    _userProvider = config.userProvider;
    isBuilt = _init(withAnalytics);
  }

  Future<void> _init(bool withAnalytics) async {
    _registerProviders();
    if (withAnalytics) {
      await ExperimentPlatform.instance.initWithAmplitude(apiKey, config);
    } else {
      await ExperimentPlatform.instance.init(apiKey, config);
    }
  }

  void _registerProviders() {
    if (config.trackingProvider != null) {
      ExperimentPlatform.instance.registerTrackingProvider(
        _instanceName,
        config.trackingProvider!,
      );
    }
  }

  Future<void> start(ExperimentUser? user) {
    final mergedUser = _resolveUser(user);
    _user = mergedUser;
    return ExperimentPlatform.instance.start(_instanceName, mergedUser);
  }

  Future<void> stop() async {
    return await ExperimentPlatform.instance.stop(_instanceName);
  }

  Future<ExperimentClient> fetch([
    ExperimentUser? user,
    FetchOptions? options,
  ]) async {
    final mergedUser = _resolveUser(user);
    _user = mergedUser;
    await ExperimentPlatform.instance.fetch(_instanceName, mergedUser, options);
    return this;
  }

  Future<Variant> variant(String flagKey, [Variant? fallbackVariant]) {
    final mergedUser = _resolveUser();
    _user = mergedUser;
    return ExperimentPlatform.instance.variant(
      _instanceName,
      mergedUser,
      flagKey,
      fallbackVariant,
    );
  }

  Future<Map<String, Variant>> all() {
    final mergedUser = _resolveUser();
    _user = mergedUser;
    return ExperimentPlatform.instance.all(_instanceName, mergedUser);
  }

  Future<void> clear() async {
    return await ExperimentPlatform.instance.clear(_instanceName);
  }

  Future<void> exposure(String flagKey) async {
    return await ExperimentPlatform.instance.exposure(_instanceName, flagKey);
  }

  ExperimentUser getUser() {
    return _user ?? ExperimentUser();
  }

  void setUser(ExperimentUser user) {
    _user = user;
  }

  Future<void> setTracksAssignment(bool tracksAssignment) async {
    return await ExperimentPlatform.instance.setTracksAssignment(
      _instanceName,
      tracksAssignment,
    );
  }

  // ── User Resolution ──────────────────────────────

  ExperimentUser _resolveUser([ExperimentUser? explicit]) {
    final provider = _userProvider?.getUser();
    final sdkUser = explicit ?? _user;
    _user = _merge(sdkUser, provider);
    return _user!;
  }

  /// Two-way merge: SDK user fields take precedence over provider.
  static ExperimentUser _merge(
    ExperimentUser? sdkUser,
    ExperimentUser? provider,
  ) {
    return ExperimentUser(
      userId: sdkUser?.userId ?? provider?.userId,
      deviceId: sdkUser?.deviceId ?? provider?.deviceId,
      version: sdkUser?.version ?? provider?.version,
      platform: sdkUser?.platform ?? provider?.platform,
      os: sdkUser?.os ?? provider?.os,
      deviceModel: sdkUser?.deviceModel ?? provider?.deviceModel,
      deviceManufacturer:
          sdkUser?.deviceManufacturer ?? provider?.deviceManufacturer,
      language: sdkUser?.language ?? provider?.language,
      userProperties: _mergeMaps(
        sdkUser?.userProperties,
        provider?.userProperties,
      ),
      groups:
          _mergeMaps(sdkUser?.groups, provider?.groups)
              as Map<String, List<String>>?,
      groupProperties:
          _mergeMaps(sdkUser?.groupProperties, provider?.groupProperties)
              as Map<String, Map<String, Map<String, Object?>>>?,
    );
  }

  static Map<String, dynamic>? _mergeMaps(
    Map<String, dynamic>? sdkMap,
    Map<String, dynamic>? providerMap,
  ) {
    if (sdkMap == null && providerMap == null) return null;
    return {...?providerMap, ...?sdkMap};
  }
}
