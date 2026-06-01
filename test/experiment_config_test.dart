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

    // Regression tests for serverZone:EU being silently ignored because the
    // default US server URLs were always forwarded across the platform bridge,
    // defeating each native SDK's serverZone -> host resolution.
    test('default config still exposes the documented default URLs', () {
      final config = ExperimentConfig();
      expect(config.serverUrl, ExperimentConfigDefaults.serverUrl);
      expect(config.flagsServerUrl, ExperimentConfigDefaults.flagsServerUrl);
    });

    test(
      'default EU config does not forward default URLs so native resolves EU',
      () {
        final config = ExperimentConfig(serverZone: ServerZone.eu);
        final pigeon = config.pigeonConfig;
        // Empty sentinel => native SDK resolves the EU host from serverZone
        // (api.lab.eu.amplitude.com / flag.lab.eu.amplitude.com) instead of
        // being overridden by the forwarded US default.
        expect(pigeon.serverUrl, isEmpty);
        expect(pigeon.flagsServerUrl, isEmpty);
        expect(pigeon.serverUrl, isNot(contains('api.lab.amplitude.com')));
        expect(
          pigeon.flagsServerUrl,
          isNot(contains('flag.lab.amplitude.com')),
        );
      },
    );

    test(
      'default US config also withholds the default URLs from the bridge',
      () {
        final pigeon = ExperimentConfig().pigeonConfig;
        expect(pigeon.serverUrl, isEmpty);
        expect(pigeon.flagsServerUrl, isEmpty);
      },
    );

    test('explicit URL overrides are forwarded across the bridge', () {
      final config = ExperimentConfig(
        serverZone: ServerZone.eu,
        serverUrl: 'https://proxy.example.com',
        flagsServerUrl: 'https://flags.proxy.example.com',
      );
      final pigeon = config.pigeonConfig;
      expect(pigeon.serverUrl, 'https://proxy.example.com');
      expect(pigeon.flagsServerUrl, 'https://flags.proxy.example.com');
    });

    test(
      'explicitly passing a URL equal to the default is still forwarded',
      () {
        final config = ExperimentConfig(
          serverUrl: ExperimentConfigDefaults.serverUrl,
        );
        expect(
          config.pigeonConfig.serverUrl,
          ExperimentConfigDefaults.serverUrl,
        );
      },
    );

    test('a blank URL is treated as not set and not forwarded', () {
      final config = ExperimentConfig(
        serverZone: ServerZone.eu,
        serverUrl: '',
        flagsServerUrl: '',
      );
      // Blank normalizes to the default for reads, and is withheld from the
      // bridge so native serverZone resolution still applies.
      expect(config.serverUrl, ExperimentConfigDefaults.serverUrl);
      expect(config.flagsServerUrl, ExperimentConfigDefaults.flagsServerUrl);
      expect(config.pigeonConfig.serverUrl, isEmpty);
      expect(config.pigeonConfig.flagsServerUrl, isEmpty);
    });
  });
}
