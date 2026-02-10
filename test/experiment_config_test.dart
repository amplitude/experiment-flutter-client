import 'package:flutter_test/flutter_test.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

void main() {
  group('ExperimentConfig', () {
    test('uses default values when no parameters provided', () {
      final config = ExperimentConfig(instanceName: 'test-instance');
      expect(config.pigeonConfig.instanceName, 'test-instance');
    });

    test('uses provided values when provided', () {
      final config = ExperimentConfig(
        instanceName: 'test-instance',
        logLevel: LogLevel.debug,
        source: Source.initialVariants,
        serverZone: ServerZone.eu,
        serverUrl: 'https://test.com',
        flagsServerUrl: 'https://test.com',
        initialFlags: 'test-flags',
        initialVariants: {
          'test-variant': Variant(key: 'test-variant', value: 'test-value'),
        },
        fallbackVariant: Variant(
          key: 'test-fallback-variant',
          value: 'test-fallback-value',
        ),
      );
      expect(config.pigeonConfig.instanceName, 'test-instance');
      expect(config.pigeonConfig.logLevel, LogLevel.debug);
      expect(config.pigeonConfig.source, Source.initialVariants);
      expect(config.pigeonConfig.serverZone, ServerZone.eu);
      expect(config.pigeonConfig.serverUrl, 'https://test.com');
      expect(config.pigeonConfig.flagsServerUrl, 'https://test.com');
      expect(config.pigeonConfig.initialFlags, 'test-flags');
      expect(config.pigeonConfig.initialVariants, {
        'test-variant': Variant(key: 'test-variant', value: 'test-value'),
      });
      expect(
        config.pigeonConfig.fallbackVariant,
        Variant(key: 'test-fallback-variant', value: 'test-fallback-value'),
      );
    });
  });
}
