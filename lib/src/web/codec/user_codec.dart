import 'dart:js_interop';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

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
    final dartified = userObj.dartify();
    if (dartified == null) {
      return ExperimentUser();
    }

    // Normalize to a plain Map (dartify() can return IdentityMap, etc.)
    final userMap = toPlainMap(dartified);
    if (userMap == null) {
      return ExperimentUser();
    }

    return ExperimentUser(
      deviceId: _stringOrNull(userMap['deviceId']),
      userId: _stringOrNull(userMap['userId']),
      country: _stringOrNull(userMap['country']),
      city: _stringOrNull(userMap['city']),
      region: _stringOrNull(userMap['region']),
      dma: _stringOrNull(userMap['dma']),
      language: _stringOrNull(userMap['language']),
      platform: _stringOrNull(userMap['platform']),
      version: _stringOrNull(userMap['version']),
      os: _stringOrNull(userMap['os']),
      deviceModel: _stringOrNull(userMap['deviceModel']),
      deviceBrand: _stringOrNull(userMap['deviceBrand']),
      deviceManufacturer: _stringOrNull(userMap['deviceManufacturer']),
      carrier: _stringOrNull(userMap['carrier']),
      library: _stringOrNull(userMap['library']),
      ipAddress: _stringOrNull(userMap['ipAddress']),
      userProperties: _castMapStringObject(userMap['userProperties']),
      groups: _castGroups(userMap['groups']),
      groupProperties: _castGroupProperties(userMap['groupProperties']),
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Converts a dartify() result (e.g. IdentityMap) to a plain Map. Shared for use by VariantCodec.
  static Map<String, dynamic>? toPlainMap(dynamic value) {
    if (value == null) return null;
    if (value is! Map) return null;
    return value.map<String, dynamic>(
      (Object? k, Object? v) => MapEntry(k.toString(), _toPlainValue(v)),
    );
  }

  static dynamic _toPlainValue(dynamic value) {
    if (value == null) return null;
    if (value is Map) return toPlainMap(value);
    if (value is List) return value.map(_toPlainValue).toList();
    return value;
  }

  static Map<String, Object>? _castMapStringObject(dynamic value) {
    final m = toPlainMap(value);
    if (m == null) return null;
    return m.map((k, v) => MapEntry(k, v as Object));
  }

  static Map<String, List<String>>? _castGroups(dynamic value) {
    if (value == null) return null;
    if (value is! Map) return null;
    final plain = toPlainMap(value);
    if (plain == null) return null;
    return plain.map((k, v) {
      if (v is List) {
        return MapEntry(k, v.map((e) => e.toString()).toList());
      }
      return MapEntry(k, <String>[]);
    });
  }

  static Map<String, Map<String, Map<String, Object?>>>? _castGroupProperties(
    dynamic value,
  ) {
    if (value == null) return null;
    final m = toPlainMap(value);
    if (m == null) return null;
    final result = <String, Map<String, Map<String, Object?>>>{};
    for (final entry in m.entries) {
      final inner = toPlainMap(entry.value);
      if (inner == null) continue;
      result[entry.key] = inner.map((k, v) {
        final inner2 = toPlainMap(v);
        if (inner2 == null) return MapEntry(k, <String, Object?>{});
        return MapEntry(
          k,
          inner2.map((k2, v2) => MapEntry(k2, v2 as Object?)),
        );
      });
    }
    return result;
  }
}
