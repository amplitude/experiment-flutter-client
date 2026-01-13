import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_flutter/experiment_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelExperimentFlutter platform = MethodChannelExperimentFlutter();
  const MethodChannel channel = MethodChannel('experiment_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
