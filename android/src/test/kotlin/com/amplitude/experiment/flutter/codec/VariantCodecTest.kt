package com.amplitude.experiment.flutter.codec

import com.amplitude.experiment.Variant
import com.amplitude.experiment.flutter.TestDataHelpers
import kotlin.collections.get
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class VariantCodecTest {
    @Test
    fun fromMap_allFields_parsesCorrectly() {
        val variantMap = TestDataHelpers.createTestVariantMap(
            key = "test-key",
            value = "test-value",
            payload = "payload-data",
            expKey = "exp-123",
            metadata = """{"meta1":"value1","meta2":"value2"}"""
        )

        val variant = VariantCodec.fromMap(variantMap)

        assertEquals("test-key", variant.key)
        assertEquals("test-value", variant.value)
        assertEquals("payload-data", variant.payload)
        assertEquals("exp-123", variant.expKey)
        assertNotNull(variant.metadata)
        assertEquals("value1", variant.metadata?.get("meta1"))
        assertEquals("value2", variant.metadata?.get("meta2"))
    }

    @Test
    fun fromMap_minimalFields_parsesCorrectly() {
        val variantMap = mapOf(
            "key" to "test-key",
            "value" to "test-value"
        )

        val variant = VariantCodec.fromMap(variantMap)

        assertEquals("test-key", variant.key)
        assertEquals("test-value", variant.value)
        assertNull(variant.payload)
        assertNull(variant.expKey)
        assertNull(variant.metadata)
    }

    @Test
    fun fromMap_metadataAsJsonString_parsesCorrectly() {
        val variantMap = mapOf(
            "key" to "test-key",
            "metadata" to """{"nested":{"key":"value"}}"""
        )

        val variant = VariantCodec.fromMap(variantMap)

        assertNotNull(variant.metadata)
        val nested = variant.metadata?.get("nested") as? Map<*, *>
        assertNotNull(nested)
        assertEquals("value", nested["key"])
    }

    @Test
    fun toMap_allFields_convertsCorrectly() {
        val variant = Variant(
            key = "test-key",
            value = "test-value",
            payload = "payload-data",
            expKey = "exp-123",
            metadata = mapOf("meta1" to "value1", "meta2" to "value2")
        )

        val result = VariantCodec.toMap(variant)

        assertEquals("test-key", result["key"])
        assertEquals("test-value", result["value"])
        assertEquals("payload-data", result["payload"])
        assertEquals("exp-123", result["expKey"])
        assertTrue(result["metadata"] is String)
        assertTrue((result["metadata"] as String).contains("meta1"))
    }

    @Test
    fun toMap_nullVariant_returnsEmptyMap() {
        val result = VariantCodec.toMap(null)

        assertTrue(result.isEmpty())
    }

    @Test
    fun toMap_minimalFields_excludesNulls() {
        val variant = Variant(
            key = "test-key",
            value = "test-value"
        )

        val result = VariantCodec.toMap(variant)

        assertEquals("test-key", result["key"])
        assertEquals("test-value", result["value"])
        assertNull(result["payload"])
        assertNull(result["expKey"])
        assertNull(result["metadata"])
    }

    @Test
    fun roundTrip_allFields_preservesData() {
        val originalMap = TestDataHelpers.createTestVariantMap(
            key = "test-key",
            value = "test-value",
            payload = "payload-data",
            expKey = "exp-123",
            metadata = """{"meta1":"value1"}"""
        )

        val variant = VariantCodec.fromMap(originalMap)
        val resultMap = VariantCodec.toMap(variant)

        assertEquals(originalMap["key"], resultMap["key"])
        assertEquals(originalMap["value"], resultMap["value"])
        assertEquals(originalMap["expKey"], resultMap["expKey"])
        // Metadata is converted to JSON string, so we verify it contains the original data
        assertTrue((resultMap["metadata"] as? String)?.contains("meta1") == true)
    }

    @Test
    fun roundTrip_minimalFields_preservesData() {
        val originalMap = mapOf(
            "key" to "test-key",
            "value" to "test-value"
        )

        val variant = VariantCodec.fromMap(originalMap)
        val resultMap = VariantCodec.toMap(variant)

        assertEquals(originalMap["key"], resultMap["key"])
        assertEquals(originalMap["value"], resultMap["value"])
    }
}
