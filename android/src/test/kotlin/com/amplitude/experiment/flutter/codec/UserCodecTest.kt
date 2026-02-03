package com.amplitude.experiment.flutter.codec

import com.amplitude.experiment.ExperimentUser
import com.amplitude.experiment.flutter.TestDataHelpers
import org.json.JSONException
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.test.assertFailsWith

class UserCodecTest {
    @Test
    fun fromMap_basicFields_parsesCorrectly() {
        val userMap = TestDataHelpers.createTestUserMap(
            deviceId = "device-123",
            userId = "user-123",
            country = "US",
            city = "San Francisco"
        )

        val user = UserCodec.fromMap(userMap)

        assertNotNull(user)
        val u = user!!
        assertEquals("device-123", u.deviceId)
        assertEquals("user-123", u.userId)
        assertEquals("US", u.country)
        assertEquals("San Francisco", u.city)
    }

    @Test
    fun fromMap_allStringFields_parsesCorrectly() {
        val userMap = TestDataHelpers.createTestUserMap(
            deviceId = "device-123",
            userId = "user-123",
            country = "US",
            city = "SF",
            region = "CA",
            dma = "807",
            language = "en",
            platform = "Android",
            version = "1.0.0",
            os = "Android",
            deviceModel = "Pixel",
            deviceBrand = "Google",
            deviceManufacturer = "Google",
            carrier = "Verizon",
            library = "test-lib"
        )

        val user = UserCodec.fromMap(userMap)

        assertNotNull(user)
        val u = user!!
        assertEquals("device-123", u.deviceId)
        assertEquals("user-123", u.userId)
        assertEquals("US", u.country)
        assertEquals("SF", u.city)
        assertEquals("CA", u.region)
        assertEquals("807", u.dma)
        assertEquals("en", u.language)
        assertEquals("Android", u.platform)
        assertEquals("1.0.0", u.version)
        assertEquals("Android", u.os)
        assertEquals("Pixel", u.deviceModel)
        assertEquals("Google", u.deviceBrand)
        assertEquals("Google", u.deviceManufacturer)
        assertEquals("Verizon", u.carrier)
        assertEquals("test-lib", u.library)
    }

    @Test
    fun fromMap_userPropertiesJsonString_parsesCorrectly() {
        val userMap = mapOf(
            "userId" to "user-123",
            "userProperties" to """{"prop1":"value1","prop2":"value2"}"""
        )

        val user = UserCodec.fromMap(userMap)

        assertNotNull(user)
        val u = user!!
        assertNotNull(u.userProperties)
        val props = u.userProperties!!
        assertEquals("value1", props["prop1"])
        assertEquals("value2", props["prop2"])
    }

    @Test
    fun fromMap_groupsJsonString_parsesCorrectly() {
        val userMap = mapOf(
            "userId" to "user-123",
            "groups" to """{"group1":["member1","member2"],"group2":["member3"]}"""
        )

        val user = UserCodec.fromMap(userMap)

        assertNotNull(user)
        val u = user!!
        assertNotNull(u.groups)
        val groups = u.groups!!
        val group1 = groups["group1"]
        assertNotNull(group1)
        assertTrue(group1.contains("member1"))
        assertTrue(group1.contains("member2"))
        val group2 = groups["group2"]
        assertNotNull(group2)
        assertTrue(group2.contains("member3"))
    }

    @Test
    fun fromMap_groupPropertiesJsonString_parsesCorrectly() {
        // groupProperties expects 3-level structure: Map<String, Map<String, Map<String, Any?>>>
        // Format: {"group1": {"propertyKey": {"role": "admin", "level": "high"}}}
        val userMap = mapOf(
            "userId" to "user-123",
            "groupProperties" to """{"group1":{"properties":{"role":"admin","level":"high"}}}"""
        )

        val user = UserCodec.fromMap(userMap)

        assertNotNull(user)
        val u = user!!
        assertNotNull(u.groupProperties)
        val groupProps = u.groupProperties!!
        val group1Props = groupProps["group1"]
        assertNotNull(group1Props)
        val props = group1Props!!["properties"]
        assertNotNull(props)
        val innerProps = props!!
        assertEquals("admin", innerProps["role"] as String)
        assertEquals("high", innerProps["level"] as String)
    }

    @Test
    fun fromMap_invalidUserPropertiesJson_throwsException() {
        val userMap = mapOf(
            "userId" to "user-123",
            "userProperties" to "invalid json {"
        )

        // Current implementation throws exception for invalid JSON
        assertFailsWith<JSONException> {
            UserCodec.fromMap(userMap)
        }
    }

    @Test
    fun fromMap_invalidGroupsJson_throwsException() {
        val userMap = mapOf(
            "userId" to "user-123",
            "groups" to "invalid json {"
        )

        // Current implementation throws exception for invalid JSON
        assertFailsWith<JSONException> {
            UserCodec.fromMap(userMap)
        }
    }

    @Test
    fun fromMap_invalidGroupPropertiesJson_throwsException() {
        val userMap = mapOf(
            "userId" to "user-123",
            "groupProperties" to "invalid json {"
        )

        // Current implementation throws exception for invalid JSON
        assertFailsWith<JSONException> {
            UserCodec.fromMap(userMap)
        }
    }

    @Test
    fun fromMap_nullMap_returnsNull() {
        val user = UserCodec.fromMap(null)

        assertNull(user)
    }

    @Test
    fun toMap_basicFields_convertsCorrectly() {
        val user = ExperimentUser.Builder()
            .userId("user-123")
            .deviceId("device-123")
            .country("US")
            .city("San Francisco")
            .build()

        val result = UserCodec.toMap(user)

        assertEquals("user-123", result["userId"])
        assertEquals("device-123", result["deviceId"])
        assertEquals("US", result["country"])
        assertEquals("San Francisco", result["city"])
    }

    @Test
    fun toMap_userProperties_convertsToJsonString() {
        val user = ExperimentUser.Builder()
            .userId("user-123")
            .userProperties(mapOf("prop1" to "value1", "prop2" to "value2"))
            .build()

        val result = UserCodec.toMap(user)

        assertTrue(result["userProperties"] is String)
        val jsonString = result["userProperties"] as String
        assertTrue(jsonString.contains("prop1"))
        assertTrue(jsonString.contains("value1"))
    }

    @Test
    fun toMap_groups_convertsSetToListInJsonString() {
        val user = ExperimentUser.Builder()
            .userId("user-123")
            .groups(mapOf("group1" to setOf("member1", "member2")))
            .build()

        val result = UserCodec.toMap(user)

        assertTrue(result["groups"] is String)
        val jsonString = result["groups"] as String
        assertTrue(jsonString.contains("group1"))
        assertTrue(jsonString.contains("member1"))
        assertTrue(jsonString.contains("member2"))
    }

    @Test
    fun toMap_nullUser_returnsEmptyMap() {
        val result = UserCodec.toMap(null)

        assertTrue(result.isEmpty())
    }

    @Test
    fun roundTrip_basicFields_preservesData() {
        val originalMap = TestDataHelpers.createTestUserMap(
            userId = "user-123",
            deviceId = "device-123",
            country = "US"
        )

        val user = UserCodec.fromMap(originalMap)
        assertNotNull(user)
        val resultMap = UserCodec.toMap(user)

        assertEquals("user-123", resultMap["userId"])
        assertEquals("device-123", resultMap["deviceId"])
        assertEquals("US", resultMap["country"])
    }

    @Test
    fun roundTrip_complexFields_preservesData() {
        val originalMap = TestDataHelpers.createTestUserMapWithComplexFields()

        val user = UserCodec.fromMap(originalMap)
        assertNotNull(user)
        val u = user!!
        val resultMap = UserCodec.toMap(user)

        // Verify basic field
        assertEquals("user-123", resultMap["userId"])

        // Verify userProperties - should be converted to JSON string and back
        assertNotNull(u.userProperties)
        assertTrue(resultMap["userProperties"] is String)
        val userPropsJson = resultMap["userProperties"] as String
        assertTrue(userPropsJson.contains("prop1"))
        assertTrue(userPropsJson.contains("value1"))
        assertTrue(userPropsJson.contains("prop2"))
        assertTrue(userPropsJson.contains("value2"))

        // Verify groups - should be converted to JSON string and back
        assertNotNull(u.groups)
        assertTrue(resultMap["groups"] is String)
        val groupsJson = resultMap["groups"] as String
        assertTrue(groupsJson.contains("group1"))
        assertTrue(groupsJson.contains("member1"))
        assertTrue(groupsJson.contains("member2"))
        assertTrue(groupsJson.contains("group2"))
        assertTrue(groupsJson.contains("member3"))

        // Verify groupProperties - should be converted to JSON string and back
        assertNotNull(u.groupProperties)
        assertTrue(resultMap["groupProperties"] is String)
        val groupPropsJson = resultMap["groupProperties"] as String
        assertTrue(groupPropsJson.contains("group1"))
        assertTrue(groupPropsJson.contains("role"))
        assertTrue(groupPropsJson.contains("admin"))
        assertTrue(groupPropsJson.contains("level"))
        assertTrue(groupPropsJson.contains("high"))
    }
}