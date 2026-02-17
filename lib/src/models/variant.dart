/// A feature flag variant containing the evaluated value and metadata.
///
/// Returned by [ExperimentClient.variant] and as values in the map from
/// [ExperimentClient.all]. Can also be used as a fallback variant in
/// [ExperimentConfig.fallbackVariant] or [ExperimentConfig.initialVariants].
class Variant {
  /// The variant key, typically used to identify the variant assignment.
  final String? key;

  /// The variant value, such as `'on'`, `'control'`, or `'treatment'`.
  final String? value;

  /// An optional dynamic payload attached to the variant.
  ///
  /// May be a JSON-decodable value (map, list, string, number, boolean, null).
  final Object? payload;

  /// The experiment key that produced this variant, if applicable.
  final String? expKey;

  /// Additional metadata associated with this variant.
  final Map<String, Object?>? metadata;

  /// Creates a [Variant] with the given fields.
  const Variant({
    this.key,
    this.value,
    this.payload,
    this.expKey,
    this.metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variant &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value &&
          expKey == other.expKey;

  @override
  int get hashCode => Object.hash(key, value, expKey);

  @override
  String toString() => 'Variant(key: $key, value: $value, expKey: $expKey)';
}
