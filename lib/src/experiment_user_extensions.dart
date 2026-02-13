import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

extension ExperimentUserCopyWith on ExperimentUser {
  ExperimentUser copyWith({
    String? deviceId,
    String? userId,
    String? country,
    String? city,
    String? region,
    String? dma,
    String? language,
    String? platform,
    String? version,
    String? os,
    String? deviceModel,
    String? deviceBrand,
    String? deviceManufacturer,
    String? carrier,
    String? library,
    String? ipAddress,
    Map<String, Object?>? userProperties,
    Map<String, List<String>>? groups,
    Map<String, Map<String, Map<String, Object?>>>? groupProperties,
  }) {
    return ExperimentUser(
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      country: country ?? this.country,
      city: city ?? this.city,
      region: region ?? this.region,
      dma: dma ?? this.dma,
      language: language ?? this.language,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      os: os ?? this.os,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      carrier: carrier ?? this.carrier,
      library: library ?? this.library,
      ipAddress: ipAddress ?? this.ipAddress,
      userProperties: userProperties ?? this.userProperties,
      groups: groups ?? this.groups,
      groupProperties: groupProperties ?? this.groupProperties,
    );
  }
}
