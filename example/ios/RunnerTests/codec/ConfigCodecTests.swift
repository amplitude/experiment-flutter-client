import XCTest
@testable import experiment_flutter
import AmplitudeExperiment

class ConfigCodecTests: XCTestCase {
    func testFromMap_basicFields_parsesCorrectly() throws {
        let configMap = TestDataHelpers.createTestConfigMap(
            instanceName: "test-instance",
            fetchOnStart: true,
            fetchTimeoutMillis: 10000,
            flagsServerUrl: "https://flags.example.com",
            serverUrl: "https://api.example.com"
        )

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.instanceName, "test-instance")
        XCTAssertEqual(c.fetchOnStart, true)
        XCTAssertEqual(c.fetchTimeoutMillis, 10000)
        XCTAssertEqual(c.flagsServerUrl, "https://flags.example.com")
        XCTAssertEqual(c.serverUrl, "https://api.example.com")
    }

    func testFromMap_allFields_parsesCorrectly() throws {
        let configMap = TestDataHelpers.createTestConfigMap(
            instanceName: "test-instance",
            fetchOnStart: true,
            fetchTimeoutMillis: 5000,
            flagsServerUrl: "https://flags.example.com",
            serverUrl: "https://api.example.com",
            serverZone: "us",
            source: "localStorage",
            retryFetchOnFailure: true,
            pollOnStart: false,
            automaticExposureTracking: true,
            automaticFetchOnAmplitudeIdentityChange: false,
            initialFlags: "{}",
            flagConfigPollingIntervalMillis: 60000
        )

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.instanceName, "test-instance")
        XCTAssertEqual(c.fetchOnStart, true)
        XCTAssertEqual(c.fetchTimeoutMillis, 5000)
        XCTAssertEqual(c.flagsServerUrl, "https://flags.example.com")
        XCTAssertEqual(c.serverUrl, "https://api.example.com")
        XCTAssertEqual(c.serverZone, .US)
        XCTAssertEqual(c.source, .LocalStorage)
        XCTAssertEqual(c.retryFetchOnFailure, true)
        XCTAssertEqual(c.pollOnStart, false)
        XCTAssertEqual(c.automaticExposureTracking, true)
        XCTAssertEqual(c.automaticFetchOnAmplitudeIdentityChange, false)
        XCTAssertEqual(c.initialFlags, "{}")
        XCTAssertEqual(c.flagConfigPollingIntervalMillis, 60000)
    }

    func testFromMap_serverZoneUs_parsesCorrectly() throws {
        let configMap = TestDataHelpers.createTestConfigMap(serverZone: "us")

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.serverZone, .US)
    }

    func testFromMap_serverZoneEu_parsesCorrectly() throws {
        let configMap = TestDataHelpers.createTestConfigMap(serverZone: "eu")

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.serverZone, .EU)
    }

    func testFromMap_sourceLocalStorage_parsesCorrectly() throws {
        let configMap = TestDataHelpers.createTestConfigMap(source: "localStorage")

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.source, .LocalStorage)
    }

    func testFromMap_sourceInitialVariants_parsesCorrectly() throws {
        let configMap = TestDataHelpers.createTestConfigMap(source: "initialVariants")

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.source, .InitialVariants)
    }

    func testFromMap_fallbackVariant_parsesCorrectly() throws {
        let fallbackVariant = TestDataHelpers.createTestVariantMap(
            key: "fallback-key",
            value: "fallback-value"
        )
        let configMap = TestDataHelpers.createTestConfigMap(
            fallbackVariant: fallbackVariant
        )

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertNotNil(c.fallbackVariant)
        let variant = c.fallbackVariant
        XCTAssertEqual(variant.key, "fallback-key")
        XCTAssertEqual(variant.value, "fallback-value")
    }

    func testFromMap_initialVariants_parsesCorrectly() throws {
        let initialVariants: [String: [String: Any]] = [
            "flag1": TestDataHelpers.createTestVariantMap(key: "flag1", value: "value1"),
            "flag2": TestDataHelpers.createTestVariantMap(key: "flag2", value: "value2")
        ]
        let configMap = TestDataHelpers.createTestConfigMap(
            initialVariants: initialVariants
        )

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertNotNil(c.initialVariants)
        let variants = c.initialVariants
        XCTAssertEqual(variants.count, 2)
        XCTAssertEqual(variants["flag1"]?.key, "flag1")
        XCTAssertEqual(variants["flag1"]?.value, "value1")
        XCTAssertEqual(variants["flag2"]?.key, "flag2")
        XCTAssertEqual(variants["flag2"]?.value, "value2")
    }

    func testFromMap_nullMap_returnsNil() throws {
        let config = try ConfigCodec.fromMap(nil)

        XCTAssertNil(config)
    }

    func testFromMap_optionalFields_handlesNulls() throws {
        let configMap: [String: Any] = [
            "instanceName": "test-instance"
        ]

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.instanceName, "test-instance")
        // Other fields should use defaults from builder
    }

    func testFromMap_invalidServerZone_throwsException() {
        let configMap = TestDataHelpers.createTestConfigMap(serverZone: "invalid")

        XCTAssertThrowsError(try ConfigCodec.fromMap(configMap)) { error in
            XCTAssertTrue(error is NSError)
        }
    }

    func testFromMap_invalidSource_throwsException() {
        let configMap = TestDataHelpers.createTestConfigMap(source: "invalid")

        XCTAssertThrowsError(try ConfigCodec.fromMap(configMap)) { error in
            XCTAssertTrue(error is NSError)
        }
    }

    func testFromMap_fetchTimeoutMillis_convertsIntToInt() throws {
        let configMap = TestDataHelpers.createTestConfigMap(fetchTimeoutMillis: 5000)

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.fetchTimeoutMillis, 5000)
    }

    func testFromMap_flagConfigPollingIntervalMillis_convertsIntToInt() throws {
        let configMap = TestDataHelpers.createTestConfigMap(
            flagConfigPollingIntervalMillis: 30000
        )

        let config = try ConfigCodec.fromMap(configMap)

        XCTAssertNotNil(config)
        let c = config!
        XCTAssertEqual(c.flagConfigPollingIntervalMillis, 30000)
    }
}
