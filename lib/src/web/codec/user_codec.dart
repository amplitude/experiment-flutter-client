import 'dart:js_interop';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/codec/codec_utils.dart';

/// Codec for converting ExperimentUser objects between Dart and JS.
class UserCodec {
  static const _flutterLibraryVersion =
      '0.1.0-beta.2'; // x-release-please-version
  static const _flutterLibrary =
      'experiment-flutter-client/${_flutterLibraryVersion}_experiment-js-client';

  /// Converts an ExperimentUser to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(ExperimentUser user) {
    final userMap = <String, dynamic>{};

    if (user.deviceId != null) userMap['device_id'] = user.deviceId;
    if (user.userId != null) userMap['user_id'] = user.userId;
    if (user.country != null) userMap['country'] = user.country;
    if (user.city != null) userMap['city'] = user.city;
    if (user.region != null) userMap['region'] = user.region;
    if (user.dma != null) userMap['dma'] = user.dma;
    if (user.language != null) userMap['language'] = user.language;
    if (user.platform != null) userMap['platform'] = user.platform;
    if (user.version != null) userMap['version'] = user.version;
    if (user.os != null) userMap['os'] = user.os;
    if (user.deviceModel != null) userMap['device_model'] = user.deviceModel;
    if (user.deviceBrand != null) userMap['device_brand'] = user.deviceBrand;
    if (user.deviceManufacturer != null) {
      userMap['device_manufacturer'] = user.deviceManufacturer;
    }
    if (user.carrier != null) userMap['carrier'] = user.carrier;
    userMap['library'] = user.library ?? _flutterLibrary;
    if (user.ipAddress != null) userMap['ip_address'] = user.ipAddress;
    if (user.userProperties != null) {
      userMap['user_properties'] = user.userProperties;
    }
    if (user.groups != null) {
      userMap['groups'] = user.groups;
    }
    if (user.groupProperties != null) {
      userMap['group_properties'] = user.groupProperties;
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
    final userMap = CodecUtils.toPlainMap(dartified);
    if (userMap == null) {
      return ExperimentUser();
    }

    return ExperimentUser(
      deviceId: CodecUtils.stringOrNull(userMap['device_id']),
      userId: CodecUtils.stringOrNull(userMap['user_id']),
      country: CodecUtils.stringOrNull(userMap['country']),
      city: CodecUtils.stringOrNull(userMap['city']),
      region: CodecUtils.stringOrNull(userMap['region']),
      dma: CodecUtils.stringOrNull(userMap['dma']),
      language: CodecUtils.stringOrNull(userMap['language']),
      platform: CodecUtils.stringOrNull(userMap['platform']),
      version: CodecUtils.stringOrNull(userMap['version']),
      os: CodecUtils.stringOrNull(userMap['os']),
      deviceModel: CodecUtils.stringOrNull(userMap['device_model']),
      deviceBrand: CodecUtils.stringOrNull(userMap['device_brand']),
      deviceManufacturer: CodecUtils.stringOrNull(
        userMap['device_manufacturer'],
      ),
      carrier: CodecUtils.stringOrNull(userMap['carrier']),
      library: CodecUtils.stringOrNull(userMap['library']),
      ipAddress: CodecUtils.stringOrNull(userMap['ip_address']),
      userProperties: CodecUtils.castMapStringObject(
        userMap['user_properties'],
      ),
      groups: CodecUtils.castGroups(userMap['groups']),
      groupProperties: CodecUtils.castGroupProperties(
        userMap['group_properties'],
      ),
    );
  }
}
