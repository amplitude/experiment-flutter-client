package com.amplitude.experiment.flutter.codec

import com.amplitude.experiment.ServerZone
import com.amplitude.experiment.Source
import com.amplitude.experiment.flutter.TestDataHelpers
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.fail

class ConfigCodecTest {
    @Test
    fun fromMap_basicFields_parsesCorrectly() {
        val configMap = TestDataHelpers.createTestConfigMap(
            instanceName = "test-instance",
            fetchOnStart = true,
            fetchTimeoutMillis = 10000,
            flagsServerUrl = "https://flags.example.com",
            serverUrl = "https://api.example.com"
        )

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals("test-instance", c.instanceName)
        assertEquals(true, c.fetchOnStart)
        assertEquals(10000L, c.fetchTimeoutMillis)
        assertEquals("https://flags.example.com", c.flagsServerUrl)
        assertEquals("https://api.example.com", c.serverUrl)
    }

    @Test
    fun fromMap_allFields_parsesCorrectly() {
        val configMap = TestDataHelpers.createTestConfigMap(
            instanceName = "test-instance",
            fetchOnStart = true,
            fetchTimeoutMillis = 5000,
            flagsServerUrl = "https://flags.example.com",
            serverUrl = "https://api.example.com",
            serverZone = "us",
            source = "localStorage",
            retryFetchOnFailure = true,
            pollOnStart = false,
            automaticExposureTracking = true,
            automaticFetchOnAmplitudeIdentityChange = false,
            initialFlags = "{}",
            flagConfigPollingIntervalMillis = 60000
        )

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals("test-instance", c.instanceName)
        assertEquals(true, c.fetchOnStart)
        assertEquals(5000L, c.fetchTimeoutMillis)
        assertEquals("https://flags.example.com", c.flagsServerUrl)
        assertEquals("https://api.example.com", c.serverUrl)
        assertEquals(ServerZone.US, c.serverZone)
        assertEquals(Source.LOCAL_STORAGE, c.source)
        assertEquals(true, c.retryFetchOnFailure)
        assertEquals(false, c.pollOnStart)
        assertEquals(true, c.automaticExposureTracking)
        assertEquals(false, c.automaticFetchOnAmplitudeIdentityChange)
        assertEquals("{}", c.initialFlags)
        assertEquals(60000L, c.flagConfigPollingIntervalMillis)
    }

    @Test
    fun fromMap_serverZoneUs_parsesCorrectly() {
        val configMap = TestDataHelpers.createTestConfigMap(serverZone = "us")

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals(ServerZone.US, c.serverZone)
    }

    @Test
    fun fromMap_serverZoneEu_parsesCorrectly() {
        val configMap = TestDataHelpers.createTestConfigMap(serverZone = "eu")

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals(ServerZone.EU, c.serverZone)
    }

    @Test
    fun fromMap_sourceLocalStorage_parsesCorrectly() {
        val configMap = TestDataHelpers.createTestConfigMap(source = "localStorage")

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals(Source.LOCAL_STORAGE, c.source)
    }

    @Test
    fun fromMap_sourceInitialVariants_parsesCorrectly() {
        val configMap = TestDataHelpers.createTestConfigMap(source = "initialVariants")

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals(Source.INITIAL_VARIANTS, c.source)
    }

    @Test
    fun fromMap_fallbackVariant_parsesCorrectly() {
        val fallbackVariant = TestDataHelpers.createTestVariantMap(
            key = "fallback-key",
            value = "fallback-value"
        )
        val configMap = TestDataHelpers.createTestConfigMap(
            fallbackVariant = fallbackVariant
        )

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertNotNull(c.fallbackVariant)
        val variant = c.fallbackVariant!!
        assertEquals("fallback-key", variant.key)
        assertEquals("fallback-value", variant.value)
    }

    @Test
    fun fromMap_initialVariants_parsesCorrectly() {
        val initialVariants = mapOf(
            "flag1" to TestDataHelpers.createTestVariantMap(key = "flag1", value = "value1"),
            "flag2" to TestDataHelpers.createTestVariantMap(key = "flag2", value = "value2")
        )
        val configMap = TestDataHelpers.createTestConfigMap(
            initialVariants = initialVariants
        )

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertNotNull(c.initialVariants)
        val variants = c.initialVariants!!
        assertEquals(2, variants.size)
        assertEquals("flag1", variants["flag1"]?.key)
        assertEquals("value1", variants["flag1"]?.value)
        assertEquals("flag2", variants["flag2"]?.key)
        assertEquals("value2", variants["flag2"]?.value)
    }

    @Test
    fun fromMap_nullMap_returnsNull() {
        val config = ConfigCodec.fromMap(null)

        assertNull(config)
    }

    @Test
    fun fromMap_optionalFields_handlesNulls() {
        val configMap = mapOf<String, Any>(
            "instanceName" to "test-instance"
        )

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals("test-instance", c.instanceName)
        // Other fields should use defaults from builder
    }

    @Test
    fun fromMap_invalidServerZone_throwsException() {
        val configMap = TestDataHelpers.createTestConfigMap(serverZone = "invalid")

        try {
            ConfigCodec.fromMap(configMap)
            fail("Expected IllegalArgumentException")
        } catch (e: IllegalArgumentException) {
            // Expected
        }
    }

    @Test
    fun fromMap_invalidSource_throwsException() {
        val configMap = TestDataHelpers.createTestConfigMap(source = "invalid")

        try {
            ConfigCodec.fromMap(configMap)
            fail("Expected IllegalArgumentException")
        } catch (e: IllegalArgumentException) {
            // Expected
        }
    }

    @Test
    fun fromMap_fetchTimeoutMillis_convertsIntToLong() {
        val configMap = TestDataHelpers.createTestConfigMap(fetchTimeoutMillis = 5000)

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals(5000L, c.fetchTimeoutMillis)
    }

    @Test
    fun fromMap_flagConfigPollingIntervalMillis_convertsIntToLong() {
        val configMap = TestDataHelpers.createTestConfigMap(
            flagConfigPollingIntervalMillis = 30000
        )

        val config = ConfigCodec.fromMap(configMap)

        assertNotNull(config)
        val c = config!!
        assertEquals(30000L, c.flagConfigPollingIntervalMillis)
    }
}
