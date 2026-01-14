import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:experiment_flutter/experiment_flutter_platform_interface.dart';
import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/constants.dart';
import 'package:experiment_flutter/models/variant.dart';
import 'package:experiment_flutter/models/experiment_user.dart';
import 'package:experiment_flutter/web/experiment_js.dart';

// @JS()
// external Experiment get experiment;

/// Web implementation of [ExperimentFlutterPlatform]
class ExperimentFlutterWeb extends ExperimentFlutterPlatform {
  static void registerWith(Registrar registrar) {
    ExperimentFlutterPlatform.instance = ExperimentFlutterWeb();
  }

  // Store client instances by instance name
  final Map<String, ExperimentClient> _instances = {};

  @override
  Future<void> init(String apiKey, ExperimentConfig config) async {
    // Build config object for JS SDK
    final configObj = _buildConfigObject(config);

    // Call Experiment.initialize(apiKey, config)
    final ExperimentClient client = Experiment.initialize(apiKey, configObj);

    _instances[config.instanceName] = client;
  }

  @override
  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) async {
    final configObj = _buildConfigObject(config);

    final ExperimentClient client = Experiment.initializeWithAmplitudeAnalytics(
      apiKey,
      configObj,
    );

    _instances[config.instanceName] = client;
  }

  @override
  Future<void> start(String instanceName, ExperimentUser? user) async {
    final client = _getClient(instanceName);

    JSPromise promise;
    if (user != null) {
      final userObj = _buildUserObject(user);
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
  Future<void> fetch(String instanceName, ExperimentUser? user) async {
    final client = _getClient(instanceName);

    final promise = user != null
        ? client.fetch(_buildUserObject(user))
        : client.fetch();

    await promise.toDart;
  }

  @override
  Future<Variant> variant(
    String instanceName,
    String flagKey,
    Variant? fallbackVariant,
  ) async {
    final client = _getClient(instanceName);

    JSObject variantObj;
    if (fallbackVariant != null) {
      final fallbackObj = _buildVariantObject(fallbackVariant);
      variantObj = client.variant(flagKey, fallbackObj);
    } else {
      variantObj = client.variant(flagKey);
    }

    return _variantFromJsObject(variantObj);
  }

  @override
  Future<Map<String, Variant>> all(String instanceName) async {
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
        result[keyStr] = _variantFromJsObject(variantObj);
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
    await Future.value('Exposure tracked');
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

    return _userFromJsObject(userObj);
  }

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    final client = _getClient(instanceName);
    final setUserFn = client['setUser'] as JSFunction?;
    if (setUserFn == null) {
      throw UnsupportedError('Client.setUser not found');
    }
    final userObj = _buildUserObject(user);
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

  // Helper methods

  ExperimentClient _getClient(String instanceName) {
    final ExperimentClient? client = _instances[instanceName];
    if (client == null) {
      throw ArgumentError('ExperimentClient instance $instanceName not found');
    }
    return client;
  }

  JSObject _buildConfigObject(ExperimentConfig config) {
    final configMap = <String, dynamic>{
      'instanceName': config.instanceName,
      'fetchOnStart': config.fetchOnStart,
      'pollOnStart': config.pollOnStart,
      'retryFetchOnFailure': config.retryFetchOnFailure,
      'automaticExposureTracking': config.automaticExposureTracking,
      'automaticFetchOnAmplitudeIdentityChange':
          config.automaticFetchOnAmplitudeIdentityChange,
      'fetchTimeoutMillis': config.fetchTimeoutMillis,
    };

    if (config.serverUrl.isNotEmpty) {
      configMap['serverUrl'] = config.serverUrl;
    }
    if (config.flagsServerUrl.isNotEmpty) {
      configMap['flagsServerUrl'] = config.flagsServerUrl;
    }
    if (config.initialFlags != null) {
      configMap['initialFlags'] = config.initialFlags;
    }
    if (config.initialVariants.isNotEmpty) {
      configMap['initialVariants'] = config.initialVariants.map(
        (key, value) => MapEntry(key, value.toMap()),
      );
    }
    if (config.fallbackVariant.key != null ||
        config.fallbackVariant.value != null) {
      configMap['fallbackVariant'] = config.fallbackVariant.toMap();
    }

    // Convert source enum
    switch (config.source) {
      case Source.localStorage:
        configMap['source'] = 'localStorage';
        break;
      case Source.initialVariants:
        configMap['source'] = 'initialVariants';
        break;
    }

    // Convert serverZone enum
    switch (config.serverZone) {
      case ServerZone.us:
        configMap['serverZone'] = 'us';
        break;
      case ServerZone.eu:
        configMap['serverZone'] = 'eu';
        break;
    }

    return configMap.jsify() as JSObject;
  }

  JSObject _buildUserObject(ExperimentUser user) {
    final userMap = <String, dynamic>{};

    if (user.deviceId != null) userMap['deviceId'] = user.deviceId;
    if (user.userId != null) userMap['userId'] = user.userId;
    if (user.country != null) userMap['country'] = user.country;
    if (user.city != null) userMap['city'] = user.city;
    if (user.region != null) userMap['region'] = user.region;
    if (user.dma != null) userMap['dma'] = user.dma;
    if (user.language != null) userMap['language'] = user.language;
    if (user.platform != null) userMap['platform'] = user.platform;
    if (user.version != null) userMap['version'] = user.version;
    if (user.os != null) userMap['os'] = user.os;
    if (user.deviceModel != null) userMap['deviceModel'] = user.deviceModel;
    if (user.deviceBrand != null) userMap['deviceBrand'] = user.deviceBrand;
    if (user.deviceManufacturer != null) {
      userMap['deviceManufacturer'] = user.deviceManufacturer;
    }
    if (user.carrier != null) userMap['carrier'] = user.carrier;
    if (user.library != null) userMap['library'] = user.library;
    if (user.ipAddress != null) userMap['ipAddress'] = user.ipAddress;
    if (user.userProperties != null) {
      userMap['userProperties'] = user.userProperties;
    }
    if (user.groups != null) {
      userMap['groups'] = user.groups;
    }
    if (user.groupProperties != null) {
      userMap['groupProperties'] = user.groupProperties;
    }

    return userMap.jsify() as JSObject;
  }

  JSObject _buildVariantObject(Variant variant) {
    return variant.toMap().jsify() as JSObject;
  }

  Variant _variantFromJsObject(JSObject variantObj) {
    final map = <String, dynamic>{};

    final key = variantObj['key'];
    if (key != null) {
      map['key'] = (key as JSString).toDart;
    }

    final value = variantObj['value'];
    if (value != null) {
      map['value'] = (value as JSString).toDart;
    }

    final payload = variantObj['payload'];
    if (payload != null) {
      if (payload is JSString) {
        map['payload'] = payload.toDart;
      } else {
        map['payload'] = jsonEncode(payload.dartify());
      }
    }

    final expKey = variantObj['expKey'];
    if (expKey != null) {
      map['expKey'] = (expKey as JSString).toDart;
    }

    final metadata = variantObj['metadata'];
    if (metadata != null) {
      map['metadata'] = jsonEncode(metadata.dartify());
    }

    return Variant.fromMap(map);
  }

  ExperimentUser _userFromJsObject(JSObject userObj) {
    final map = <String, dynamic>{};

    _setIfPresent(userObj, 'deviceId', map);
    _setIfPresent(userObj, 'userId', map);
    _setIfPresent(userObj, 'country', map);
    _setIfPresent(userObj, 'city', map);
    _setIfPresent(userObj, 'region', map);
    _setIfPresent(userObj, 'dma', map);
    _setIfPresent(userObj, 'language', map);
    _setIfPresent(userObj, 'platform', map);
    _setIfPresent(userObj, 'version', map);
    _setIfPresent(userObj, 'os', map);
    _setIfPresent(userObj, 'deviceModel', map);
    _setIfPresent(userObj, 'deviceBrand', map);
    _setIfPresent(userObj, 'deviceManufacturer', map);
    _setIfPresent(userObj, 'carrier', map);
    _setIfPresent(userObj, 'library', map);
    _setIfPresent(userObj, 'ipAddress', map);

    final userProperties = userObj['userProperties'];
    if (userProperties != null) {
      map['userProperties'] = jsonEncode(userProperties.dartify());
    }

    final groups = userObj['groups'];
    if (groups != null) {
      map['groups'] = jsonEncode(groups.dartify());
    }

    final groupProperties = userObj['groupProperties'];
    if (groupProperties != null) {
      map['groupProperties'] = jsonEncode(groupProperties.dartify());
    }

    return ExperimentUser.fromMap(map);
  }

  void _setIfPresent(JSObject obj, String key, Map<String, dynamic> map) {
    final value = obj[key];
    if (value != null) {
      if (value is JSString) {
        map[key] = value.toDart;
      } else if (value is JSNumber) {
        map[key] = value.toDartDouble;
      } else if (value is JSBoolean) {
        map[key] = value.toDart;
      } else {
        map[key] = value.dartify();
      }
    }
  }
}
