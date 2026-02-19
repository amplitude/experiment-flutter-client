/// Options for customizing a [ExperimentClient.fetch] request.
class FetchOptions {
  /// An optional list of flag keys to fetch.
  ///
  /// When provided, only the specified flags are fetched from the server.
  /// When `null`, all flags for the user are fetched.
  final List<String>? flagKeys;

  /// Creates [FetchOptions] with an optional list of [flagKeys] to fetch.
  const FetchOptions({this.flagKeys});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchOptions &&
          runtimeType == other.runtimeType &&
          _listEquals(flagKeys, other.flagKeys);

  @override
  int get hashCode => Object.hashAll(flagKeys ?? const []);

  @override
  String toString() => 'FetchOptions(flagKeys: $flagKeys)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
