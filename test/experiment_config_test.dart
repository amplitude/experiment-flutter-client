import 'package:flutter_test/flutter_test.dart';
import 'package:amplitude_experiment/src/experiment_config_builder.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/constants.dart';

void main() {
  group('ExperimentConfigBuilder', () {
    test('uses default values when no parameters provided', () {
      final config = createExperimentConfig();
      expect(config.instanceName, '\$default_instance');
      expect(config.logLevel, LogLevel.warn);
      expect(config.source, Source.localStorage);
      expect(config.serverZone, ServerZone.us);
      expect(config.serverUrl, Constants.serverUrl);
      expect(config.retryFetchOnFailure, true);
      expect(config.automaticExposureTracking, true);
      expect(config.fetchOnStart, true);
      expect(config.pollOnStart, false);
      expect(config.automaticFetchOnAmplitudeIdentityChange, false);
      expect(config.fetchTimeoutMillis, 10000);
      expect(config.flagsServerUrl, Constants.flagsServerUrl);
      expect(config.initialFlags, null);
      expect(config.initialVariants, isA<Map>());
      expect(config.fallbackVariant, isA<Variant>());
    });
  });
}
