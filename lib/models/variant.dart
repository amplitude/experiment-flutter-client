import 'dart:convert';

class Variant {
  final String? key;
  final String? value;
  final dynamic payload;
  final String? expKey;
  final Map<String, dynamic>? metadata;

  const Variant({
    this.key,
    this.value,
    this.payload,
    this.expKey,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (payload != null) 'payload': jsonEncode(payload),
      if (expKey != null) 'expKey': expKey,
      if (metadata != null) 'metadata': jsonEncode(metadata),
    };
  }

  factory Variant.fromMap(Map<String, dynamic> map) {
    final metadataString = map['metadata'] as String?;
    // print('metadataString: $metadataString');
    Map<String, dynamic>? metadata;
    if (metadataString != null) {
      metadata = jsonDecode(metadataString) as Map<String, dynamic>?;
    }
    final payloadString = map['payload'] as String?;
    dynamic payload;
    if (payloadString != null) {
      try {
        payload = jsonDecode(payloadString) as dynamic;
      } catch (e) {
        payload = payloadString;
      }
    }
    return Variant(
      key: map['key'] as String?,
      value: map['value'] as String?,
      payload: payload,
      expKey: map['expKey'] as String?,
      metadata: metadata,
    );
  }
}
