import 'dart:js_interop';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/web/codec/codec_utils.dart';

class ExposureCodec {
  static Map<String, dynamic> toMap(Exposure exposure) {
    final map = <String, dynamic>{
      'flag_key': exposure.flagKey,
    };
    if (exposure.variant != null) map['variant'] = exposure.variant;
    if (exposure.experimentKey != null) {
      map['experiment_key'] = exposure.experimentKey;
    }
    if (exposure.metadata != null) map['metadata'] = exposure.metadata;
    if (exposure.time != null) map['time'] = exposure.time;
    return map;
  }

  static JSObject toJSObject(Exposure exposure) {
    return toMap(exposure).jsify() as JSObject;
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
