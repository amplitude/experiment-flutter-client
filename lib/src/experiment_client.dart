import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

/// Public interface for interacting with the Amplitude Experiment SDK.
///
/// Obtain an instance via [Experiment.initialize] or
/// [Experiment.initializeWithAmplitude]. Do not implement or extend.
abstract class ExperimentClient {
  Future<void> start(ExperimentUser? user);

  Future<void> stop();

  Future<void> fetch([
    ExperimentUser? user,
    FetchOptions? options,
  ]);

  Future<Variant> variant(String flagKey, [Variant? fallbackVariant]);

  Future<Map<String, Variant>> all();

  Future<void> clear();

  Future<void> exposure(String flagKey);

  Future<ExperimentUser> getUser();

  Future<void> setUser(ExperimentUser user);

  Future<void> setTracksAssignment(bool tracksAssignment);
}
