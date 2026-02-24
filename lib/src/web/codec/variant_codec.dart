import 'dart:js_interop';
import 'dart:convert';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/codec/codec_utils.dart';

/// Codec for converting Variant objects between Dart and JS.
class VariantCodec {
  /// Converts a Variant to a plain Dart Map matching the JS SDK's Variant shape.
  static Map<String, dynamic> toMap(Variant variant) {
    final map = <String, dynamic>{};
    if (variant.key != null) map['key'] = variant.key;
    if (variant.value != null) map['value'] = variant.value;
    if (variant.payload != null) map['payload'] = variant.payload;
    if (variant.expKey != null) map['expKey'] = variant.expKey;
    if (variant.metadata != null) map['metadata'] = variant.metadata;
    return map;
  }

  /// Converts a Variant to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(Variant variant) {
    return toMap(variant).jsify() as JSObject;
  }

  /// Converts a JSObject from the JavaScript SDK to a Dart Variant.
  static Variant fromJSObject(JSObject variantObj) {
    final dartified = variantObj.dartify();
    if (dartified == null) {
      return Variant();
    }

    final variantMap = CodecUtils.toPlainMap(dartified);
    if (variantMap == null) {
      return Variant();
    }

    return fromMap(variantMap);
  }

  /// Converts a plain Dart Map to a Variant.
  static Variant fromMap(Map<String, dynamic> variantMap) {
    final key = variantMap['key'];
    final value = variantMap['value'];
    final payload = variantMap['payload'];
    final expKey = variantMap['expKey'];
    final metadataRaw = variantMap['metadata'];

    Object? payloadObj;
    if (payload != null) {
      payloadObj = payload is String
          ? payload
          : jsonDecode(jsonEncode(payload));
    }

    Map<String, Object?>? metadataMap;
    if (metadataRaw != null && metadataRaw is Map) {
      final plain = CodecUtils.toPlainMap(metadataRaw);
      if (plain != null) {
        metadataMap = plain.map((k, v) => MapEntry(k, v as Object?));
      }
    }

    return Variant(
      key: key?.toString(),
      value: value?.toString(),
      payload: payloadObj,
      expKey: expKey?.toString(),
      metadata: metadataMap,
    );
  }
}
