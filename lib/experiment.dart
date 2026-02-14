import 'package:amplitude_experiment/src/experiment_client.dart';
import 'package:amplitude_experiment/src/experiment_client_impl.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';

class Experiment {
  static Future<ExperimentClient> initialize(
    String apiKey,
    ExperimentConfig config,
  ) {
    return ExperimentClientImpl.create(
      apiKey: apiKey,
      config: config,
      withAnalytics: false,
    );
  }

  static Future<ExperimentClient> initializeWithAmplitude(
    String apiKey,
    ExperimentConfig config,
  ) {
    return ExperimentClientImpl.create(
      apiKey: apiKey,
      config: config,
      withAnalytics: true,
    );
  }
}
