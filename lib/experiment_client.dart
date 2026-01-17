import 'package:experiment_flutter/models/experiment_user.dart';
import 'package:experiment_flutter/models/variant.dart';
import 'package:experiment_flutter/experiment_config.dart';
import 'experiment_flutter_platform_interface.dart';

class ExperimentClient {
  final String apiKey;
  final ExperimentConfig config;
  late Future<bool> isBuilt;

  ExperimentClient({
    required this.apiKey,
    required this.config,
    required bool withAnalytics,
  }) {
    isBuilt = _init(withAnalytics);
  }

  Future<bool> _init(bool withAnalytics) async {
    try {
      if (withAnalytics) {
        await ExperimentFlutterPlatform.instance.initWithAmplitude(
          apiKey,
          config,
        );
      } else {
        await ExperimentFlutterPlatform.instance.init(apiKey, config);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> start(ExperimentUser? user) {
    return ExperimentFlutterPlatform.instance.start(config.instanceName, user);
  }

  void stop() async {
    return await ExperimentFlutterPlatform.instance.stop(config.instanceName);
  }

  Future<ExperimentClient> fetch([ExperimentUser? user]) async {
    await ExperimentFlutterPlatform.instance.fetch(config.instanceName, user);
    return this;
  }

  Future<Variant> variant(String flagKey, [Variant? fallbackVariant]) {
    return ExperimentFlutterPlatform.instance.variant(
      config.instanceName,
      flagKey,
      fallbackVariant,
    );
  }

  Future<Map<String, Variant>> all() {
    return ExperimentFlutterPlatform.instance.all(config.instanceName);
  }

  void clear() async {
    return await ExperimentFlutterPlatform.instance.clear(config.instanceName);
  }

  void exposure(String flagKey) async {
    return await ExperimentFlutterPlatform.instance.exposure(
      config.instanceName,
      flagKey,
    );
  }

  Future<ExperimentUser> getUser() {
    return ExperimentFlutterPlatform.instance.getUser(config.instanceName);
  }

  void setUser(ExperimentUser user) async {
    return await ExperimentFlutterPlatform.instance.setUser(
      config.instanceName,
      user,
    );
  }

  void setTracksAssignment(bool tracksAssignment) async {
    return await ExperimentFlutterPlatform.instance.setTracksAssignment(
      config.instanceName,
      tracksAssignment,
    );
  }
}
