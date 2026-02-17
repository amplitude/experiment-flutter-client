import 'package:flutter_test/flutter_test.dart';
import 'package:amplitude_experiment/amplitude_experiment.dart';

void main() {
  group('ExperimentConfig', () {
    test('uses default values when no parameters provided', () {
      final config = ExperimentConfig(instanceName: 'test-instance');
      expect(config.instanceName, 'test-instance');
      expect(config.logLevel, LogLevel.warn);
      expect(config.source, Source.localStorage);
      expect(config.serverZone, ServerZone.us);
      expect(config.fallbackVariant, isNull);
      expect(config.initialVariants, isEmpty);
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
      expect(config.instanceName, 'test-instance');
      expect(config.logLevel, LogLevel.debug);
      expect(config.source, Source.initialVariants);
      expect(config.serverZone, ServerZone.eu);
      expect(config.serverUrl, 'https://test.com');
      expect(config.flagsServerUrl, 'https://test.com');
      expect(config.initialFlags, 'test-flags');
      expect(config.initialVariants.length, 1);
      expect(config.initialVariants['test-variant']?.key, 'test-variant');
      expect(config.fallbackVariant?.key, 'test-fallback-variant');
      expect(config.fallbackVariant?.value, 'test-fallback-value');
    });

    test('pigeonConfig converts fields correctly', () {
      final config = ExperimentConfig(
        instanceName: 'test-instance',
        serverUrl: 'https://test.com',
        fetchTimeoutMillis: 5000,
        retryFetchOnFailure: false,
      );
      final pigeon = config.pigeonConfig;
      expect(pigeon.instanceName, 'test-instance');
      expect(pigeon.serverUrl, 'https://test.com');
      expect(pigeon.fetchTimeoutMillis, 5000);
      expect(pigeon.retryFetchOnFailure, false);
    });
  });
}
