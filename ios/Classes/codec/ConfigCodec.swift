import AmplitudeExperiment
import Foundation

/**
 * Codec for parsing ExperimentConfig from method channel arguments.
 */
enum ConfigCodec {
    /**
     * Parses an ExperimentConfig from a Map representation.
     * @param configMap The map containing config data
     * @return An ExperimentConfig object parsed from the map, or nil if configMap is nil
     */
    static func fromMap(_ configMap: [String: Any]?) throws -> ExperimentConfig? {
        guard let configMap = configMap else {
            return nil
        }

        let builder = ExperimentConfigBuilder()

        if let instanceName = configMap["instanceName"] as? String {
            builder.instanceName(instanceName)
        }

        if let fallbackVariantDict = configMap["fallbackVariant"] as? [String: Any] {
            builder.fallbackVariant(VariantCodec.fromMap(fallbackVariantDict))
        }

        if let fetchOnStart = configMap["fetchOnStart"] as? Bool {
            builder.fetchOnStart(fetchOnStart)
        }

        if let fetchTimeoutMillis = configMap["fetchTimeoutMillis"] as? Int {
            builder.fetchTimeoutMillis(fetchTimeoutMillis)
        }

        if let flagsServerUrl = configMap["flagsServerUrl"] as? String {
            builder.flagsServerUrl(flagsServerUrl)
        }

        if let flagConfigPollingIntervalMillis = configMap[
            "flagConfigPollingIntervalMillis"
        ] as? Int {
            builder.flagConfigPollingIntervalMillis(
                flagConfigPollingIntervalMillis
            )
        }

        if let initialFlags = configMap["initialFlags"] as? String {
            builder.initialFlags(initialFlags)
        }

        if let pollOnStart = configMap["pollOnStart"] as? Bool {
            builder.pollOnStart(pollOnStart)
        }

        if let retryFetchOnFailure = configMap["retryFetchOnFailure"] as? Bool {
            builder.fetchRetryOnFailure(retryFetchOnFailure)
        }

        if let serverUrl = configMap["serverUrl"] as? String {
            builder.serverUrl(serverUrl)
        }

        if let serverZoneString = configMap["serverZone"] as? String {
            builder.serverZone(try EnumParser.parseServerZone(serverZoneString))
        }

        if let sourceString = configMap["source"] as? String {
            builder.source(try EnumParser.parseSource(sourceString))
        }

        if let automaticExposureTracking = configMap["automaticExposureTracking"]
            as? Bool
        {
            builder.automaticExposureTracking(automaticExposureTracking)
        }

        if let automaticFetchOnAmplitudeIdentityChange = configMap[
            "automaticFetchOnAmplitudeIdentityChange"
        ] as? Bool {
            builder.automaticFetchOnAmplitudeIdentityChange(
                automaticFetchOnAmplitudeIdentityChange
            )
        }

        if let initialVariantsDict = configMap["initialVariants"] as? [String: Any] {
            let initialVariants = initialVariantsDict.mapValues {
                VariantCodec.fromMap($0 as! [String: Any])
            }
            builder.initialVariants(initialVariants)
        }

        return builder.build()
    }
}
