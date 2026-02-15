import 'package:flutter_test/flutter_test.dart';
import 'package:amplitude_experiment/amplitude_experiment.dart';
import 'package:amplitude_experiment/src/experiment_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExperimentPlatform
    with MockPlatformInterfaceMixin
    implements ExperimentPlatform {
  String? lastApiKey;
  ExperimentConfig? lastConfig;
  String? lastInstanceName;
  String? lastFlagKey;
  Variant? lastFallbackVariant;
  ExperimentUser? lastUser;
  bool? lastTracksAssignment;
  FetchOptions? lastFetchOptions;
  bool shouldThrowOnInit = false;
  final Map<String, ExposureTrackingProvider> _trackingProviderMap = {};

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
  Future<void> fetch(
    String instanceName,
    ExperimentUser? user,
    FetchOptions? options,
  ) async {
    lastInstanceName = instanceName;
    lastUser = user;
    lastFetchOptions = options;
  }

  @override
  Future<Variant> variant(
    String instanceName,
    ExperimentUser? user,
    String flagKey,
    Variant? fallbackVariant,
  ) async {
    lastInstanceName = instanceName;
    lastUser = user;
    lastFlagKey = flagKey;
    lastFallbackVariant = fallbackVariant;
    return Variant(key: flagKey, value: 'test-value');
  }

  @override
  Future<Map<String, Variant>> all(
    String instanceName,
    ExperimentUser? user,
  ) async {
    lastInstanceName = instanceName;
    lastUser = user;
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
  Future<void> setUser(String instanceName, ExperimentUser user) async {
    lastInstanceName = instanceName;
    lastUser = user;
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    lastInstanceName = instanceName;
    return ExperimentUser(userId: 'test-user');
  }

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) async {
    lastInstanceName = instanceName;
    lastTracksAssignment = tracksAssignment;
  }

  @override
  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {
    _trackingProviderMap[instanceName] = provider;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExperimentClient', () {
    late MockExperimentPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockExperimentPlatform();
      ExperimentPlatform.instance = mockPlatform;
    });

    group('initialization', () {
      test('calls platform.init via Experiment.initialize', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('test-api-key', config);

        expect(mockPlatform.lastApiKey, 'test-api-key');
        expect(
          mockPlatform.lastConfig?.pigeonConfig.instanceName,
          'test-instance',
        );
        // Verify client is usable immediately after await
        expect(client, isA<ExperimentClient>());
      });

      test(
        'calls platform.initWithAmplitude via Experiment.initializeWithAmplitude',
        () async {
          final config = ExperimentConfig(instanceName: 'test-instance');
          final client = await Experiment.initializeWithAmplitude(
            'test-api-key',
            config,
          );

          expect(mockPlatform.lastApiKey, 'test-api-key');
          expect(
            mockPlatform.lastConfig?.pigeonConfig.instanceName,
            'test-instance',
          );
          expect(client, isA<ExperimentClient>());
        },
      );

      test('throws when initialization fails', () async {
        mockPlatform.shouldThrowOnInit = true;
        final config = ExperimentConfig(instanceName: 'test-instance');

        expect(
          Experiment.initialize('test-api-key', config),
          throwsException,
        );
      });

      test('uses config instanceName for all platform calls', () async {
        final config = ExperimentConfig(instanceName: 'custom-instance');
        final client = await Experiment.initialize('key', config);

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
        final client = await Experiment.initialize('key', config);

        final user = ExperimentUser(userId: 'user-123');
        await client.start(user);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser?.userId, 'user-123');
      });

      test(
        'delegates to platform with instanceName and resolved user when null passed',
        () async {
          final config = ExperimentConfig(instanceName: 'test-instance');
          final client = await Experiment.initialize('key', config);

          await client.start(null);

          expect(mockPlatform.lastInstanceName, 'test-instance');
          expect(mockPlatform.lastUser, isNotNull);
        },
      );
    });

    group('stop', () {
      test('delegates to platform with instanceName', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        client.stop();

        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
      });
    });

    group('fetch', () {
      test('delegates to platform with user', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        final user = ExperimentUser(userId: 'user-123');
        await client.fetch(user);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastUser?.userId, 'user-123');
      });

      test('passes FetchOptions to platform', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        final user = ExperimentUser(userId: 'user-123');
        final options = FetchOptions(flagKeys: ['flag-1', 'flag-2']);
        await client.fetch(user, options);

        expect(mockPlatform.lastFetchOptions?.flagKeys, ['flag-1', 'flag-2']);
      });

      test(
        'delegates to platform with resolved user when no user passed',
        () async {
          final config = ExperimentConfig(instanceName: 'test-instance');
          final client = await Experiment.initialize('key', config);

          await client.fetch();

          expect(mockPlatform.lastInstanceName, 'test-instance');
          expect(mockPlatform.lastUser, isNotNull);
        },
      );
    });

    group('variant', () {
      test('delegates to platform with correct parameters', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

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
        final client = await Experiment.initialize('key', config);

        await client.variant('flag-key', null);

        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastFlagKey, 'flag-key');
        expect(mockPlatform.lastFallbackVariant, isNull);
      });
    });

    group('all', () {
      test('delegates to platform and returns all variants', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

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
        final client = await Experiment.initialize('key', config);

        client.clear();

        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
      });
    });

    group('exposure', () {
      test('delegates to platform with instanceName and flagKey', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        client.exposure('flag-key');

        await Future.delayed(Duration(milliseconds: 10));
        expect(mockPlatform.lastInstanceName, 'test-instance');
        expect(mockPlatform.lastFlagKey, 'flag-key');
      });
    });

    group('getUser', () {
      test('returns empty user when no user has been set', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        final user = await client.getUser();

        expect(user.userId, isNull);
      });

      test('returns stored user after setUser', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        await client.setUser(ExperimentUser(userId: 'user-123'));
        final user = await client.getUser();

        expect(user.userId, 'user-123');
      });
    });

    group('setUser', () {
      test('stores user locally', () async {
        final config = ExperimentConfig(instanceName: 'test-instance');
        final client = await Experiment.initialize('key', config);

        final user = ExperimentUser(userId: 'user-123');
        await client.setUser(user);

        expect((await client.getUser()).userId, 'user-123');
      });
    });

    group('user resolution', () {
      test('merges all scalar fields from provider when explicit user is empty',
          () async {
        final provider = _TestUserProvider(ExperimentUser(
          userId: 'provider-user',
          deviceId: 'provider-device',
          country: 'US',
          city: 'San Francisco',
          region: 'CA',
          dma: 'dma-1',
          language: 'en',
          platform: 'iOS',
          version: '2.0',
          os: 'iOS 17',
          deviceModel: 'iPhone',
          deviceBrand: 'Apple',
          deviceManufacturer: 'Apple Inc',
          carrier: 'Verizon',
          ipAddress: '1.2.3.4',
        ));
        final config = ExperimentConfig(
          instanceName: 'test-instance',
          userProvider: provider,
        );
        final client = await Experiment.initialize('key', config);

        await client.fetch(ExperimentUser());

        final merged = mockPlatform.lastUser!;
        expect(merged.userId, 'provider-user');
        expect(merged.deviceId, 'provider-device');
        expect(merged.country, 'US');
        expect(merged.city, 'San Francisco');
        expect(merged.region, 'CA');
        expect(merged.dma, 'dma-1');
        expect(merged.language, 'en');
        expect(merged.platform, 'iOS');
        expect(merged.version, '2.0');
        expect(merged.os, 'iOS 17');
        expect(merged.deviceModel, 'iPhone');
        expect(merged.deviceBrand, 'Apple');
        expect(merged.deviceManufacturer, 'Apple Inc');
        expect(merged.carrier, 'Verizon');
        expect(merged.ipAddress, '1.2.3.4');
      });

      test('sdk user fields take precedence over provider', () async {
        final provider = _TestUserProvider(ExperimentUser(
          userId: 'provider-user',
          country: 'GB',
          city: 'London',
          region: 'England',
          dma: 'provider-dma',
          carrier: 'provider-carrier',
          ipAddress: '10.0.0.1',
          deviceBrand: 'provider-brand',
        ));
        final config = ExperimentConfig(
          instanceName: 'test-instance',
          userProvider: provider,
        );
        final client = await Experiment.initialize('key', config);

        await client.fetch(ExperimentUser(
          userId: 'sdk-user',
          country: 'US',
          city: 'NYC',
          region: 'NY',
          dma: 'sdk-dma',
          carrier: 'sdk-carrier',
          ipAddress: '192.168.1.1',
          deviceBrand: 'sdk-brand',
        ));

        final merged = mockPlatform.lastUser!;
        expect(merged.userId, 'sdk-user');
        expect(merged.country, 'US');
        expect(merged.city, 'NYC');
        expect(merged.region, 'NY');
        expect(merged.dma, 'sdk-dma');
        expect(merged.carrier, 'sdk-carrier');
        expect(merged.ipAddress, '192.168.1.1');
        expect(merged.deviceBrand, 'sdk-brand');
      });

      test('merges map fields with sdk taking precedence', () async {
        final provider = _TestUserProvider(ExperimentUser(
          userProperties: {'color': 'blue', 'size': 'large'},
        ));
        final config = ExperimentConfig(
          instanceName: 'test-instance',
          userProvider: provider,
        );
        final client = await Experiment.initialize('key', config);

        await client.fetch(ExperimentUser(
          userProperties: {'color': 'red'},
        ));

        final merged = mockPlatform.lastUser!;
        expect(merged.userProperties?['color'], 'red');
        expect(merged.userProperties?['size'], 'large');
      });
    });

    group('setTracksAssignment', () {
      test(
        'delegates to platform with instanceName and tracksAssignment',
        () async {
          final config = ExperimentConfig(instanceName: 'test-instance');
          final client = await Experiment.initialize('key', config);

          client.setTracksAssignment(true);

          await Future.delayed(Duration(milliseconds: 10));
          expect(mockPlatform.lastInstanceName, 'test-instance');
          expect(mockPlatform.lastTracksAssignment, true);
        },
      );
    });
  });
}

class _TestUserProvider implements UserProvider {
  final ExperimentUser _user;
  _TestUserProvider(this._user);

  @override
  ExperimentUser getUser() => _user;
}
