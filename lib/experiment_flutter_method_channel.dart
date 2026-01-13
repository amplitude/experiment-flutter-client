import 'experiment_config.dart';
import 'models/variant.dart';
import 'models/experiment_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'experiment_flutter_platform_interface.dart';

/// An implementation of [ExperimentFlutterPlatform] that uses method channels.
class MethodChannelExperimentFlutter extends ExperimentFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('experiment_flutter');

  @override
  Future<void> init(String apiKey, ExperimentConfig config) async {
    Map<String, dynamic> configMap = config.toMap();
    configMap.putIfAbsent('apiKey', () => apiKey);
    await methodChannel.invokeMethod<void>('init', configMap);
  }

  @override
  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) async {
    Map<String, dynamic> configMap = config.toMap();
    configMap.putIfAbsent('apiKey', () => apiKey);
    await methodChannel.invokeMethod<void>('initWithAmplitude', configMap);
  }

  @override
  Future<void> fetch(String instanceName, ExperimentUser? user) async {
    Map<String, dynamic> params = {'instanceName': instanceName};
    if (user != null) {
      params['user'] = user.toMap();
    }
    await methodChannel.invokeMethod<void>('fetch', params);
  }

  @override
  Future<Map<String, Variant>> all(String instanceName) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'all',
      {'instanceName': instanceName},
    );
    if (result == null) {
      return {};
    }
    return result.map(
      (key, value) => MapEntry(
        key as String,
        Variant.fromMap(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  @override
  Future<Variant> variant(
    String instanceName,
    String flagKey,
    Variant? fallbackVariant,
  ) async {
    Map<String, dynamic> params = {
      'instanceName': instanceName,
      'flagKey': flagKey,
    };
    if (fallbackVariant != null) {
      params['fallbackVariant'] = fallbackVariant.toMap();
    }
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'variant',
      params,
    );
    if (result == null) {
      return Variant.fromMap({});
    }
    return Variant.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    await methodChannel.invokeMethod<void>('setUser', {
      'instanceName': instanceName,
      'user': user.toMap(),
    });
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getUser',
      {'instanceName': instanceName},
    );
    if (result == null) {
      return ExperimentUser.fromMap({});
    }
    return ExperimentUser.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) async {
    await methodChannel.invokeMethod<void>('setTracksAssignment', {
      'instanceName': instanceName,
      'tracksAssignment': tracksAssignment,
    });
  }

  @override
  Future<void> start(String instanceName, ExperimentUser? user) async {
    Map<String, dynamic> params = {'instanceName': instanceName};
    if (user != null) {
      params['user'] = user.toMap();
    }
    await methodChannel.invokeMethod<void>('start', params);
  }

  @override
  Future<void> stop(String instanceName) async {
    await methodChannel.invokeMethod<void>('stop', {
      'instanceName': instanceName,
    });
  }

  @override
  Future<void> clear(String instanceName) async {
    await methodChannel.invokeMethod<void>('clear', {
      'instanceName': instanceName,
    });
  }

  @override
  Future<void> exposure(String instanceName, String key) async {
    await methodChannel.invokeMethod<void>('exposure', {
      'instanceName': instanceName,
      'key': key,
    });
  }
}
