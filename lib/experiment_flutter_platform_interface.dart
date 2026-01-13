import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/models/variant.dart';
import 'package:experiment_flutter/models/experiment_user.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:experiment_flutter/experiment_flutter_method_channel.dart';

abstract class ExperimentFlutterPlatform extends PlatformInterface {
  /// Constructs a ExperimentFlutterPlatform.
  ExperimentFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExperimentFlutterPlatform _instance = MethodChannelExperimentFlutter();

  /// The default instance of [ExperimentFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelExperimentFlutter].
  static ExperimentFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ExperimentFlutterPlatform] when
  /// they register themselves.
  static set instance(ExperimentFlutterPlatform instance) {
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

  Future<void> fetch(String instanceName, ExperimentUser? user) {
    throw UnimplementedError('fetch() has not been implemented.');
  }

  Future<Variant> variant(
    String instanceName,
    String flagKey,
    Variant? fallbackVariant,
  ) {
    throw UnimplementedError('variant() has not been implemented.');
  }

  Future<Map<String, Variant>> all(String instanceName) {
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
}
