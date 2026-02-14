import AmplitudeExperiment
import Foundation

/**
 * Converts between Pigeon/Flutter types (from AmplitudeExperimentApi.g.swift) and
 * Amplitude Experiment SDK types. Mirrors the Android ExperimentSdkCodec.kt.
 */
enum ExperimentSdkCodec {
    /// Convert Pigeon ExperimentUser to SDK ExperimentUser.
    static func convertUser(_ pigeon: ExperimentUser?) -> AmplitudeExperiment.ExperimentUser? {
        guard let pigeon = pigeon else { return nil }
        let builder = AmplitudeExperiment.ExperimentUserBuilder()
        builder.deviceId(pigeon.deviceId)
        builder.userId(pigeon.userId)
        builder.country(pigeon.country)
        builder.city(pigeon.city)
        builder.region(pigeon.region)
        builder.dma(pigeon.dma)
        builder.language(pigeon.language)
        builder.platform(pigeon.platform)
        builder.version(pigeon.version)
        builder.os(pigeon.os)
        builder.deviceModel(pigeon.deviceModel)
        builder.deviceManufacturer(pigeon.deviceManufacturer)
        builder.carrier(pigeon.carrier)
        builder.library(pigeon.library)
        builder.userProperties(pigeon.userProperties)
        builder.groups(pigeon.groups)
        builder.groupProperties(pigeon.groupProperties)
        return builder.build()
    }

    /// Convert SDK ExperimentUser to Pigeon ExperimentUser (for getUser return value).
    static func convertUserToPigeon(_ sdk: AmplitudeExperiment.ExperimentUser?) -> ExperimentUser {
        guard let sdk = sdk else {
            return ExperimentUser()
        }
        var groups: [String: [String]]?
        if let sdkGroups = sdk.groups {
            let pairs: [(String, [String])] = sdkGroups.map { ($0.key, Array($0.value)) }
            groups = Dictionary(uniqueKeysWithValues: pairs)
        }
        return ExperimentUser(
            deviceId: sdk.deviceId,
            userId: sdk.userId,
            country: sdk.country,
            city: sdk.city,
            region: sdk.region,
            dma: sdk.dma,
            language: sdk.language,
            platform: sdk.platform,
            version: sdk.version,
            os: sdk.os,
            deviceModel: sdk.deviceModel,
            deviceBrand: nil,
            deviceManufacturer: sdk.deviceManufacturer,
            carrier: sdk.carrier,
            library: sdk.library,
            ipAddress: nil,
            userProperties: sdk.userProperties,
            groups: groups,
            groupProperties: sdk.groupProperties
        )
    }

    /// Convert Pigeon ExperimentConfigData to SDK ExperimentConfig.
    static func convertConfig(_ pigeon: ExperimentConfigData, api: CustomProviderApi) -> AmplitudeExperiment.ExperimentConfig {
        let builder = AmplitudeExperiment.ExperimentConfigBuilder()
        builder.instanceName(pigeon.instanceName)
        if let fallback = convertVariant(pigeon.fallbackVariant) {
            builder.fallbackVariant(fallback)
        }
        builder.initialFlags(pigeon.initialFlags)
        builder.initialVariants(convertVariants(pigeon.initialVariants))
        builder.source(convertSource(pigeon.source))
        builder.serverZone(convertServerZone(pigeon.serverZone))
        builder.serverUrl(pigeon.serverUrl)
        builder.flagsServerUrl(pigeon.flagsServerUrl)
        builder.fetchTimeoutMillis(Int(pigeon.fetchTimeoutMillis))
        builder.fetchRetryOnFailure(pigeon.retryFetchOnFailure)
        builder.automaticExposureTracking(pigeon.automaticExposureTracking)
        builder.fetchOnStart(pigeon.fetchOnStart)
        builder.pollOnStart(pigeon.pollOnStart)
        builder.automaticFetchOnAmplitudeIdentityChange(pigeon.automaticFetchOnAmplitudeIdentityChange)
        if pigeon.hasTrackingProvider {
            builder.exposureTrackingProvider(
                PigeonExposureTrackingProvider(instanceName: pigeon.instanceName, api: api)
            )
        }
        return builder.build()
    }

    /// Convert Pigeon Variant to SDK Variant.
    static func convertVariant(_ pigeon: Variant?) -> AmplitudeExperiment.Variant? {
        guard let pigeon = pigeon else { return nil }
        return AmplitudeExperiment.Variant(
            pigeon.value,
            payload: pigeon.payload,
            expKey: pigeon.expKey,
            key: pigeon.key,
            metadata: pigeon.metadata
        )
    }

    /// Convert SDK Variant to Pigeon Variant (for return values).
    static func convertVariant(_ sdk: AmplitudeExperiment.Variant) -> Variant {
        Variant(
            key: sdk.key,
            value: sdk.value,
            payload: sdk.payload,
            expKey: sdk.expKey,
            metadata: sdk.metadata
        )
    }

    /// Convert SDK Exposure to Pigeon Exposure (for tracking provider callback).
    static func convertExposure(_ sdk: AmplitudeExperiment.Exposure) -> Exposure {
        Exposure(
            flagKey: sdk.flagKey,
            variant: sdk.variant,
            experimentKey: sdk.experimentKey,
            metadata: sdk.metadata
        )
    }

    /// Convert Pigeon FetchOptions to SDK FetchOptions.
    static func convertFetchOptions(_ pigeon: FetchOptions?) -> AmplitudeExperiment.FetchOptions? {
        guard let pigeon = pigeon else { return nil }
        return AmplitudeExperiment.FetchOptions(pigeon.flagKeys)
    }

    private static func convertVariants(_ pigeon: [String: Variant]) -> [String: AmplitudeExperiment.Variant] {
        pigeon.mapValues { convertVariant($0)! }
    }

    private static func convertSource(_ pigeon: Source) -> AmplitudeExperiment.Source {
        switch pigeon {
        case .localStorage: return AmplitudeExperiment.Source.LocalStorage
        case .initialVariants: return AmplitudeExperiment.Source.InitialVariants
        }
    }

    private static func convertServerZone(_ pigeon: ServerZone) -> AmplitudeExperiment.ServerZone {
        switch pigeon {
        case .us: return AmplitudeExperiment.ServerZone.US
        case .eu: return AmplitudeExperiment.ServerZone.EU
        }
    }
}

/// Bridges native ExposureTrackingProvider to Dart via Pigeon's CustomProviderApi.
class PigeonExposureTrackingProvider: NSObject, AmplitudeExperiment.ExposureTrackingProvider {
    private let instanceName: String
    private let api: CustomProviderApi

    init(instanceName: String, api: CustomProviderApi) {
        self.instanceName = instanceName
        self.api = api
    }

    func track(exposure: AmplitudeExperiment.Exposure) {
        let pigeonExposure = ExperimentSdkCodec.convertExposure(exposure)
        api.track(instanceName: instanceName, exposure: pigeonExposure) { _ in }
    }
}
