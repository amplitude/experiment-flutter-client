import 'experiment_flutter_platform_interface.dart';
import 'experiment_config.dart';
import 'experiment_client.dart';

class Experiment {
  Future<String?> getPlatformVersion() {
    return ExperimentFlutterPlatform.instance.getPlatformVersion();
  }

  static ExperimentClient initialize(String apiKey, ExperimentConfig config) {
    return ExperimentClient(
      apiKey: apiKey,
      config: config,
      withAnalytics: false,
    );
  }

  static ExperimentClient initializeWithAmplitude(
    String apiKey,
    ExperimentConfig config,
  ) {
    return ExperimentClient(
      apiKey: apiKey,
      config: config,
      withAnalytics: true,
    );
  }
}
