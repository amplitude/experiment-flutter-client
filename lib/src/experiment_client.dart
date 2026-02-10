import 'experiment_platform_interface.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';

class ExperimentClient {
  final String apiKey;
  final ExperimentConfig config;
  late Future<bool> isBuilt;
  late String _instanceName;

  ExperimentClient({
    required this.apiKey,
    required this.config,
    required bool withAnalytics,
  }) {
    _instanceName = config.instanceName;
    isBuilt = _init(withAnalytics);
  }

  Future<bool> _init(bool withAnalytics) async {
    try {
      _registerProviders();
      if (withAnalytics) {
        await ExperimentPlatform.instance.initWithAmplitude(apiKey, config);
      } else {
        await ExperimentPlatform.instance.init(apiKey, config);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void _registerProviders() {
    if (config.trackingProvider != null) {
      print('registering tracking provider');
      config.trackingProvider!.track(
        Exposure(flagKey: 'BANANA', variant: 'variant1'),
      );
      ExperimentPlatform.instance.registerTrackingProvider(
        _instanceName,
        config.trackingProvider!,
      );
    }
    if (config.userProvider != null) {
      ExperimentPlatform.instance.registerUserProvider(
        _instanceName,
        config.userProvider!,
      );
    }
  }

  Future<void> start(ExperimentUser? user) {
    return ExperimentPlatform.instance.start(_instanceName, user);
  }

  Future<void> stop() async {
    return await ExperimentPlatform.instance.stop(_instanceName);
  }

  Future<ExperimentClient> fetch([ExperimentUser? user]) async {
    await ExperimentPlatform.instance.fetch(_instanceName, user);
    return this;
  }

  Future<Variant> variant(String flagKey, [Variant? fallbackVariant]) {
    return ExperimentPlatform.instance.variant(
      _instanceName,
      flagKey,
      fallbackVariant,
    );
  }

  Future<Map<String, Variant>> all() {
    return ExperimentPlatform.instance.all(_instanceName);
  }

  Future<void> clear() async {
    return await ExperimentPlatform.instance.clear(_instanceName);
  }

  Future<void> exposure(String flagKey) async {
    return await ExperimentPlatform.instance.exposure(_instanceName, flagKey);
  }

  Future<ExperimentUser> getUser() {
    return ExperimentPlatform.instance.getUser(_instanceName);
  }

  Future<void> setUser(ExperimentUser user) async {
    return await ExperimentPlatform.instance.setUser(_instanceName, user);
  }

  Future<void> setTracksAssignment(bool tracksAssignment) async {
    return await ExperimentPlatform.instance.setTracksAssignment(
      _instanceName,
      tracksAssignment,
    );
  }
}
