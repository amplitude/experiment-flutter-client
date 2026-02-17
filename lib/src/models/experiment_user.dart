/// A user context for evaluating feature flags and experiments.
///
/// Pass to [ExperimentClient.fetch], [ExperimentClient.start], or
/// [ExperimentClient.setUser] to identify the user for flag evaluation.
/// Use [copyWith] to create modified copies without mutating the original.
class ExperimentUser {
  /// The unique device identifier.
  final String? deviceId;

  /// The unique user identifier.
  final String? userId;

  /// The user's country.
  final String? country;

  /// The user's city.
  final String? city;

  /// The user's region or state.
  final String? region;

  /// The user's Designated Market Area.
  final String? dma;

  /// The user's language.
  final String? language;

  /// The platform.
  final String? platform;

  /// The app version string.
  final String? version;

  /// The operating system.
  final String? os;

  /// The device model.
  final String? deviceModel;

  /// The device brand.
  ///
  /// Note: Not supported by the iOS native SDK; will be silently dropped on iOS.
  final String? deviceBrand;

  /// The device manufacturer.
  final String? deviceManufacturer;

  /// The mobile carrier name.
  final String? carrier;

  /// The SDK library identifier. Typically set automatically.
  final String? library;

  /// The user's IP address.
  ///
  /// Note: Not supported by the iOS native SDK; will be silently dropped on iOS.
  final String? ipAddress;

  /// Custom user properties for targeting.
  final Map<String, Object?>? userProperties;

  /// Group memberships as a map of group type to group names.
  final Map<String, List<String>>? groups;

  /// Group-level properties, keyed by group type, group name, then property name.
  final Map<String, Map<String, Map<String, Object?>>>? groupProperties;

  /// Creates an [ExperimentUser] with the given fields.
  const ExperimentUser({
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

  /// Returns a copy of this user with the given fields replaced.
  ///
  /// Fields that are not provided retain their current values.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          deviceId == other.deviceId;

  @override
  int get hashCode => Object.hash(userId, deviceId);

  @override
  String toString() => 'ExperimentUser(userId: $userId, deviceId: $deviceId)';
}
