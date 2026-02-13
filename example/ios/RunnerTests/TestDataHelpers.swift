import Flutter
import Foundation
@testable import amplitude_experiment

/// Mock FlutterBinaryMessenger for unit tests.
class MockBinaryMessenger: NSObject, FlutterBinaryMessenger {
    func send(onChannel channel: String, message: Data?) {}
    func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
        callback?(nil)
    }
    func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
        return FlutterBinaryMessengerConnection(0)
    }
    func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

/// Shared test data for unit tests. Provides Pigeon (Host API) types, mirroring Android TestDataHelpers.kt.
enum TestDataHelpers {

    // MARK: - Pigeon types for Host API

    static func createPigeonVariant(
        key: String? = "test-key",
        value: String? = "test-value",
        payload: Any? = nil,
        expKey: String? = "exp-123",
        metadata: [String: Any?]? = nil
    ) -> Variant {
        Variant(
            key: key,
            value: value,
            payload: payload,
            expKey: expKey,
            metadata: metadata
        )
    }

    static func createPigeonUser(
        deviceId: String? = "device-123",
        userId: String? = "user-123",
        country: String? = "US",
        city: String? = "San Francisco",
        region: String? = "CA",
        dma: String? = nil,
        language: String? = "en",
        platform: String? = "iOS",
        version: String? = "1.0.0",
        os: String? = "iOS",
        deviceModel: String? = "iPhone",
        deviceBrand: String? = "Apple",
        deviceManufacturer: String? = "Apple",
        carrier: String? = nil,
        library: String? = nil,
        ipAddress: String? = nil,
        userProperties: [String: Any]? = nil,
        groups: [String: [String]]? = nil,
        groupProperties: [String: [String: [String: Any?]]]? = nil
    ) -> ExperimentUser {
        ExperimentUser(
            deviceId: deviceId,
            userId: userId,
            country: country,
            city: city,
            region: region,
            dma: dma,
            language: language,
            platform: platform,
            version: version,
            os: os,
            deviceModel: deviceModel,
            deviceBrand: deviceBrand,
            deviceManufacturer: deviceManufacturer,
            carrier: carrier,
            library: library,
            ipAddress: ipAddress,
            userProperties: userProperties,
            groups: groups,
            groupProperties: groupProperties
        )
    }

    static func createPigeonConfig(
        instanceName: String = "test-instance",
        logLevel: LogLevel = .warn,
        fallbackVariant: Variant = createPigeonVariant(),
        initialFlags: String? = nil,
        initialVariants: [String: Variant] = [:],
        source: Source = .localStorage,
        serverZone: ServerZone = .us,
        serverUrl: String = "https://api.example.com",
        flagsServerUrl: String = "https://flags.example.com",
        fetchTimeoutMillis: Int64 = 10000,
        retryFetchOnFailure: Bool = true,
        automaticExposureTracking: Bool = true,
        fetchOnStart: Bool = true,
        pollOnStart: Bool = false,
        automaticFetchOnAmplitudeIdentityChange: Bool = false,
        hasTrackingProvider: Bool = false
    ) -> ExperimentConfigData {
        ExperimentConfigData(
            instanceName: instanceName,
            logLevel: logLevel,
            fallbackVariant: fallbackVariant,
            initialFlags: initialFlags,
            initialVariants: initialVariants,
            source: source,
            serverZone: serverZone,
            serverUrl: serverUrl,
            flagsServerUrl: flagsServerUrl,
            fetchTimeoutMillis: fetchTimeoutMillis,
            retryFetchOnFailure: retryFetchOnFailure,
            automaticExposureTracking: automaticExposureTracking,
            fetchOnStart: fetchOnStart,
            pollOnStart: pollOnStart,
            automaticFetchOnAmplitudeIdentityChange: automaticFetchOnAmplitudeIdentityChange,
            hasTrackingProvider: hasTrackingProvider
        )
    }

    /// Creates a plugin instance with a mock binary messenger, ready for Host API calls.
    /// Mirrors Android TestDataHelpers.createAttachedPlugin().
    static func createAttachedPlugin() -> AmplitudeExperimentPlugin {
        let plugin = AmplitudeExperimentPlugin()
        let messenger = MockBinaryMessenger()
        plugin.providerApi = CustomProviderApi(binaryMessenger: messenger)
        return plugin
    }

    /// Creates a mock CustomProviderApi for codec tests.
    static func createMockProviderApi() -> CustomProviderApi {
        return CustomProviderApi(binaryMessenger: MockBinaryMessenger())
    }
}
