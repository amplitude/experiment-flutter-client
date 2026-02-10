import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/providers.dart';
import 'package:amplitude_experiment/src/web/codec/exposure_codec.dart';
import 'package:amplitude_experiment/src/web/codec/user_codec.dart';

/// Codec for converting ExperimentConfig between Dart and JS objects.
class ConfigCodec {
  /// Converts an ExperimentConfig to a JSObject for the JavaScript SDK.
  static JSObject toJSObject(
    ExperimentConfig c,
    // ExposureTrackingProvider? trackingProvider,
    // UserProvider? userProvider,
  ) {
    final config = c.pigeonConfig;

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
        (key, value) => MapEntry(key, value.encode()),
      );
    }
    if (config.fallbackVariant.key != null ||
        config.fallbackVariant.value != null) {
      configMap['fallbackVariant'] = config.fallbackVariant.encode();
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

    final configObj = configMap.jsify() as JSObject;
    if (c.trackingProvider != null) {
      configObj['exposureTrackingProvider'] = _buildTrackingProviderJS(
        c.trackingProvider!,
      );
    }
    if (c.userProvider != null) {
      configObj['userProvider'] = _buildUserProviderJS(c.userProvider!);
    }

    return configObj;
  }

  static JSObject _buildTrackingProviderJS(ExposureTrackingProvider provider) {
    final obj = <String, dynamic>{}.jsify() as JSObject;
    obj['track'] = ((JSObject jsExposure) {
      final exposure = ExposureCodec.fromJSObject(jsExposure);
      provider.track(exposure);
    }).toJS;
    return obj;
  }

  static JSObject _buildUserProviderJS(UserProvider provider) {
    final obj = <String, dynamic>{}.jsify() as JSObject;
    obj['getUser'] = (() {
      final user = provider.getUser();
      return UserCodec.toJSObject(user);
    }).toJS;
    return obj;
  }
}
