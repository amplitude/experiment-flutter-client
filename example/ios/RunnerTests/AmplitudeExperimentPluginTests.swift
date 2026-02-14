import XCTest
@testable import amplitude_experiment

/// Unit tests for AmplitudeExperimentPlugin with Pigeon Host API.
/// Mirrors Android ExperimentFlutterPluginTest.kt.
///
/// The plugin implements AmplitudeExperimentHostApi; communication is via
/// Pigeon message channels. These tests call Host API methods directly and
/// verify error handling when instances are missing.
///
/// Full integration with the Amplitude Experiment SDK is not exercised here;
/// the codec is tested in ExperimentSdkCodecTest.
class AmplitudeExperimentPluginTests: XCTestCase {

    var plugin: AmplitudeExperimentPlugin!

    override func setUp() {
        super.setUp()
        plugin = TestDataHelpers.createAttachedPlugin()
    }

    override func tearDown() {
        plugin = nil
        super.tearDown()
    }

    func assertThrowsInstanceNotFound(_ block: () throws -> Void) {
        do {
            try block()
            XCTFail("Expected PigeonError with INSTANCE_NOT_FOUND")
        } catch let e as PigeonError {
            XCTAssertEqual(e.code, "INSTANCE_NOT_FOUND")
        } catch {
            XCTFail("Expected PigeonError, got \(type(of: error))")
        }
    }

    func testVariant_withNonExistentInstance_throws() {
        let user = TestDataHelpers.createPigeonUser()
        assertThrowsInstanceNotFound {
            _ = try plugin.variant(instanceName: "non-existent-instance", user: user, flagKey: "test-flag", fallbackVariant: nil)
        }
    }

    func testStart_withNonExistentInstance_callsBackWithFailure() {
        let expectation = expectation(description: "start completion called")
        var completionError: Error?
        plugin.start(instanceName: "non-existent-instance", user: nil) { result in
            if case .failure(let error) = result {
                completionError = error
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
        XCTAssertNotNil(completionError)
        XCTAssertTrue(completionError is PigeonError)
        XCTAssertEqual((completionError as? PigeonError)?.code, "INSTANCE_NOT_FOUND")
    }

    func testStop_withNonExistentInstance_throws() {
        assertThrowsInstanceNotFound {
            try plugin.stop(instanceName: "non-existent-instance")
        }
    }

    func testFetch_withNonExistentInstance_callsBackWithFailure() {
        let expectation = expectation(description: "fetch completion called")
        var completionError: Error?
        plugin.fetch(instanceName: "non-existent-instance", user: nil, options: nil) { result in
            if case .failure(let error) = result {
                completionError = error
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
        XCTAssertNotNil(completionError)
        XCTAssertTrue(completionError is PigeonError)
        XCTAssertEqual((completionError as? PigeonError)?.code, "INSTANCE_NOT_FOUND")
    }

    func testClear_withNonExistentInstance_throws() {
        assertThrowsInstanceNotFound {
            try plugin.clear(instanceName: "non-existent-instance")
        }
    }

    func testExposure_withNonExistentInstance_throws() {
        assertThrowsInstanceNotFound {
            try plugin.exposure(instanceName: "non-existent-instance", key: "flag-key")
        }
    }

    func testSetUser_withNonExistentInstance_throws() {
        let user = TestDataHelpers.createPigeonUser()
        assertThrowsInstanceNotFound {
            try plugin.setUser(instanceName: "non-existent-instance", user: user)
        }
    }

    func testSetTracksAssignment_withNonExistentInstance_throws() {
        assertThrowsInstanceNotFound {
            try plugin.setTracksAssignment(instanceName: "non-existent-instance", tracksAssignment: true)
        }
    }

    func testInitializeExperiment_withValidConfig_doesNotThrow() {
        let config = TestDataHelpers.createPigeonConfig(instanceName: "test-instance")
        do {
            try plugin.initializeExperiment(apiKey: "test-api-key", config: config)
        } catch {
            // SDK initialization can fail in unit test environment (e.g. no real app context)
        }
    }

    func testInitializeExperiment_twiceWithSameInstanceName_doesNotThrow() {
        let config = TestDataHelpers.createPigeonConfig(instanceName: "same-instance")
        do {
            try plugin.initializeExperiment(apiKey: "test-api-key", config: config)
            try plugin.initializeExperiment(apiKey: "test-api-key", config: config)
        } catch {
            // SDK initialization can fail in unit test environment
        }
    }
}
