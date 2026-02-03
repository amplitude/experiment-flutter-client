import 'package:amplitude_experiment/src/experiment_config.dart';
import 'package:amplitude_experiment/src/experiment_client.dart';

class Experiment {
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
