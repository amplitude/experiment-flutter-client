import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart'
    as pigeon;
import 'package:amplitude_experiment/src/providers.dart';
import 'package:amplitude_experiment/src/pigeon_mappers.dart';

class CustomProviderPigeon extends pigeon.CustomProviderApi {
  final Map<String, ExposureTrackingProvider> _trackingProviderMap = {};

  @override
  void track(String instanceName, pigeon.Exposure exposure) {
    _trackingProviderMap[instanceName]?.track(exposureFromPigeon(exposure));
  }

  void registerTrackingProvider(
    String instanceName,
    ExposureTrackingProvider provider,
  ) {
    _trackingProviderMap[instanceName] = provider;
  }
}
