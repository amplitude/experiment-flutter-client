import 'package:amplitude_experiment/src/experiment_platform_interface.dart';
import 'package:amplitude_experiment/src/experiment_client.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/models/experiment_user.dart';
import 'package:amplitude_experiment/src/models/variant.dart';
import 'package:amplitude_experiment/src/models/fetch_options.dart';
import 'package:amplitude_experiment/src/providers.dart';
import 'package:amplitude_experiment/src/pigeon_mappers.dart';

class ExperimentClientImpl implements ExperimentClient {
  final String _instanceName;
  final UserProvider? _userProvider;
  ExperimentUser? _user;

  ExperimentClientImpl._({
    required String instanceName,
    UserProvider? userProvider,
  })  : _instanceName = instanceName,
        _userProvider = userProvider;

  static Future<ExperimentClientImpl> create({
    required String apiKey,
    required ExperimentConfig config,
    required bool withAnalytics,
  }) async {
    final client = ExperimentClientImpl._(
      instanceName: config.instanceName,
      userProvider: config.userProvider,
    );
    client._registerProviders(config);
    if (withAnalytics) {
      await ExperimentPlatform.instance.initWithAmplitude(apiKey, config);
    } else {
      await ExperimentPlatform.instance.init(apiKey, config);
    }
    return client;
  }

  void _registerProviders(ExperimentConfig config) {
    if (config.trackingProvider != null) {
      ExperimentPlatform.instance.registerTrackingProvider(
        _instanceName,
        config.trackingProvider!,
      );
    }
  }

  @override
  Future<void> start(ExperimentUser? user) {
    final mergedUser = _resolveUser(user);
    _user = mergedUser;
    return ExperimentPlatform.instance.start(
      _instanceName,
      mergedUser.toPigeon(),
    );
  }

  @override
  Future<void> stop() async {
    return await ExperimentPlatform.instance.stop(_instanceName);
  }

  @override
  Future<void> fetch([
    ExperimentUser? user,
    FetchOptions? options,
  ]) async {
    final mergedUser = _resolveUser(user);
    _user = mergedUser;
    await ExperimentPlatform.instance.fetch(
      _instanceName,
      mergedUser.toPigeon(),
      options?.toPigeon(),
    );
  }

  @override
  Future<Variant> variant(String flagKey, [Variant? fallbackVariant]) async {
    final mergedUser = _resolveUser();
    _user = mergedUser;
    final result = await ExperimentPlatform.instance.variant(
      _instanceName,
      mergedUser.toPigeon(),
      flagKey,
      fallbackVariant?.toPigeon(),
    );
    return variantFromPigeon(result);
  }

  @override
  Future<Map<String, Variant>> all() async {
    final mergedUser = _resolveUser();
    _user = mergedUser;
    final result = await ExperimentPlatform.instance.all(
      _instanceName,
      mergedUser.toPigeon(),
    );
    return result.map((k, v) => MapEntry(k, variantFromPigeon(v)));
  }

  @override
  Future<void> clear() async {
    return await ExperimentPlatform.instance.clear(_instanceName);
  }

  @override
  Future<void> exposure(String flagKey) async {
    return await ExperimentPlatform.instance.exposure(_instanceName, flagKey);
  }

  @override
  Future<ExperimentUser> getUser() async {
    return _user ?? const ExperimentUser();
  }

  @override
  Future<void> setUser(ExperimentUser user) async {
    _user = user;
  }

  @override
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
      country: sdkUser?.country ?? provider?.country,
      city: sdkUser?.city ?? provider?.city,
      region: sdkUser?.region ?? provider?.region,
      dma: sdkUser?.dma ?? provider?.dma,
      ipAddress: sdkUser?.ipAddress ?? provider?.ipAddress,
      deviceBrand: sdkUser?.deviceBrand ?? provider?.deviceBrand,
      carrier: sdkUser?.carrier ?? provider?.carrier,
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
