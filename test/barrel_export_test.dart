/// Verifies that all public API symbols are accessible through the barrel file.
///
/// If this file compiles and the tests pass, the barrel file correctly
/// exports everything an integrator needs.
import 'package:flutter_test/flutter_test.dart';
import 'package:amplitude_experiment/amplitude_experiment.dart';

void main() {
  group('barrel exports', () {
    test('Experiment factory is accessible', () {
      // Experiment.initialize and Experiment.initializeWithAmplitude are
      // static methods; just verify the class is reachable.
      expect(Experiment, isNotNull);
    });

    test('ExperimentClient is accessible', () {
      // We can't construct one without a platform, but the type must resolve.
      expect(ExperimentClient, isNotNull);
    });

    test('ExperimentConfig is accessible', () {
      final config = ExperimentConfig(instanceName: 'barrel-test');
      expect(config.instanceName, 'barrel-test');
    });

    test('ExperimentUser is accessible', () {
      final user = ExperimentUser(userId: 'u1', deviceId: 'd1');
      expect(user.userId, 'u1');
      expect(user.deviceId, 'd1');
    });

    test('Variant is accessible', () {
      final v = Variant(key: 'k', value: 'v');
      expect(v.key, 'k');
      expect(v.value, 'v');
    });

    test('Exposure is accessible', () {
      final e = Exposure(flagKey: 'flag');
      expect(e.flagKey, 'flag');
    });

    test('FetchOptions is accessible', () {
      final opts = FetchOptions(flagKeys: ['a', 'b']);
      expect(opts.flagKeys, ['a', 'b']);
    });

    test('enums are accessible', () {
      expect(LogLevel.values, isNotEmpty);
      expect(Source.values, isNotEmpty);
      expect(ServerZone.values, isNotEmpty);
    });

    test('provider interfaces are accessible', () {
      // UserProvider and ExposureTrackingProvider should be reachable types.
      expect(UserProvider, isNotNull);
      expect(ExposureTrackingProvider, isNotNull);
    });
  });
}
