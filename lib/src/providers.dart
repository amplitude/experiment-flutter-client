import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';

abstract interface class ExposureTrackingProvider {
  void track(Exposure exposure);
}

abstract interface class UserProvider {
  ExperimentUser getUser();
}
