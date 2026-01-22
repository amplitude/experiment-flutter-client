import XCTest
@testable import experiment_flutter
import AmplitudeExperiment

class UserCodecTests: XCTestCase {
    func testFromMap_basicFields_parsesCorrectly() {
        let userMap = TestDataHelpers.createTestUserMap(
            deviceId: "device-123",
            userId: "user-123",
            country: "US",
            city: "San Francisco"
        )

        let user = UserCodec.fromMap(userMap)

        XCTAssertNotNil(user)
        XCTAssertEqual(user?.deviceId, "device-123")
        XCTAssertEqual(user?.userId, "user-123")
        XCTAssertEqual(user?.country, "US")
        XCTAssertEqual(user?.city, "San Francisco")
    }

    func testFromMap_allStringFields_parsesCorrectly() {
        let userMap = TestDataHelpers.createTestUserMap(
            deviceId: "device-123",
            userId: "user-123",
            country: "US",
            city: "SF",
            region: "CA",
            dma: "807",
            language: "en",
            platform: "iOS",
            version: "1.0.0",
            os: "iOS",
            deviceModel: "iPhone",
            deviceBrand: "Apple",
            deviceManufacturer: "Apple",
            carrier: "Verizon",
            library: "test-lib"
        )

        let user = UserCodec.fromMap(userMap)

        XCTAssertNotNil(user)
        let u = user!
        XCTAssertEqual(u.deviceId, "device-123")
        XCTAssertEqual(u.userId, "user-123")
        XCTAssertEqual(u.country, "US")
        XCTAssertEqual(u.city, "SF")
        XCTAssertEqual(u.region, "CA")
        XCTAssertEqual(u.dma, "807")
        XCTAssertEqual(u.language, "en")
        XCTAssertEqual(u.platform, "iOS")
        XCTAssertEqual(u.version, "1.0.0")
        XCTAssertEqual(u.os, "iOS")
        XCTAssertEqual(u.deviceModel, "iPhone")
        XCTAssertEqual(u.deviceManufacturer, "Apple")
        XCTAssertEqual(u.carrier, "Verizon")
        XCTAssertEqual(u.library, "test-lib")
    }

    func testFromMap_userPropertiesJsonString_parsesCorrectly() {
        let userMap: [String: Any] = [
            "userId": "user-123",
            "userProperties": #"{"prop1":"value1","prop2":"value2"}"#
        ]

        let user = UserCodec.fromMap(userMap)

        XCTAssertNotNil(user)
        let u = user!
        XCTAssertNotNil(u.userProperties)
        let props = u.userProperties!
        XCTAssertEqual(props["prop1"] as? String, "value1")
        XCTAssertEqual(props["prop2"] as? String, "value2")
    }

    func testFromMap_groupsJsonString_parsesCorrectly() {
        let userMap: [String: Any] = [
            "userId": "user-123",
            "groups": #"{"group1":["member1","member2"],"group2":["member3"]}"#
        ]

        let user = UserCodec.fromMap(userMap)

        XCTAssertNotNil(user)
        let u = user!
        XCTAssertNotNil(u.groups)
        let groups = u.groups!
        let group1 = groups["group1"]
        XCTAssertNotNil(group1)
        XCTAssertTrue(group1!.contains("member1"))
        XCTAssertTrue(group1!.contains("member2"))
        let group2 = groups["group2"]
        XCTAssertNotNil(group2)
        XCTAssertTrue(group2!.contains("member3"))
    }

    func testFromMap_groupPropertiesJsonString_parsesCorrectly() {
        // groupProperties expects 3-level structure: Map<String, Map<String, Map<String, Any?>>>
        // Format: {"group1": {"propertyKey": {"role": "admin", "level": "high"}}}
        let userMap: [String: Any] = [
            "userId": "user-123",
            "groupProperties": #"{"group1":{"properties":{"role":"admin","level":"high"}}}"#
        ]

        let user = UserCodec.fromMap(userMap)

        XCTAssertNotNil(user)
        let u = user!
        XCTAssertNotNil(u.groupProperties)
        let groupProps = u.groupProperties!
        let group1Props = groupProps["group1"]
        XCTAssertNotNil(group1Props)
        let props = group1Props!["properties"]
        XCTAssertNotNil(props)
        let innerProps = props!
        XCTAssertEqual(innerProps["role"] as? String, "admin")
        XCTAssertEqual(innerProps["level"] as? String, "high")
    }

    func testFromMap_invalidUserPropertiesJson_handlesGracefully() {
        let userMap: [String: Any] = [
            "userId": "user-123",
            "userProperties": "invalid json {"
        ]

        // Current implementation handles invalid JSON gracefully (returns nil for userProperties)
        let user = UserCodec.fromMap(userMap)
        XCTAssertNotNil(user)
        // userProperties should be nil due to invalid JSON
    }

    func testFromMap_invalidGroupsJson_handlesGracefully() {
        let userMap: [String: Any] = [
            "userId": "user-123",
            "groups": "invalid json {"
        ]

        // Current implementation handles invalid JSON gracefully
        let user = UserCodec.fromMap(userMap)
        XCTAssertNotNil(user)
        // groups should be nil due to invalid JSON
    }

    func testFromMap_invalidGroupPropertiesJson_handlesGracefully() {
        let userMap: [String: Any] = [
            "userId": "user-123",
            "groupProperties": "invalid json {"
        ]

        // Current implementation handles invalid JSON gracefully
        let user = UserCodec.fromMap(userMap)
        XCTAssertNotNil(user)
        // groupProperties should be nil due to invalid JSON
    }

    func testFromMap_nullMap_returnsNil() {
        let user = UserCodec.fromMap(nil)

        XCTAssertNil(user)
    }

    func testToMap_basicFields_convertsCorrectly() {
        let builder = ExperimentUserBuilder()
        builder.userId("user-123")
        builder.deviceId("device-123")
        builder.country("US")
        builder.city("San Francisco")
        let user = builder.build()

        let result = UserCodec.toMap(user)

        XCTAssertEqual(result["userId"] as? String, "user-123")
        XCTAssertEqual(result["deviceId"] as? String, "device-123")
        XCTAssertEqual(result["country"] as? String, "US")
        XCTAssertEqual(result["city"] as? String, "San Francisco")
    }

    func testToMap_userProperties_convertsToJsonString() {
        let builder = ExperimentUserBuilder()
        builder.userId("user-123")
        builder.userProperties(["prop1": "value1", "prop2": "value2"])
        let user = builder.build()

        let result = UserCodec.toMap(user)

        XCTAssertTrue(result["userProperties"] is String)
        let jsonString = result["userProperties"] as! String
        XCTAssertTrue(jsonString.contains("prop1"))
        XCTAssertTrue(jsonString.contains("value1"))
    }

    func testToMap_groups_convertsSetToListInJsonString() {
        let builder = ExperimentUserBuilder()
        builder.userId("user-123")
        builder.groups(["group1": ["member1", "member2"]])
        let user = builder.build()

        let result = UserCodec.toMap(user)

        XCTAssertTrue(result["groups"] is String)
        let jsonString = result["groups"] as! String
        XCTAssertTrue(jsonString.contains("group1"))
        XCTAssertTrue(jsonString.contains("member1"))
        XCTAssertTrue(jsonString.contains("member2"))
    }

    func testToMap_nullUser_returnsEmptyMap() {
        let result = UserCodec.toMap(nil)

        XCTAssertTrue(result.isEmpty)
    }

    func testRoundTrip_basicFields_preservesData() {
        let originalMap = TestDataHelpers.createTestUserMap(
            deviceId: "device-123",
            userId: "user-123",
            country: "US"
        )

        let user = UserCodec.fromMap(originalMap)
        XCTAssertNotNil(user)
        let resultMap = UserCodec.toMap(user)

        XCTAssertEqual(originalMap["userId"] as? String, resultMap["userId"] as? String)
        XCTAssertEqual(originalMap["deviceId"] as? String, resultMap["deviceId"] as? String)
        XCTAssertEqual(originalMap["country"] as? String, resultMap["country"] as? String)
    }

    func testRoundTrip_complexFields_preservesData() {
        let originalMap = TestDataHelpers.createTestUserMapWithComplexFields()

        let user = UserCodec.fromMap(originalMap)
        XCTAssertNotNil(user)
        let u = user!
        let resultMap = UserCodec.toMap(user)

        // Verify basic field
        XCTAssertEqual("user-123", resultMap["userId"] as? String)

        // Verify userProperties - should be converted to JSON string and back
        XCTAssertNotNil(u.userProperties)
        XCTAssertTrue(resultMap["userProperties"] is String)
        let userPropsJson = resultMap["userProperties"] as! String
        XCTAssertTrue(userPropsJson.contains("prop1"))
        XCTAssertTrue(userPropsJson.contains("value1"))
        XCTAssertTrue(userPropsJson.contains("prop2"))
        XCTAssertTrue(userPropsJson.contains("value2"))

        // Verify groups - should be converted to JSON string and back
        XCTAssertNotNil(u.groups)
        XCTAssertTrue(resultMap["groups"] is String)
        let groupsJson = resultMap["groups"] as! String
        XCTAssertTrue(groupsJson.contains("group1"))
        XCTAssertTrue(groupsJson.contains("member1"))
        XCTAssertTrue(groupsJson.contains("member2"))
        XCTAssertTrue(groupsJson.contains("group2"))
        XCTAssertTrue(groupsJson.contains("member3"))

        // Verify groupProperties - should be converted to JSON string and back
        XCTAssertNotNil(u.groupProperties)
        XCTAssertTrue(resultMap["groupProperties"] is String)
        let groupPropsJson = resultMap["groupProperties"] as! String
        XCTAssertTrue(groupPropsJson.contains("group1"))
        XCTAssertTrue(groupPropsJson.contains("role"))
        XCTAssertTrue(groupPropsJson.contains("admin"))
        XCTAssertTrue(groupPropsJson.contains("level"))
        XCTAssertTrue(groupPropsJson.contains("high"))
    }
}
