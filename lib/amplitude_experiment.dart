/// Amplitude Experiment Flutter SDK.
///
/// Use [Experiment.initialize] or [Experiment.initializeWithAmplitude] to
/// create an [ExperimentClient], then call methods like [ExperimentClient.fetch]
/// and [ExperimentClient.variant] to evaluate feature flags.
library amplitude_experiment;

// Factory entry point
export 'src/experiment.dart';

// Core API
export 'src/experiment_client.dart';
export 'src/experiment_config.dart';

// Provider interfaces
export 'src/providers.dart';

// Public data models
export 'src/models/experiment_user.dart';
export 'src/models/variant.dart';
export 'src/models/exposure.dart';
export 'src/models/fetch_options.dart';
export 'src/models/enums.dart';
