import 'dart:js_interop';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

/// Codec for converting FetchOptions between Dart and JS.
class OptionsCodec {
  static JSObject toJSObject(FetchOptions options) {
    final map = <String, dynamic>{};
    if (options.flagKeys != null) {
      map['flagKeys'] = options.flagKeys;
    }
    return map.jsify() as JSObject;
  }
}
