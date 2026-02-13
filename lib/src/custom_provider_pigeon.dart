import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart';
import 'package:amplitude_experiment/src/providers.dart';

class CustomProviderPigeon extends CustomProviderApi {
  final Map<String, ExposureTrackingProvider> _trackingProviderMap = {};

  @override
  void track(String instanceName, Exposure exposure) {
    _trackingProviderMap[instanceName]?.track(exposure);
  }

  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {
    _trackingProviderMap[instanceName] = provider;
  }
}
