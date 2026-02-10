import 'dart:js_interop';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/codec/codec_utils.dart';

class ExposureCodec {
  static JSObject toJSObject(Exposure exposure) {
    return exposure.encode().jsify() as JSObject;
  }

  static Exposure fromJSObject(JSObject obj) {
    final map = CodecUtils.toPlainMap(obj.dartify());
    return Exposure(
      flagKey: map?['flag_key']?.toString() ?? '',
      variant: map?['variant']?.toString(),
      experimentKey: map?['experiment_key']?.toString(),
      metadata: CodecUtils.toPlainMap(
        map?['metadata'],
      )?.cast<String, Object?>(),
      time: map?['time']?.toInt(),
    );
  }
}
