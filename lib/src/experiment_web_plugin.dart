import 'dart:js_interop';
import 'dart:async';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:amplitude_experiment/src/experiment_platform_interface.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/experiment_js.dart';
import 'package:amplitude_experiment/src/web/codec/config_codec.dart';
import 'package:amplitude_experiment/src/web/codec/user_codec.dart';
import 'package:amplitude_experiment/src/web/codec/variant_codec.dart';
import 'package:amplitude_experiment/src/web/codec/options_codec.dart';
import 'package:amplitude_experiment/src/web/codec/codec_utils.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/providers.dart'
    show ExposureTrackingProvider;

/// Web implementation of [ExperimentPlatform]
class ExperimentWebPlugin extends ExperimentPlatform {
  static void registerWith(Registrar registrar) {
    ExperimentPlatform.instance = ExperimentWebPlugin();
  }

  // Store client instances by instance name
  final Map<String, ExperimentClient> _instances = {};

  @override
  Future<void> init(String apiKey, ExperimentConfig config) async {
    // Call Experiment.initialize(apiKey, config)
    final ExperimentClient client = Experiment.initialize(
      apiKey,
      ConfigCodec.toJSObject(config),
    );

    _instances[config.instanceName] = client;
  }

  @override
  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) async {
    final ExperimentClient client = Experiment.initializeWithAmplitudeAnalytics(
      apiKey,
      ConfigCodec.toJSObject(config),
    );

    _instances[config.instanceName] = client;
  }

  @override
  Future<void> start(String instanceName, ExperimentUser? user) async {
    final client = _getClient(instanceName);

    JSPromise promise;
    if (user != null) {
      final userObj = UserCodec.toJSObject(user);
      promise = client.start(userObj);
    } else {
      promise = client.start();
    }

    // start returns Promise<void>
    await promise.toDart;
  }

  @override
  Future<void> stop(String instanceName) async {
    final client = _getClient(instanceName);
    client.stop();
  }

  @override
  Future<void> fetch(
    String instanceName,
    ExperimentUser? user,
    FetchOptions? options,
  ) async {
    final client = _getClient(instanceName);

    final userObj = user != null ? UserCodec.toJSObject(user) : null;
    final optionsObj = options != null ? OptionsCodec.toJSObject(options) : null;

    final promise = client.fetch(userObj, optionsObj);
    await promise.toDart;
  }

  @override
  Future<Variant> variant(
    String instanceName,
    ExperimentUser? user,
    String flagKey,
    Variant? fallbackVariant,
  ) async {
    final client = _getClient(instanceName);

    JSObject variantObj;
    if (fallbackVariant != null) {
      final fallbackObj = VariantCodec.toJSObject(fallbackVariant);
      variantObj = client.variant(flagKey, fallbackObj);
    } else {
      variantObj = client.variant(flagKey);
    }

    return VariantCodec.fromJSObject(variantObj);
  }

  @override
  Future<Map<String, Variant>> all(
    String instanceName,
    ExperimentUser? user,
  ) async {
    final client = _getClient(instanceName);
    final allVariants = client.all();
    final dartified = allVariants.dartify();
    if (dartified == null) {
      return {};
    }

    final allMap = CodecUtils.toPlainMap(dartified);
    if (allMap == null) {
      return {};
    }

    final Map<String, Variant> result = {};
    for (final entry in allMap.entries) {
      final variantRaw = entry.value;
      if (variantRaw != null) {
        final variantMap = CodecUtils.toPlainMap(variantRaw);
        if (variantMap != null) {
          result[entry.key] = VariantCodec.fromMap(variantMap);
        }
      }
    }

    return result;
  }

  @override
  Future<void> clear(String instanceName) async {
    final client = _getClient(instanceName);
    client.clear();
  }

  @override
  Future<void> exposure(String instanceName, String key) async {
    final client = _getClient(instanceName);
    client.exposure(key);
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    final client = _getClient(instanceName);
    final userObj = client.getUser();
    return UserCodec.fromJSObject(userObj);
  }

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    final client = _getClient(instanceName);
    final userObj = UserCodec.toJSObject(user);
    client.setUser(userObj);
  }

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) async {
    final client = _getClient(instanceName);
    client.setTracksAssignment(tracksAssignment);
  }

  /// No-op on web. Tracking providers are wired through the config at init
  /// time via [ConfigCodec.toJSObject], so runtime registration is unnecessary.
  @override
  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {}

  ExperimentClient _getClient(String instanceName) {
    final ExperimentClient? client = _instances[instanceName];
    if (client == null) {
      throw ArgumentError('ExperimentClient instance $instanceName not found');
    }
    return client;
  }
}
