import XCTest
@testable import amplitude_experiment
import AmplitudeExperiment

class VariantCodecTests: XCTestCase {
    func testFromMap_allFields_parsesCorrectly() {
        let variantMap = TestDataHelpers.createTestVariantMap(
            key: "test-key",
            value: "test-value",
            payload: "payload-data",
            expKey: "exp-123",
            metadata: #"{"meta1":"value1","meta2":"value2"}"#
        )

        let variant = VariantCodec.fromMap(variantMap)

        XCTAssertEqual(variant.key, "test-key")
        XCTAssertEqual(variant.value, "test-value")
        XCTAssertEqual(variant.payload as? String, "payload-data")
        XCTAssertEqual(variant.expKey, "exp-123")
        XCTAssertNotNil(variant.metadata)
        XCTAssertEqual(variant.metadata?["meta1"] as? String, "value1")
        XCTAssertEqual(variant.metadata?["meta2"] as? String, "value2")
    }

    func testFromMap_minimalFields_parsesCorrectly() {
        let variantMap: [String: Any] = [
            "key": "test-key",
            "value": "test-value"
        ]

        let variant = VariantCodec.fromMap(variantMap)

        XCTAssertEqual(variant.key, "test-key")
        XCTAssertEqual(variant.value, "test-value")
        XCTAssertNil(variant.payload)
        XCTAssertNil(variant.expKey)
        XCTAssertNil(variant.metadata)
    }

    func testFromMap_metadataAsJsonString_parsesCorrectly() {
        let variantMap: [String: Any] = [
            "key": "test-key",
            "metadata": #"{"nested":{"key":"value"}}"#
        ]

        let variant = VariantCodec.fromMap(variantMap)

        XCTAssertNotNil(variant.metadata)
        let nested = variant.metadata?["nested"] as? [String: Any]
        XCTAssertNotNil(nested)
        XCTAssertEqual(nested?["key"] as? String, "value")
    }

    func testToMap_allFields_convertsCorrectly() {
        let variant = Variant(
            "test-value",
            payload: "payload-data",
            expKey: "exp-123",
            key: "test-key",
            metadata: ["meta1": "value1", "meta2": "value2"]
        )

        let result = VariantCodec.toMap(variant)

        XCTAssertEqual(result["key"] as? String, "test-key")
        XCTAssertEqual(result["value"] as? String, "test-value")
        XCTAssertEqual(result["payload"] as? String, "payload-data")
        XCTAssertEqual(result["expKey"] as? String, "exp-123")
        XCTAssertTrue(result["metadata"] is String)
        let metadataString = result["metadata"] as! String
        XCTAssertTrue(metadataString.contains("meta1"))
    }

    func testToMap_nullVariant_returnsEmptyMap() {
        let result = VariantCodec.toMap(nil)

        XCTAssertTrue(result.isEmpty)
    }

    func testToMap_minimalFields_excludesNulls() {
        let variant = Variant(
            "test-value",
            payload: nil,
            expKey: nil,
            key: "test-key",
            metadata: nil
        )

        let result = VariantCodec.toMap(variant)

        XCTAssertEqual(result["key"] as? String, "test-key")
        XCTAssertEqual(result["value"] as? String, "test-value")
        XCTAssertNil(result["payload"])
        XCTAssertNil(result["expKey"])
        XCTAssertNil(result["metadata"])
    }

    func testRoundTrip_allFields_preservesData() {
        let originalMap = TestDataHelpers.createTestVariantMap(
            key: "test-key",
            value: "test-value",
            payload: "payload-data",
            expKey: "exp-123",
            metadata: #"{"meta1":"value1"}"#
        )

        let variant = VariantCodec.fromMap(originalMap)
        let resultMap = VariantCodec.toMap(variant)

        XCTAssertEqual(originalMap["key"] as? String, resultMap["key"] as? String)
        XCTAssertEqual(originalMap["value"] as? String, resultMap["value"] as? String)
        XCTAssertEqual(originalMap["expKey"] as? String, resultMap["expKey"] as? String)
        // Metadata is converted to JSON string, so we verify it contains the original data
        let metadataString = resultMap["metadata"] as? String
        XCTAssertNotNil(metadataString)
        XCTAssertTrue(metadataString!.contains("meta1"))
    }

    func testRoundTrip_minimalFields_preservesData() {
        let originalMap: [String: Any] = [
            "key": "test-key",
            "value": "test-value"
        ]

        let variant = VariantCodec.fromMap(originalMap)
        let resultMap = VariantCodec.toMap(variant)

        XCTAssertEqual(originalMap["key"] as? String, resultMap["key"] as? String)
        XCTAssertEqual(originalMap["value"] as? String, resultMap["value"] as? String)
    }
}
