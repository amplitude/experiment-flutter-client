import XCTest
import AmplitudeExperiment
@testable import amplitude_experiment

/// Unit tests for ExperimentSdkCodec. Verifies conversion between Pigeon/Flutter types
/// and Amplitude Experiment SDK types. Mirrors Android ExperimentSdkCodecTest.kt.
class ExperimentSdkCodecTest: XCTestCase {

    // MARK: - convertVariant (Pigeon -> SDK)

    func testConvertVariant_pigeonToSdk_mapsAllFields() {
        let pigeon = TestDataHelpers.createPigeonVariant(
            key: "k",
            value: "v",
            payload: "payload",
            expKey: "exp",
            metadata: ["a": 1]
        )
        let sdk = ExperimentSdkCodec.convertVariant(pigeon)
        XCTAssertNotNil(sdk)
        XCTAssertEqual(sdk?.key, "k")
        XCTAssertEqual(sdk?.value, "v")
        XCTAssertEqual(sdk?.payload as? String, "payload")
        XCTAssertEqual(sdk?.expKey, "exp")
        XCTAssertEqual(sdk?.metadata?["a"] as? Int, 1)
    }

    func testConvertVariant_null_returnsNil() {
        let sdk = ExperimentSdkCodec.convertVariant(nil as amplitude_experiment.Variant?)
        XCTAssertNil(sdk)
    }

    // MARK: - convertVariant (SDK -> Pigeon)

    func testConvertVariant_sdkToPigeon_mapsAllFields() {
        // Build SDK variant via codec (Pigeon -> SDK) to avoid depending on SDK's initializer
        let fromPigeon = TestDataHelpers.createPigeonVariant(
            key: "k",
            value: "v",
            payload: "payload",
            expKey: "exp",
            metadata: ["a": 1]
        )
        let sdk = ExperimentSdkCodec.convertVariant(fromPigeon)!
        let pigeon = ExperimentSdkCodec.convertVariant(sdk)
        XCTAssertEqual(pigeon.key, "k")
        XCTAssertEqual(pigeon.value, "v")
        XCTAssertEqual(pigeon.payload as? String, "payload")
        XCTAssertEqual(pigeon.expKey, "exp")
        XCTAssertEqual(pigeon.metadata?["a"] as? Int, 1)
    }

    func testConvertVariant_roundTrip_preservesData() {
        let pigeon = TestDataHelpers.createPigeonVariant(
            key: "k",
            value: "v",
            payload: 42,
            expKey: "e",
            metadata: ["m": "n"]
        )
        let sdk = ExperimentSdkCodec.convertVariant(pigeon)!
        let back = ExperimentSdkCodec.convertVariant(sdk)
        XCTAssertEqual(pigeon.key, back.key)
        XCTAssertEqual(pigeon.value, back.value)
        XCTAssertEqual(pigeon.expKey, back.expKey)
    }

    // MARK: - convertUser

    func testConvertUser_pigeonToSdk_mapsScalarFields() {
        let pigeon = TestDataHelpers.createPigeonUser(
            deviceId: "dev-1",
            userId: "u-1",
            country: "US",
            city: "NYC",
            region: "NY",
            language: "en",
            platform: "iOS",
            version: "1.0",
            os: "iOS"
        )
        let sdk = ExperimentSdkCodec.convertUser(pigeon)
        XCTAssertNotNil(sdk)
        XCTAssertEqual(sdk?.deviceId, "dev-1")
        XCTAssertEqual(sdk?.userId, "u-1")
        XCTAssertEqual(sdk?.country, "US")
        XCTAssertEqual(sdk?.city, "NYC")
        XCTAssertEqual(sdk?.region, "NY")
        XCTAssertEqual(sdk?.language, "en")
        XCTAssertEqual(sdk?.platform, "iOS")
        XCTAssertEqual(sdk?.version, "1.0")
        XCTAssertEqual(sdk?.os, "iOS")
    }

    func testConvertUser_null_returnsNil() {
        let sdk = ExperimentSdkCodec.convertUser(nil)
        XCTAssertNil(sdk)
    }

    func testConvertUser_groups_convertedToSet() {
        let groups: [String: [String]] = ["g1": ["a", "b"]]
        let pigeon = TestDataHelpers.createPigeonUser(groups: groups)
        let sdk = ExperimentSdkCodec.convertUser(pigeon)
        XCTAssertNotNil(sdk?.groups)
        let g1 = sdk?.groups?["g1"]
        XCTAssertNotNil(g1)
        XCTAssertTrue(g1?.contains("a") ?? false)
        XCTAssertTrue(g1?.contains("b") ?? false)
        XCTAssertEqual(g1?.count, 2)
    }

    func testConvertUser_userProperties_preserved() {
        let props: [String: Any] = ["p1": "v1", "p2": 2]
        let pigeon = TestDataHelpers.createPigeonUser(userProperties: props)
        let sdk = ExperimentSdkCodec.convertUser(pigeon)
        XCTAssertNotNil(sdk?.userProperties)
        XCTAssertEqual(sdk?.userProperties?["p1"] as? String, "v1")
        // TODO: iOS SDK does not properly expose non-string userProperties.
        // Re-enable after the next iOS SDK version upgrade.
        // XCTAssertEqual(sdk?.userProperties?["p2"] as? Int, 2)
    }

    // MARK: - convertConfig

    func testConvertConfig_pigeonToSdk_mapsAllFields() {
        let pigeon = TestDataHelpers.createPigeonConfig(
            instanceName: "my-instance",
            initialFlags: "flag1,flag2",
            initialVariants: ["f1": TestDataHelpers.createPigeonVariant(value: "on")],
            source: .initialVariants,
            serverZone: amplitude_experiment.ServerZone.eu,
            serverUrl: "https://api.test.com",
            flagsServerUrl: "https://flags.test.com",
            fetchTimeoutMillis: 5000,
            retryFetchOnFailure: false,
            automaticExposureTracking: false,
            fetchOnStart: false,
            pollOnStart: true,
            automaticFetchOnAmplitudeIdentityChange: true,
        )
        let sdk = ExperimentSdkCodec.convertConfig(pigeon, api: TestDataHelpers.createMockProviderApi())
        XCTAssertEqual(sdk.instanceName, "my-instance")
        XCTAssertEqual(sdk.initialFlags, "flag1,flag2")
        XCTAssertEqual(sdk.serverUrl, "https://api.test.com")
        XCTAssertEqual(sdk.flagsServerUrl, "https://flags.test.com")
        XCTAssertEqual(sdk.fetchTimeoutMillis, 5000)
        XCTAssertEqual(sdk.retryFetchOnFailure, false)
        XCTAssertEqual(sdk.automaticExposureTracking, false)
        XCTAssertEqual(sdk.fetchOnStart, false)
        XCTAssertEqual(sdk.pollOnStart, true)
        XCTAssertEqual(sdk.automaticFetchOnAmplitudeIdentityChange, true)
        XCTAssertEqual(sdk.source, AmplitudeExperiment.Source.InitialVariants)
        XCTAssertEqual(sdk.serverZone, AmplitudeExperiment.ServerZone.EU)
        XCTAssertEqual(sdk.initialVariants.count, 1)
        XCTAssertEqual(sdk.initialVariants["f1"]?.value, "on")
    }

    func testConvertConfig_source_localStorage_mapsToSdk() {
        let pigeon = TestDataHelpers.createPigeonConfig(source: .localStorage)
        let sdk = ExperimentSdkCodec.convertConfig(pigeon, api: TestDataHelpers.createMockProviderApi())
        XCTAssertEqual(sdk.source, AmplitudeExperiment.Source.LocalStorage)
    }

    func testConvertConfig_serverZone_usAndEu_mapsToSdk() {
        let sdkUs = ExperimentSdkCodec.convertConfig(TestDataHelpers.createPigeonConfig(serverZone: .us), api: TestDataHelpers.createMockProviderApi())
        XCTAssertEqual(sdkUs.serverZone, AmplitudeExperiment.ServerZone.US)
        let sdkEu = ExperimentSdkCodec.convertConfig(TestDataHelpers.createPigeonConfig(serverZone: .eu), api: TestDataHelpers.createMockProviderApi())
        XCTAssertEqual(sdkEu.serverZone, AmplitudeExperiment.ServerZone.EU)
    }

    func testConvertConfig_defaultPigeonConfig_producesValidSdkConfig() {
        let pigeon = TestDataHelpers.createPigeonConfig()
        let sdk = ExperimentSdkCodec.convertConfig(pigeon, api: TestDataHelpers.createMockProviderApi())
        XCTAssertEqual(sdk.instanceName, "test-instance")
        XCTAssertEqual(sdk.fetchTimeoutMillis, 10000)
        XCTAssertEqual(sdk.retryFetchOnFailure, true)
        XCTAssertEqual(sdk.automaticExposureTracking, true)
        XCTAssertEqual(sdk.fetchOnStart, true)
        XCTAssertEqual(sdk.pollOnStart, false)
        XCTAssertEqual(sdk.automaticFetchOnAmplitudeIdentityChange, false)
        XCTAssertEqual(sdk.source, AmplitudeExperiment.Source.LocalStorage)
        XCTAssertEqual(sdk.serverZone, AmplitudeExperiment.ServerZone.US)
        XCTAssertEqual(sdk.initialVariants.count, 0)
    }
}
