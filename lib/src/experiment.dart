import 'package:amplitude_experiment/src/experiment_client.dart';
import 'package:amplitude_experiment/src/experiment_client_impl.dart';
import 'package:amplitude_experiment/src/experiment_config.dart';

/// Entry point for creating [ExperimentClient] instances.
///
/// Use [initialize] to create a standalone client, or
/// [initializeWithAmplitude] to create a client that shares identity
/// and lifecycle with an existing Amplitude Analytics instance.
///
/// ```dart
/// final client = await Experiment.initialize('API_KEY', ExperimentConfig());
/// ```
class Experiment {
  /// Creates an [ExperimentClient] configured with the given [apiKey].
  ///
  /// The client operates independently and does not share user identity
  /// with Amplitude Analytics. Use [initializeWithAmplitude] if you want
  /// automatic identity resolution from an Analytics instance.
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

  /// Creates an [ExperimentClient] that integrates with Amplitude Analytics.
  ///
  /// The client automatically shares user identity and lifecycle events
  /// with the Amplitude Analytics SDK identified by [apiKey].
  ///
  /// **Important:** The [ExperimentConfig.instanceName] must exactly match
  /// (case-sensitive) the instance name used when initializing the Amplitude
  /// Analytics SDK. If the names do not match, the integration will fail to
  /// locate the Analytics instance. Both SDKs default to `$default_instance`,
  /// so no action is needed when using a single default instance of each.
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
