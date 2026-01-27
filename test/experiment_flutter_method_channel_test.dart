import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_flutter/experiment_flutter_method_channel.dart';
import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/models/experiment_user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelExperimentFlutter platform;
  const MethodChannel channel = MethodChannel('experiment_flutter');

  setUp(() {
    platform = MethodChannelExperimentFlutter();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('init', () {
    test('sends correct method call with apiKey and config', () async {
      MethodCall? receivedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            receivedCall = call;
            return null;
          });

      final config = ExperimentConfig(instanceName: 'test-instance');
      await platform.init('test-api-key', config);

      expect(receivedCall?.method, 'init');
      expect(receivedCall?.arguments['apiKey'], 'test-api-key');
      expect(receivedCall?.arguments['config'], isA<Map>());
      expect(
        receivedCall?.arguments['config']['instanceName'],
        'test-instance',
      );
    });
  });

  group('fetch', () {
    test('sends instanceName and user when provided', () async {
      MethodCall? receivedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            receivedCall = call;
            return null;
          });

      final user = ExperimentUser(userId: 'user-123');
      await platform.fetch('test-instance', user);

      expect(receivedCall?.method, 'fetch');
      expect(receivedCall?.arguments['instanceName'], 'test-instance');
      expect(receivedCall?.arguments['user'], isA<Map>());
      expect(receivedCall?.arguments['user']['userId'], 'user-123');
    });

    test('sends instanceName without user when user is null', () async {
      MethodCall? receivedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            receivedCall = call;
            return null;
          });

      await platform.fetch('test-instance', null);

      expect(receivedCall?.method, 'fetch');
      expect(receivedCall?.arguments['instanceName'], 'test-instance');
      expect(receivedCall?.arguments.containsKey('user'), false);
    });
  });

  group('variant', () {
    test('parses response into Variant object', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            return {
              'key': 'test-key',
              'value': 'test-value',
              'expKey': 'exp-123',
            };
          });

      final variant = await platform.variant('test-instance', 'flag-key', null);

      expect(variant.key, 'test-key');
      expect(variant.value, 'test-value');
      expect(variant.expKey, 'exp-123');
    });

    test('handles null response with empty Variant', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      final variant = await platform.variant('test-instance', 'flag-key', null);

      expect(variant.key, isNull);
      expect(variant.value, isNull);
    });
  });

  group('all', () {
    test('parses response into Map of Variants', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            return {
              'flag1': {'key': 'flag1', 'value': 'value1'},
              'flag2': {'key': 'flag2', 'value': 'value2'},
            };
          });

      final all = await platform.all('test-instance');

      expect(all.length, 2);
      expect(all['flag1']?.key, 'flag1');
      expect(all['flag2']?.key, 'flag2');
    });
  });
}
