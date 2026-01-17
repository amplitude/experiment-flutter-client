import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/models/variant.dart';
import 'package:experiment_flutter/constants.dart';

void main() {
  group('ExperimentConfig', () {
    test('uses default values when no parameters provided', () {
      final config = ExperimentConfig();

      expect(config.instanceName, '\$default_instance');
      expect(config.logLevel, LogLevel.warn);
      expect(config.source, Source.localStorage);
      expect(config.serverZone, ServerZone.us);
      expect(config.serverUrl, Constants.serverUrl);
      expect(config.retryFetchOnFailure, true);
    });

    test('toMap includes all fields', () {
      final config = ExperimentConfig(
        instanceName: 'custom-instance',
        logLevel: LogLevel.debug,
      );

      final map = config.toMap();

      expect(map['instanceName'], 'custom-instance');
      expect(map['logLevel'], 'debug');
      expect(map['source'], 'localStorage');
      expect(map['serverZone'], 'us');
      expect(map['fallbackVariant'], isA<Map>());
      expect(map['initialVariants'], isA<Map>());
    });

    test('toMap encodes Variant objects', () {
      final variant = Variant(key: 'test', value: 'value');
      final config = ExperimentConfig(fallbackVariant: variant);

      final map = config.toMap();

      expect(map['fallbackVariant'], isA<Map>());
      expect(map['fallbackVariant']['key'], 'test');
    });
  });
}
