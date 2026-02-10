import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/providers.dart';

class CustomProviderPigeon extends CustomProviderApi {
  final Map<String, ExposureTrackingProvider> _trackingProviderMap = {};
  final Map<String, UserProvider> _userProviderMap = {};

  @override
  void track(String instanceName, Exposure exposure) {
    _trackingProviderMap[instanceName]?.track(exposure);
  }

  @override
  Future<ExperimentUser> getUser(String instanceName) async {
    return _userProviderMap[instanceName]?.getUser() ?? ExperimentUser();
  }

  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {
    _trackingProviderMap[instanceName] = provider;
  }

  void registerUserProvider(String instanceName, UserProvider provider) {
    _userProviderMap[instanceName] = provider;
  }
}
