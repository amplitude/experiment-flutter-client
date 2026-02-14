/// Amplitude Experiment Flutter SDK.
///
/// Use [Experiment.initialize] or [Experiment.initializeWithAmplitude] to
/// create an [ExperimentClient], then call methods like [ExperimentClient.fetch]
/// and [ExperimentClient.variant] to evaluate feature flags.
library amplitude_experiment;

// Factory entry point
export 'experiment.dart';

// Core API
export 'src/experiment_client.dart';
export 'src/experiment_config.dart';

// Provider interfaces
export 'src/providers.dart';

// User extension helpers
export 'src/experiment_user_extensions.dart';

// Public data models and enums from Pigeon
export 'src/generated/amplitude_experiment_api.g.dart'
    show
        ExperimentUser,
        Variant,
        Exposure,
        FetchOptions,
        LogLevel,
        Source,
        ServerZone;
