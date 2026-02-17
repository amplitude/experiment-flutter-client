import 'package:amplitude_experiment/src/models/exposure.dart';
import 'package:amplitude_experiment/src/models/experiment_user.dart';

/// Receives exposure events when a user is exposed to a variant.
///
/// Implement this interface and pass it to [ExperimentConfig.trackingProvider]
/// to receive exposure tracking callbacks. Typically used to forward exposures
/// to an analytics provider.
abstract interface class ExposureTrackingProvider {
  /// Called when a user is exposed to a flag variant.
  void track(Exposure exposure);
}

/// Provides the current user context for flag evaluation.
///
/// Implement this interface and pass it to [ExperimentConfig.userProvider]
/// to automatically supply user context for all SDK operations. The SDK
/// merges the provider's user with any explicitly provided user, with
/// explicit values taking precedence.
abstract interface class UserProvider {
  /// Returns the current user context.
  ExperimentUser getUser();
}
