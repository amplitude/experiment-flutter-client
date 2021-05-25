import 'dart:convert';

class SkylabUser {
    final String userId;
    final String deviceId;
    final String country;
    final String region;
    final String dma;
    final String city;
    final String language;
    final String platform;
    final String version;
    final String os;
    final String deviceFamily;
    final String deviceType;
    final String deviceManufacturer;
    final String deviceBrand;
    final String deviceModel;
    final String carrier;
    final String library;

  SkylabUser({
    required this.userId,
    required this.deviceId,
    required this.country,
    required this.region,
    required this.dma,
    required this.city,
    required this.language,
    required this.platform,
    required this.version,
    required this.os,
    required this.deviceFamily,
    required this.deviceType,
    required this.deviceManufacturer,
    required this.deviceBrand,
    required this.deviceModel,
    required this.carrier,
    required this.library,
  });

  SkylabUser copyWith({
    String? userId,
    String? deviceId,
    String? country,
    String? region,
    String? dma,
    String? city,
    String? language,
    String? platform,
    String? version,
    String? os,
    String? deviceFamily,
    String? deviceType,
    String? deviceManufacturer,
    String? deviceBrand,
    String? deviceModel,
    String? carrier,
    String? library,
  }) {
    return SkylabUser(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      country: country ?? this.country,
      region: region ?? this.region,
      dma: dma ?? this.dma,
      city: city ?? this.city,
      language: language ?? this.language,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      os: os ?? this.os,
      deviceFamily: deviceFamily ?? this.deviceFamily,
      deviceType: deviceType ?? this.deviceType,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      carrier: carrier ?? this.carrier,
      library: library ?? this.library,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'country': country,
      'region': region,
      'dma': dma,
      'city': city,
      'language': language,
      'platform': platform,
      'version': version,
      'os': os,
      'deviceFamily': deviceFamily,
      'deviceType': deviceType,
      'deviceManufacturer': deviceManufacturer,
      'deviceBrand': deviceBrand,
      'deviceModel': deviceModel,
      'carrier': carrier,
      'library': library,
    };
  }

  factory SkylabUser.fromMap(Map<String, dynamic> map) {
    return SkylabUser(
      userId: map['userId'],
      deviceId: map['deviceId'],
      country: map['country'],
      region: map['region'],
      dma: map['dma'],
      city: map['city'],
      language: map['language'],
      platform: map['platform'],
      version: map['version'],
      os: map['os'],
      deviceFamily: map['deviceFamily'],
      deviceType: map['deviceType'],
      deviceManufacturer: map['deviceManufacturer'],
      deviceBrand: map['deviceBrand'],
      deviceModel: map['deviceModel'],
      carrier: map['carrier'],
      library: map['library'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SkylabUser.fromJson(String source) => SkylabUser.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SkylabUser(userId: $userId, deviceId: $deviceId, country: $country, region: $region, dma: $dma, city: $city, language: $language, platform: $platform, version: $version, os: $os, deviceFamily: $deviceFamily, deviceType: $deviceType, deviceManufacturer: $deviceManufacturer, deviceBrand: $deviceBrand, deviceModel: $deviceModel, carrier: $carrier, library: $library)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SkylabUser &&
      other.userId == userId &&
      other.deviceId == deviceId &&
      other.country == country &&
      other.region == region &&
      other.dma == dma &&
      other.city == city &&
      other.language == language &&
      other.platform == platform &&
      other.version == version &&
      other.os == os &&
      other.deviceFamily == deviceFamily &&
      other.deviceType == deviceType &&
      other.deviceManufacturer == deviceManufacturer &&
      other.deviceBrand == deviceBrand &&
      other.deviceModel == deviceModel &&
      other.carrier == carrier &&
      other.library == library;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      deviceId.hashCode ^
      country.hashCode ^
      region.hashCode ^
      dma.hashCode ^
      city.hashCode ^
      language.hashCode ^
      platform.hashCode ^
      version.hashCode ^
      os.hashCode ^
      deviceFamily.hashCode ^
      deviceType.hashCode ^
      deviceManufacturer.hashCode ^
      deviceBrand.hashCode ^
      deviceModel.hashCode ^
      carrier.hashCode ^
      library.hashCode;
  }
}