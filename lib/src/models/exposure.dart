/// Describes a user's exposure to a feature flag variant.
///
/// Passed to [ExposureTrackingProvider.track] when automatic or manual
/// exposure tracking is triggered.
class Exposure {
  /// The key of the flag the user was exposed to.
  final String flagKey;

  /// The variant value the user was assigned, if any.
  final String? variant;

  /// The experiment key associated with this exposure, if applicable.
  final String? experimentKey;

  /// Additional metadata associated with this exposure event.
  final Map<String, Object?>? metadata;

  /// The timestamp of the exposure in milliseconds since epoch, if available.
  final int? time;

  /// Creates an [Exposure] for the given [flagKey].
  const Exposure({
    required this.flagKey,
    this.variant,
    this.experimentKey,
    this.metadata,
    this.time,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exposure &&
          runtimeType == other.runtimeType &&
          flagKey == other.flagKey &&
          variant == other.variant &&
          experimentKey == other.experimentKey;

  @override
  int get hashCode => Object.hash(flagKey, variant, experimentKey);

  @override
  String toString() =>
      'Exposure(flagKey: $flagKey, variant: $variant, experimentKey: $experimentKey)';
}
