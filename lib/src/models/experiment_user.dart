import 'dart:convert';

class ExperimentUser {
  final String? deviceId;
  final String? userId;
  final String? country;
  final String? city;
  final String? region;
  final String? dma;
  final String? language;
  final String? platform;
  final String? version;
  final String? os;
  final String? deviceModel;
  final String? deviceBrand;
  final String? deviceManufacturer;
  final String? carrier;
  final String? library;
  final String? ipAddress;
  final Map<String, dynamic>? userProperties;
  final Map<String, List<String>>? groups;
  final Map<String, dynamic>? groupProperties;

  ExperimentUser({
    this.deviceId,
    this.userId,
    this.country,
    this.city,
    this.region,
    this.dma,
    this.language,
    this.platform,
    this.version,
    this.os,
    this.deviceModel,
    this.deviceBrand,
    this.deviceManufacturer,
    this.carrier,
    this.library,
    this.ipAddress,
    this.userProperties,
    this.groups,
    this.groupProperties,
  });

  Map<String, dynamic> toMap() {
    return {
      if (deviceId != null) 'deviceId': deviceId,
      if (userId != null) 'userId': userId,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      if (region != null) 'region': region,
      if (dma != null) 'dma': dma,
      if (language != null) 'language': language,
      if (platform != null) 'platform': platform,
      if (version != null) 'version': version,
      if (os != null) 'os': os,
      if (deviceModel != null) 'deviceModel': deviceModel,
      if (deviceBrand != null) 'deviceBrand': deviceBrand,
      if (deviceManufacturer != null) 'deviceManufacturer': deviceManufacturer,
      if (carrier != null) 'carrier': carrier,
      if (library != null) 'library': library,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userProperties != null) 'userProperties': jsonEncode(userProperties),
      if (groups != null) 'groups': jsonEncode(groups),
      if (groupProperties != null)
        'groupProperties': jsonEncode(groupProperties),
    };
  }

  factory ExperimentUser.fromMap(Map<String, dynamic> map) {
    // Helper function to decode JSON string or return null
    Map<String, dynamic>? decodeUserProperties(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return jsonDecode(value) as Map<String, dynamic>?;
      }
      // If already a Map (from native), use it directly
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    // Helper function to decode groups (Map<String, List<String>>)
    Map<String, List<String>>? decodeGroups(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        final decoded = jsonDecode(value) as Map<String, dynamic>?;
        if (decoded == null) return null;
        return decoded.map(
          (key, val) =>
              MapEntry(key, (val as List).map((e) => e.toString()).toList()),
        );
      }
      // If already a Map (from native), convert it
      if (value is Map) {
        return value.map(
          (key, val) => MapEntry(
            key.toString(),
            (val is List)
                ? val.map((e) => e.toString()).toList()
                : [val.toString()],
          ),
        );
      }
      return null;
    }

    // Helper function to decode groupProperties
    Map<String, dynamic>? decodeGroupProperties(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return jsonDecode(value) as Map<String, dynamic>?;
      }
      // If already a Map (from native), use it directly
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    return ExperimentUser(
      deviceId: map['deviceId'] as String?,
      userId: map['userId'] as String?,
      country: map['country'] as String?,
      city: map['city'] as String?,
      region: map['region'] as String?,
      dma: map['dma'] as String?,
      language: map['language'] as String?,
      platform: map['platform'] as String?,
      version: map['version'] as String?,
      os: map['os'] as String?,
      deviceModel: map['deviceModel'] as String?,
      deviceBrand: map['deviceBrand'] as String?,
      deviceManufacturer: map['deviceManufacturer'] as String?,
      carrier: map['carrier'] as String?,
      library: map['library'] as String?,
      ipAddress: map['ipAddress'] as String?,
      userProperties: decodeUserProperties(map['userProperties']),
      groups: decodeGroups(map['groups']),
      groupProperties: decodeGroupProperties(map['groupProperties']),
    );
  }
}
