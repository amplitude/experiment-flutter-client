import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:async';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:amplitude_experiment/src/experiment_platform_interface.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/experiment_js.dart';
import 'package:amplitude_experiment/src/web/codec/config_codec.dart';
import 'package:amplitude_experiment/src/web/codec/user_codec.dart';
import 'package:amplitude_experiment/src/web/codec/variant_codec.dart';
import 'package:amplitude_experiment/src/web/codec/options_codec.dart';
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
    final allFn = client['all'] as JSFunction?;
    if (allFn == null) {
      throw UnsupportedError('Client.all not found');
    }

    final allVariants =
        allFn.callAsFunction(client, <JSAny>[].toJS) as JSObject;
    final Map<String, Variant> result = {};

    // Get all keys from the JS object using Object.keys
    final objectKeys = globalContext['Object'] as JSObject;
    final keysFn = objectKeys['keys'] as JSFunction;
    final keys =
        keysFn.callAsFunction(objectKeys, [allVariants].toJS)
            as JSArray<JSString>;

    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final keyStr = key.toDart;
      final variantObj = allVariants[keyStr] as JSObject?;
      if (variantObj != null) {
        result[keyStr] = VariantCodec.fromJSObject(variantObj);
      }
    }

    return result;
  }

  @override
  Future<void> clear(String instanceName) async {
    final client = _getClient(instanceName);
    final clearFn = client['clear'] as JSFunction?;
    if (clearFn == null) {
      throw UnsupportedError('Client.clear not found');
    }
    clearFn.callAsFunction(client, <JSAny>[].toJS);
  }

  @override
  Future<void> exposure(String instanceName, String key) async {
    final client = _getClient(instanceName);
    client.exposure(key);
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    final client = _getClient(instanceName);
    final getUserFn = client['getUser'] as JSFunction?;
    if (getUserFn == null) {
      throw UnsupportedError('Client.getUser not found');
    }

    final userObj =
        getUserFn.callAsFunction(client, <JSAny>[].toJS) as JSObject?;

    if (userObj == null) {
      return ExperimentUser();
    }

    return UserCodec.fromJSObject(userObj);
  }

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    final client = _getClient(instanceName);
    final setUserFn = client['setUser'] as JSFunction?;
    if (setUserFn == null) {
      throw UnsupportedError('Client.setUser not found');
    }
    final userObj = UserCodec.toJSObject(user);
    setUserFn.callAsFunction(client, [userObj].toJS);
  }

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) async {
    final client = _getClient(instanceName);
    final setTracksAssignmentFn = client['setTracksAssignment'] as JSFunction?;
    if (setTracksAssignmentFn == null) {
      throw UnsupportedError('Client.setTracksAssignment not found');
    }
    setTracksAssignmentFn.callAsFunction(client, [tracksAssignment.toJS].toJS);
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
