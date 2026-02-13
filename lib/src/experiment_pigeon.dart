import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/custom_provider_pigeon.dart';
import 'package:amplitude_experiment/src/providers.dart'
    show ExposureTrackingProvider;

import 'experiment_platform_interface.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';

class ExperimentPigeon extends ExperimentPlatform {
  final AmplitudeExperimentHostApi _api = AmplitudeExperimentHostApi();
  final CustomProviderPigeon _providerApi = CustomProviderPigeon();

  ExperimentPigeon() : super() {
    CustomProviderApi.setUp(_providerApi);
  }

  @override
  Future<void> init(String apiKey, ExperimentConfig config) async {
    await _api.init(apiKey, config.pigeonConfig);
  }

  @override
  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) async {
    await _api.initWithAmplitude(apiKey, config.pigeonConfig);
  }

  @override
  Future<void> fetch(String instanceName, ExperimentUser? user) async {
    await _api.fetch(instanceName, user);
  }

  @override
  Future<Map<String, Variant>> all(
    String instanceName,
    ExperimentUser user,
  ) async {
    return _api.all(instanceName, user);
  }

  @override
  Future<Variant> variant(
    String instanceName,
    ExperimentUser user,
    String flagKey,
    Variant? fallbackVariant,
  ) async {
    return _api.variant(instanceName, user, flagKey, fallbackVariant);
  }

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    await _api.setUser(instanceName, user);
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    return _api.getUser(instanceName);
  }

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) async {
    await _api.setTracksAssignment(instanceName, tracksAssignment);
  }

  @override
  Future<void> start(String instanceName, ExperimentUser? user) async {
    await _api.start(instanceName, user);
  }

  @override
  Future<void> stop(String instanceName) async {
    await _api.stop(instanceName);
  }

  @override
  Future<void> clear(String instanceName) async {
    await _api.clear(instanceName);
  }

  @override
  Future<void> exposure(String instanceName, String key) async {
    await _api.exposure(instanceName, key);
  }

  @override
  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {
    _providerApi.registerTrackingProvider(instanceName, provider);
  }
}
