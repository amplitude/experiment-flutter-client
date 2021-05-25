import 'dart:convert';

class Variant {
  final String value;
  final dynamic payload;

  Variant({
    required this.value,
    required this.payload,
  });

  Variant copyWith({
    String? value,
    dynamic payload,
  }) {
    return Variant(
      value: value ?? this.value,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'payload': payload,
    };
  }

  factory Variant.fromMap(Map<String, dynamic> map) {
    return Variant(
      value: map['value'],
      payload: map['payload'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Variant.fromJson(String source) =>
      Variant.fromMap(json.decode(source));

  @override
  String toString() => 'Variant(value: $value, payload: $payload)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Variant && other.value == value && other.payload == payload;
  }

  @override
  int get hashCode => value.hashCode ^ payload.hashCode;
}
