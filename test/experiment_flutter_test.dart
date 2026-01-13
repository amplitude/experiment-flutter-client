import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_flutter/models/variant.dart';
import 'package:experiment_flutter/models/experiment_user.dart';
import 'package:experiment_flutter/experiment_client.dart';
import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/experiment.dart';
import 'package:experiment_flutter/experiment_flutter_platform_interface.dart';
import 'package:experiment_flutter/experiment_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExperimentFlutterPlatform
    with MockPlatformInterfaceMixin
    implements ExperimentFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> init(String apiKey, ExperimentConfig config) => Future.value();

  @override
  Future<void> initWithAmplitude(String apiKey, ExperimentConfig config) =>
      Future.value();

  @override
  Future<void> start(String instanceName, ExperimentUser? user) =>
      Future.value();

  @override
  Future<void> stop(String instanceName) => Future.value();

  @override
  Future<void> fetch(String instanceName, ExperimentUser? user) =>
      Future.value();

  @override
  Future<Variant> variant(
    String instanceName,
    String flagKey,
    Variant? fallbackVariant,
  ) => Future.value(Variant());

  @override
  Future<Map<String, Variant>> all(String instanceName) => Future.value({});

  @override
  Future<void> clear(String instanceName) => Future.value();

  @override
  Future<void> exposure(String instanceName, String flagKey) => Future.value();

  @override
  Future<ExperimentUser> getUser(String instanceName) => Future.value();

  @override
  Future<void> setUser(String instanceName, ExperimentUser user) =>
      Future.value();

  @override
  Future<void> setTracksAssignment(
    String instanceName,
    bool tracksAssignment,
  ) => Future.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ExperimentFlutterPlatform initialPlatform =
      MockExperimentFlutterPlatform();

  test('ExperimentFlutterPlatform is the default instance', () {
    expect(initialPlatform, isInstanceOf<ExperimentFlutterPlatform>());
  });

  test('initialize', () async {
    MockExperimentFlutterPlatform fakePlatform =
        MockExperimentFlutterPlatform();
    ExperimentFlutterPlatform.instance = fakePlatform;

    ExperimentClient experiment = Experiment.initialize(
      'apiKey',
      ExperimentConfig(),
    );

    await experiment.isBuilt;

    expect(await experiment.isBuilt, true);
  });

  // test('initialize with amplitude', () async {
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(
  //     await experimentFlutterPlugin.initializeWithAmplitude(
  //       'apiKey',
  //       ExperimentConfig(),
  //     ),
  //     true,
  //   );
  // });

  // test('start', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.start(), true);
  // });

  // test('stop', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.stop(), true);
  // });

  // test('fetch', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.fetch(), true);
  // });

  // test('getVariant', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.getVariant('flagKey'), true);
  // });

  // test('all', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.all(), true);
  // });

  // test('clear', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.clear(), true);
  // });

  // test('exposure', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.exposure('flagKey'), true);
  // });

  // test('getUser', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.getUser(), true);
  // });

  // test('setUser', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.setUser(ExperimentUser()), true);
  // });

  // test('setTracksAssignment', () async {
  //   Experiment experimentFlutterPlugin = Experiment();
  //   MockExperimentFlutterPlatform fakePlatform =
  //       MockExperimentFlutterPlatform();
  //   ExperimentFlutterPlatform.instance = fakePlatform;

  //   expect(await experimentFlutterPlugin.setTracksAssignment(true), true);
  // });
}
