import 'package:flutter_test/flutter_test.dart';
import 'package:amplitude_experiment/src/experiment_client.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/experiment_flutter_platform_interface.dart';
import 'package:amplitude_experiment/src/models/variant.dart';
import 'package:amplitude_experiment/src/models/experiment_user.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExperimentPlatform
    with MockPlatformInterfaceMixin
    implements ExperimentFlutterPlatform {
  String? lastApiKey;
  ExperimentConfig? lastConfig;
  String? lastInstanceName;
  String? lastFlagKey;
  Variant? lastFallbackVariant;
  ExperimentUser? lastUser;
  bool? lastTracksAssignment;
  bool shouldThrowOnInit = false;

  @override
  Future<void> init(String apiKey, ExperimentConfig config) async {
    if (shouldThrowOnInit) {
      throw Exception('Init failed');
    }
    lastApiKey = apiKey;
    lastConfig = config;
  }

  @override
  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) async {
    if (shouldThrowOnInit) {
      throw Exception('Init failed');
    }
    lastApiKey = apiKey;
    lastConfig = config;
  }

  @override
  Future<void> start(String instanceName, ExperimentUser? user) async {
    lastInstanceName = instanceName;
    lastUser = user;
  }

  @override
  Future<void> stop(String instanceName) async {
    lastInstanceName = instanceName;
  }

  @override
  Future<void> fetch(String instanceName, ExperimentUser? user) async {
    lastInstanceName = instanceName;
    lastUser = user;
  }

  @override
  Future<Variant> variant(
    String instanceName,
    String flagKey,
    Variant? fallbackVariant,
  ) async {
    lastInstanceName = instanceName;
    lastFlagKey = flagKey;
    lastFallbackVariant = fallbackVariant;
    return Variant(key: flagKey, value: 'test-value');
  }

  @override
  Future<Map<String, Variant>> all(String instanceName) async {
    lastInstanceName = instanceName;
    return {
      'flag1': Variant(key: 'flag1', value: 'value1'),
      'flag2': Variant(key: 'flag2', value: 'value2'),
    };
  }

  @override
  Future<void> clear(String instanceName) async {
    lastInstanceName = instanceName;
  }

  @override
  Future<void> exposure(String instanceName, String key) async {
    lastInstanceName = instanceName;
    lastFlagKey = key;
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    lastInstanceName = instanceName;
    return ExperimentUser(userId: 'test-user');
  }

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    lastInstanceName = instanceName;
    lastUser = user;
  }

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) async {
    lastInstanceName = instanceName;
    lastTracksAssignment = tracksAssignment;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExperimentClient', () {
    late MockExperimentPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockExperimentPlatform();
      ExperimentFlutterPlatform.instance = mockPlatform;
    });

    group('initialization', () {
      test('calls platform.init when withAnalytics is false', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'test-api-key',
          config: config,
          withAnalytics: false,
        );

        await client.isBuilt;

        expect(mockPlatform.lastApiKey, 'test-api-key');
        expect(mockPlatform.lastConfig?.instanceName, 'test-instance');
        expect(await client.isBuilt, true);
      });

      test(
        'calls platform.initWithAmplitude when withAnalytics is true',
        () async {
          final config = ExperimentConfig(instanceName: 'test-instance');
          final client = ExperimentClient(
            apiKey: 'test-api-key',
            config: config,
            withAnalytics: true,
          );

          await client.isBuilt;

          expect(mockPlatform.lastApiKey, 'test-api-key');
          expect(mockPlatform.lastConfig?.instanceName, 'test-instance');
          expect(await client.isBuilt, true);
        },
      );

      test('isBuilt returns false when initialization throws', () async {
        mockPlatform.shouldThrowOnInit = true;
        final config = ExperimentConfig();
        final client = ExperimentClient(
          apiKey: 'test-api-key',
          config: config,
          withAnalytics: false,
        );

        final result = await client.isBuilt;

        expect(result, false);
      });

      test('uses config instanceName for all platform calls', () async {
        final config = ExperimentConfig(instanceName: 'custom-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        await client.start(null);
        expect(mockPlatform.lastInstanceName, 'custom-instance');

        await client.fetch(null);
        expect(mockPlatform.lastInstanceName, 'custom-instance');

        await client.variant('flag-key', null);
        expect(mockPlatform.lastInstanceName, 'custom-instance');
      });
    });

    group('start', () {
      test('delegates to platform with instanceName and user', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        final user = ExperimentUser(userId: 'user-123');
        await client.start(user);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser?.userId, 'user-123');
      });

      test('delegates to platform with instanceName and null user', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        await client.start(null);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser, isNull);
      });
    });

    group('stop', () {
      test('delegates to platform with instanceName', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        client.stop();

        // Wait a bit for async operation
        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
      });
    });

    group('fetch', () {
      test('delegates to platform and returns self', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        final user = ExperimentUser(userId: 'user-123');
        final result = await client.fetch(user);

        expect(result, same(client));
        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser?.userId, 'user-123');
      });

      test('delegates to platform with null user', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        await client.fetch();

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser, isNull);
      });
    });

    group('variant', () {
      test('delegates to platform with correct parameters', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        final fallback = Variant(key: 'fallback', value: 'value');
        final variant = await client.variant('flag-key', fallback);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastFlagKey, 'flag-key');
        expect(mockPlatform.lastFallbackVariant?.key, 'fallback');
        expect(variant.key, 'flag-key');
        expect(variant.value, 'test-value');
      });

      test('delegates to platform with null fallback', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        await client.variant('flag-key', null);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastFlagKey, 'flag-key');
        expect(mockPlatform.lastFallbackVariant, isNull);
      });
    });

    group('all', () {
      test('delegates to platform and returns all variants', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        final all = await client.all();

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(all.length, 2);
        expect(all['flag1']?.key, 'flag1');
        expect(all['flag2']?.key, 'flag2');
      });
    });

    group('clear', () {
      test('delegates to platform with instanceName', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        client.clear();

        // Wait a bit for async operation
        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
      });
    });

    group('exposure', () {
      test('delegates to platform with instanceName and flagKey', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        client.exposure('flag-key');

        // Wait a bit for async operation
        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastFlagKey, 'flag-key');
      });
    });

    group('getUser', () {
      test('delegates to platform and returns user', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        final user = await client.getUser();

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(user.userId, 'test-user');
      });
    });

    group('setUser', () {
      test('delegates to platform with instanceName and user', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = ExperimentClient(
          apiKey: 'key',
          config: config,
          withAnalytics: false,
        );
        await client.isBuilt;

        final user = ExperimentUser(userId: 'user-123');
        client.setUser(user);

        // Wait a bit for async operation
        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser?.userId, 'user-123');
      });
    });

    group('setTracksAssignment', () {
      test(
        'delegates to platform with instanceName and tracksAssignment',
        () async {
          final config = ExperimentConfig(instanceName: 'test-instance');
          final client = ExperimentClient(
            apiKey: 'key',
            config: config,
            withAnalytics: false,
          );
          await client.isBuilt;

          client.setTracksAssignment(true);

          // Wait a bit for async operation
          await Future.delayed(Duration(milliseconds: 10));
          expect(mockPlatform.lastInstanceName, 'test-instance');
          expect(mockPlatform.lastTracksAssignment, true);
        },
      );
    });
  });
}
