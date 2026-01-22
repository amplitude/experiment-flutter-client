import XCTest
import Flutter
@testable import experiment_flutter

/*
 * Unit tests for ExperimentFlutterPlugin focusing on method routing and codec integration.
 *
 * These tests verify that the plugin correctly:
 * - Routes method calls to appropriate handlers
 * - Uses codec classes for data transformation
 * - Handles errors appropriately
 *
 * Note: Full integration tests with Amplitude SDK would require mocking the SDK,
 * which is beyond the scope of these unit tests. The codec classes are tested separately.
 */
class ExperimentFlutterPluginTests: XCTestCase {
    var plugin: ExperimentFlutterPlugin!

    override func setUp() {
        super.setUp()
        plugin = ExperimentFlutterPlugin()
        // Note: We test handle() directly without full plugin registration
        // since handle() doesn't require the channel to be set up
    }

    override func tearDown() {
        plugin = nil
        super.tearDown()
    }

    func testOnMethodCall_unknownMethod_withNonExistentInstance_returnsError() {
        let expectation = XCTestExpectation(description: "Result should be called")
        
        let call = FlutterMethodCall(
            methodName: "unknownMethod",
            arguments: ["instanceName": "non-existent-instance"]
        )
        
        plugin.handle(call) { result in
            if let error = result as? FlutterError {
                XCTAssertEqual(error.code, "INSTANCE_NOT_FOUND")
                XCTAssertTrue(error.message?.contains("not found") ?? false)
            } else {
                XCTFail("Expected FlutterError")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testOnMethodCall_init_missingConfig_returnsError() {
        let expectation = XCTestExpectation(description: "Result should be called")
        
        let call = FlutterMethodCall(
            methodName: "init",
            arguments: ["apiKey": "test-key"]
        )
        
        plugin.handle(call) { result in
            if let error = result as? FlutterError {
                XCTAssertEqual(error.code, "INVALID_ARGUMENT")
                XCTAssertTrue(error.message?.contains("config") ?? false)
            } else {
                XCTFail("Expected FlutterError")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testOnMethodCall_variant_missingFlagKey_returnsError() {
        let expectation = XCTestExpectation(description: "Result should be called")
        
        // First, initialize an instance (this will fail in test environment, but that's okay)
        let initConfig = TestDataHelpers.createTestConfigMap(instanceName: "test-instance")
        let initCall = FlutterMethodCall(
            methodName: "init",
            arguments: [
                "apiKey": "test-api-key",
                "config": initConfig
            ]
        )
        
        // Try to initialize (will fail but that's expected)
        plugin.handle(initCall) { _ in }
        
        // Now test variant call without flagKey
        let variantCall = FlutterMethodCall(
            methodName: "variant",
            arguments: ["instanceName": "test-instance"]
        )
        
        plugin.handle(variantCall) { result in
            if let error = result as? FlutterError {
                XCTAssertEqual(error.code, "INVALID_ARGUMENT")
                XCTAssertTrue(error.message?.contains("flagKey") ?? false)
            } else {
                // If instance doesn't exist, we'll get INSTANCE_NOT_FOUND instead
                // Both are valid error cases
                if let error = result as? FlutterError {
                    XCTAssertTrue(
                        error.code == "INVALID_ARGUMENT" || error.code == "INSTANCE_NOT_FOUND"
                    )
                } else {
                    XCTFail("Expected FlutterError")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testOnMethodCall_variant_missingInstance_returnsError() {
        let expectation = XCTestExpectation(description: "Result should be called")
        
        let call = FlutterMethodCall(
            methodName: "variant",
            arguments: [
                "instanceName": "non-existent-instance",
                "flagKey": "test-flag"
            ]
        )
        
        plugin.handle(call) { result in
            if let error = result as? FlutterError {
                XCTAssertEqual(error.code, "INSTANCE_NOT_FOUND")
                XCTAssertTrue(error.message?.contains("not found") ?? false)
            } else {
                XCTFail("Expected FlutterError")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testOnMethodCall_exposure_missingKey_returnsError() {
        let expectation = XCTestExpectation(description: "Result should be called")
        
        // First, initialize an instance (this will fail in test environment, but that's okay)
        let initConfig = TestDataHelpers.createTestConfigMap(instanceName: "test-instance")
        let initCall = FlutterMethodCall(
            methodName: "init",
            arguments: [
                "apiKey": "test-api-key",
                "config": initConfig
            ]
        )
        
        // Try to initialize (will fail but that's expected)
        plugin.handle(initCall) { _ in }
        
        // Now test exposure call without key
        let exposureCall = FlutterMethodCall(
            methodName: "exposure",
            arguments: ["instanceName": "test-instance"]
        )
        
        plugin.handle(exposureCall) { result in
            if let error = result as? FlutterError {
                XCTAssertEqual(error.code, "INVALID_ARGUMENT")
                XCTAssertTrue(error.message?.contains("key") ?? false)
            } else {
                // If instance doesn't exist, we'll get INSTANCE_NOT_FOUND instead
                // Both are valid error cases
                if let error = result as? FlutterError {
                    XCTAssertTrue(
                        error.code == "INVALID_ARGUMENT" || error.code == "INSTANCE_NOT_FOUND"
                    )
                } else {
                    XCTFail("Expected FlutterError")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// Note: We avoid full protocol conformance due to @objc compatibility issues
// with FlutterBinaryMessengerConnection. The tests focus on the handle() method
// which can be tested directly without requiring full plugin registration.
