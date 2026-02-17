import 'package:amplitude_experiment/src/models/experiment_user.dart';
import 'package:amplitude_experiment/src/models/variant.dart';
import 'package:amplitude_experiment/src/models/fetch_options.dart';

/// Public interface for interacting with the Amplitude Experiment SDK.
///
/// Obtain an instance via [Experiment.initialize] or
/// [Experiment.initializeWithAmplitude]. Do not implement or extend.
abstract class ExperimentClient {
  /// Starts the SDK, optionally setting the initial [user] context.
  ///
  /// Must be called before [fetch] or [variant] if the server requires
  /// a user for flag evaluation.
  Future<void> start(ExperimentUser? user);

  /// Stops the SDK and releases resources.
  Future<void> stop();

  /// Fetches flag variants from the server for the given [user].
  ///
  /// Optionally pass [options] to limit which flags are fetched.
  /// If [user] is omitted, the most recently resolved user is used.
  Future<void> fetch([
    ExperimentUser? user,
    FetchOptions? options,
  ]);

  /// Returns the variant for a single [flagKey].
  ///
  /// If the flag has no value, returns [fallbackVariant] (or an empty
  /// [Variant] if not provided).
  Future<Variant> variant(String flagKey, [Variant? fallbackVariant]);

  /// Returns all flag variants currently assigned to the user.
  Future<Map<String, Variant>> all();

  /// Clears all locally stored flag data.
  Future<void> clear();

  /// Manually triggers an exposure event for the given [flagKey].
  Future<void> exposure(String flagKey);

  /// Returns the current user context.
  Future<ExperimentUser> getUser();

  /// Sets the user context for subsequent flag evaluations.
  Future<void> setUser(ExperimentUser user);

  /// Enables or disables automatic assignment tracking.
  Future<void> setTracksAssignment(bool tracksAssignment);
}
