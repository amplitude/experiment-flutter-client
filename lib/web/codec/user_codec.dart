import 'dart:js_interop';
import 'dart:convert';
import 'package:experiment_flutter/models/experiment_user.dart';

/// Codec for converting ExperimentUser objects between Dart and JS.
class UserCodec {
  /// Converts an ExperimentUser to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(ExperimentUser user) {
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

  /// Converts a JSObject from the JavaScript SDK to a Dart ExperimentUser.
  static ExperimentUser fromJSObject(JSObject userObj) {
    // Convert JSObject to Dart Map first
    final dartified = userObj.dartify();
    if (dartified == null) {
      return ExperimentUser();
    }

    // Convert LinkedMap<Object?, Object?> to Map<String, dynamic>
    final userMap = Map<String, dynamic>.from(
      (dartified as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );

    final map = <String, dynamic>{};

    _setIfPresent(userMap, 'deviceId', map);
    _setIfPresent(userMap, 'userId', map);
    _setIfPresent(userMap, 'country', map);
    _setIfPresent(userMap, 'city', map);
    _setIfPresent(userMap, 'region', map);
    _setIfPresent(userMap, 'dma', map);
    _setIfPresent(userMap, 'language', map);
    _setIfPresent(userMap, 'platform', map);
    _setIfPresent(userMap, 'version', map);
    _setIfPresent(userMap, 'os', map);
    _setIfPresent(userMap, 'deviceModel', map);
    _setIfPresent(userMap, 'deviceBrand', map);
    _setIfPresent(userMap, 'deviceManufacturer', map);
    _setIfPresent(userMap, 'carrier', map);
    _setIfPresent(userMap, 'library', map);
    _setIfPresent(userMap, 'ipAddress', map);

    final userProperties = userMap['userProperties'];
    if (userProperties != null) {
      map['userProperties'] = jsonEncode(userProperties);
    }

    final groups = userMap['groups'];
    if (groups != null) {
      map['groups'] = jsonEncode(groups);
    }

    final groupProperties = userMap['groupProperties'];
    if (groupProperties != null) {
      map['groupProperties'] = jsonEncode(groupProperties);
    }

    return ExperimentUser.fromMap(map);
  }

  /// Helper method to set a value in the map if present in the source map.
  static void _setIfPresent(
    Map<String, dynamic> source,
    String key,
    Map<String, dynamic> target,
  ) {
    final value = source[key];
    if (value != null) {
      target[key] = value;
    }
  }
}
