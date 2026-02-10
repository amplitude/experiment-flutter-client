class CodecUtils {
  static String? stringOrNull(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Converts a dartify() result (e.g. IdentityMap) to a plain Map. Shared for use by VariantCodec.
  static Map<String, dynamic>? toPlainMap(dynamic value) {
    if (value == null) return null;
    if (value is! Map) return null;
    return value.map<String, dynamic>(
      (Object? k, Object? v) => MapEntry(k.toString(), toPlainValue(v)),
    );
  }

  static dynamic toPlainValue(dynamic value) {
    if (value == null) return null;
    if (value is Map) return toPlainMap(value);
    if (value is List) return value.map(toPlainValue).toList();
    return value;
  }

  static Map<String, Object>? castMapStringObject(dynamic value) {
    final m = toPlainMap(value);
    if (m == null) return null;
    return m.map((k, v) => MapEntry(k, v as Object));
  }

  static Map<String, List<String>>? castGroups(dynamic value) {
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

  static Map<String, Map<String, Map<String, Object?>>>? castGroupProperties(
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
        return MapEntry(k, inner2.map((k2, v2) => MapEntry(k2, v2 as Object?)));
      });
    }
    return result;
  }
}
