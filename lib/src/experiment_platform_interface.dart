import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:amplitude_experiment/src/experiment_pigeon.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/providers.dart'
    show ExposureTrackingProvider;

abstract class ExperimentPlatform extends PlatformInterface {
  /// Constructs a ExperimentPlatform.
  ExperimentPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExperimentPlatform _instance = ExperimentPigeon();

  /// The default instance of [ExperimentPlatform] to use.
  ///
  /// Defaults to [ExperimentPigeon].
  static ExperimentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ExperimentPlatform] when
  /// they register themselves.
  static set instance(ExperimentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(String apiKey, ExperimentConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) {
    throw UnimplementedError(
      'initializeWithAmplitude() has not been implemented.',
    );
  }

  Future<void> start(String instanceName, ExperimentUser? user) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop(String instanceName) {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> fetch(
    String instanceName,
    ExperimentUser? user,
    FetchOptions? options,
  ) {
    throw UnimplementedError('fetch() has not been implemented.');
  }

  Future<Variant> variant(
    String instanceName,
    ExperimentUser? user,
    String flagKey,
    Variant? fallbackVariant,
  ) {
    throw UnimplementedError('variant() has not been implemented.');
  }

  Future<Map<String, Variant>> all(String instanceName, ExperimentUser? user) {
    throw UnimplementedError('all() has not been implemented.');
  }

  Future<void> clear(String instanceName) {
    throw UnimplementedError('clear() has not been implemented.');
  }

  Future<void> exposure(String instanceName, String key) {
    throw UnimplementedError('exposure() has not been implemented.');
  }

  Future<ExperimentUser> getUser(String instanceName) {
    throw UnimplementedError('getUser() has not been implemented.');
  }

  Future<void> setUser(String instanceName, ExperimentUser user) {
    throw UnimplementedError('setUser() has not been implemented.');
  }

  Future<void> setTracksAssignment(String instanceName, bool tracksAssignment) {
    throw UnimplementedError('setTracksAssignment() has not been implemented.');
  }

  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {
    throw UnimplementedError(
      'registerTrackingProvider() has not been implemented.',
    );
  }
}
