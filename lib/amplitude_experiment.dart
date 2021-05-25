
import 'dart:async';

import 'package:amplitude_experiment/variant.dart';
import 'package:flutter/services.dart';

class AmplitudeExperiment {

  static const MethodChannel _channel =
      const MethodChannel('amplitude_experiment');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<AmplitudeExperiment> init(String apiKey) async {
    await _channel.invokeMethod('initialize', {'apiKey': apiKey});
    return new AmplitudeExperiment();
  }

  Future<AmplitudeExperiment> start(String userId, String? deviceId) async {
    await _channel.invokeMethod('start', {'userId': userId, 'deviceId': deviceId});
    return this;
  }

  Future<Variant?> getVariant(String flagKey) async {
    var map = await _channel.invokeMapMethod<String, dynamic>('getVariant', {"flagKey": flagKey});
    if (map == null) return null;
    return Variant.fromMap(map);
  }
}
