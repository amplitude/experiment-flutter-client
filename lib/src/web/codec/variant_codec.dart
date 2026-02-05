import 'dart:js_interop';
import 'dart:convert';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

/// Codec for converting Variant objects between Dart and JS.
class VariantCodec {
  /// Converts a Variant to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(Variant variant) {
    return variant.encode().jsify() as JSObject;
  }

  /// Converts a JSObject from the JavaScript SDK to a Dart Variant.
  static Variant fromJSObject(JSObject variantObj) {
    // Convert JSObject to Dart Map first
    final dartified = variantObj.dartify();
    if (dartified == null) {
      return Variant();
    }

    // Convert LinkedMap<Object?, Object?> to Map<String, dynamic>
    final variantMap = Map<String, dynamic>.from(
      (dartified as Map).map((key, value) => MapEntry(key.toString(), value)),
    );

    final map = <String, dynamic>{};

    final key = variantMap['key'];
    if (key != null) {
      map['key'] = key.toString();
    }

    final value = variantMap['value'];
    if (value != null) {
      map['value'] = value.toString();
    }

    final payload = variantMap['payload'];
    if (payload != null) {
      if (payload is String) {
        map['payload'] = payload;
      } else {
        map['payload'] = jsonEncode(payload);
      }
    }

    final expKey = variantMap['expKey'];
    if (expKey != null) {
      map['expKey'] = expKey.toString();
    }

    final metadata = variantMap['metadata'];
    if (metadata != null) {
      map['metadata'] = jsonEncode(metadata);
    }

    return Variant.decode(map);
  }
}
