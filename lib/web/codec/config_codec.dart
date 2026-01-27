import 'dart:js_interop';
import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/constants.dart';

/// Codec for converting ExperimentConfig between Dart and JS objects.
class ConfigCodec {
  /// Converts an ExperimentConfig to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(ExperimentConfig config) {
    final configMap = <String, dynamic>{
      'instanceName': config.instanceName,
      'fetchOnStart': config.fetchOnStart,
      'pollOnStart': config.pollOnStart,
      'retryFetchOnFailure': config.retryFetchOnFailure,
      'automaticExposureTracking': config.automaticExposureTracking,
      'automaticFetchOnAmplitudeIdentityChange':
          config.automaticFetchOnAmplitudeIdentityChange,
      'fetchTimeoutMillis': config.fetchTimeoutMillis,
    };

    if (config.serverUrl.isNotEmpty) {
      configMap['serverUrl'] = config.serverUrl;
    }
    if (config.flagsServerUrl.isNotEmpty) {
      configMap['flagsServerUrl'] = config.flagsServerUrl;
    }
    if (config.initialFlags != null) {
      configMap['initialFlags'] = config.initialFlags;
    }
    if (config.initialVariants.isNotEmpty) {
      configMap['initialVariants'] = config.initialVariants.map(
        (key, value) => MapEntry(key, value.toMap()),
      );
    }
    if (config.fallbackVariant.key != null ||
        config.fallbackVariant.value != null) {
      configMap['fallbackVariant'] = config.fallbackVariant.toMap();
    }

    // Convert source enum
    switch (config.source) {
      case Source.localStorage:
        configMap['source'] = 'localStorage';
        break;
      case Source.initialVariants:
        configMap['source'] = 'initialVariants';
        break;
    }

    // Convert serverZone enum
    switch (config.serverZone) {
      case ServerZone.us:
        configMap['serverZone'] = 'us';
        break;
      case ServerZone.eu:
        configMap['serverZone'] = 'eu';
        break;
    }

    return configMap.jsify() as JSObject;
  }
}
