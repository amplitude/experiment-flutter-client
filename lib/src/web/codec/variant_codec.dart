import 'dart:js_interop';
import 'dart:convert';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/codec/user_codec.dart';

/// Codec for converting Variant objects between Dart and JS.
class VariantCodec {
  /// Converts a Variant to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(Variant variant) {
    return variant.encode().jsify() as JSObject;
  }

  /// Converts a JSObject from the JavaScript SDK to a Dart Variant.
  static Variant fromJSObject(JSObject variantObj) {
    final dartified = variantObj.dartify();
    if (dartified == null) {
      return Variant();
    }

    // Normalize to a plain Map (dartify() can return IdentityMap, etc.)
    final variantMap = UserCodec.toPlainMap(dartified);
    if (variantMap == null) {
      return Variant();
    }

    final key = variantMap['key'];
    final value = variantMap['value'];
    final payload = variantMap['payload'];
    final expKey = variantMap['expKey'];
    final metadataRaw = variantMap['metadata'];

    Object? payloadObj;
    if (payload != null) {
      payloadObj = payload is String ? payload : jsonDecode(jsonEncode(payload));
    }

    Map<String, Object?>? metadataMap;
    if (metadataRaw != null && metadataRaw is Map) {
      final plain = UserCodec.toPlainMap(metadataRaw);
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
