package com.amplitude.experiment.flutter

import com.amplitude.experiment.Source as SdkSource
import com.amplitude.experiment.ServerZone as SdkServerZone
import com.amplitude.experiment.Variant as SdkVariant
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import org.mockito.Mockito

/**
 * Unit tests for the Experiment SDK codec (ExperimentSdkCodec.kt).
 * Verifies conversion between Pigeon/Flutter types and Amplitude Experiment SDK types.
 */
internal class ExperimentSdkCodecTest {

    private lateinit var mockApi: CustomProviderApi

    @Before
    fun setUp() {
        val mockMessenger = Mockito.mock(BinaryMessenger::class.java)
        mockApi = CustomProviderApi(mockMessenger)
    }

    // ---------- convertVariant (Pigeon -> SDK) ----------

    @Test
    fun convertVariant_pigeonToSdk_mapsAllFields() {
        val pigeon = TestDataHelpers.createPigeonVariant(
            key = "k",
            value = "v",
            payload = "payload",
            expKey = "exp",
            metadata = mapOf("a" to 1),
        )
        val sdk = requireNotNull(variantFromPigeon(pigeon))
        assertEquals("k", sdk.key)
        assertEquals("v", sdk.value)
        assertEquals("payload", sdk.payload)
        assertEquals("exp", sdk.expKey)
        assertEquals(mapOf("a" to 1), sdk.metadata)
    }

    @Test
    fun convertVariant_null_returnsNull() {
        assertNull(variantFromPigeon(null as com.amplitude.experiment.flutter.Variant?))
    }

    // ---------- convertVariant (SDK -> Pigeon) ----------

    @Test
    fun convertVariant_sdkToPigeon_mapsAllFields() {
        val sdk = SdkVariant("v", "payload", "exp", "k", mapOf("a" to 1))
        val pigeon = variantToPigeon(sdk)
        assertEquals("k", pigeon.key)
        assertEquals("v", pigeon.value)
        assertEquals("payload", pigeon.payload)
        assertEquals("exp", pigeon.expKey)
        assertEquals(mapOf("a" to 1), pigeon.metadata)
    }

    @Test
    fun convertVariant_roundTrip_preservesData() {
        val pigeon = TestDataHelpers.createPigeonVariant(
            key = "k",
            value = "v",
            payload = 42,
            expKey = "e",
            metadata = mapOf("m" to "n"),
        )
        val sdk = variantFromPigeon(pigeon)!!
        val back = variantToPigeon(sdk)
        assertEquals(pigeon.key, back.key)
        assertEquals(pigeon.value, back.value)
        assertEquals(pigeon.payload, back.payload)
        assertEquals(pigeon.expKey, back.expKey)
        assertEquals(pigeon.metadata, back.metadata)
    }

    // ---------- convertUser ----------

    @Test
    fun convertUser_pigeonToSdk_mapsScalarFields() {
        val pigeon = TestDataHelpers.createPigeonUser(
            deviceId = "dev-1",
            userId = "u-1",
            country = "US",
            city = "NYC",
            region = "NY",
            language = "en",
            platform = "Android",
            version = "1.0",
            os = "Android",
        )
        val sdk = requireNotNull(convertUser(pigeon))
        assertEquals("dev-1", sdk.deviceId)
        assertEquals("u-1", sdk.userId)
        assertEquals("US", sdk.country)
        assertEquals("NYC", sdk.city)
        assertEquals("NY", sdk.region)
        assertEquals("en", sdk.language)
        assertEquals("Android", sdk.platform)
        assertEquals("1.0", sdk.version)
        assertEquals("Android", sdk.os)
    }

    @Test
    fun convertUser_null_returnsNull() {
        assertNull(convertUser(null))
    }

    @Test
    fun convertUser_groups_convertedToListToSet() {
        val groups = mapOf("g1" to listOf("a", "b"))
        val pigeon = TestDataHelpers.createPigeonUser(groups = groups)
        val sdk = requireNotNull(convertUser(pigeon))
        assertNotNull(sdk.groups)
        assertEquals(setOf("a", "b"), sdk.groups!!["g1"])
    }

    @Test
    fun convertUser_nullLibrary_usesFlutterLibraryDefault() {
        val pigeon = TestDataHelpers.createPigeonUser(library = null)
        val sdk = requireNotNull(convertUser(pigeon))
        assertEquals(
            "experiment-flutter-client/0.1.0-alpha.1_experiment-android-client/1.15.0",
            sdk.library,
        )
    }

    @Test
    fun convertUser_explicitLibrary_preservesValue() {
        val pigeon = TestDataHelpers.createPigeonUser(library = "custom-lib/1.0")
        val sdk = requireNotNull(convertUser(pigeon))
        assertEquals("custom-lib/1.0", sdk.library)
    }

    @Test
    fun convertUser_userProperties_preserved() {
        val props = mapOf<String, Any>("p1" to "v1", "p2" to 2)
        val pigeon = TestDataHelpers.createPigeonUser(userProperties = props)
        val sdk = requireNotNull(convertUser(pigeon))
        assertEquals(props, sdk.userProperties)
    }

    // ---------- convertConfig ----------

    @Test
    fun convertConfig_pigeonToSdk_mapsAllFields() {
        val pigeon = TestDataHelpers.createPigeonConfig(
            instanceName = "my-instance",
            initialFlags = "flag1,flag2",
            serverUrl = "https://api.test.com",
            flagsServerUrl = "https://flags.test.com",
            fetchTimeoutMillis = 5000L,
            retryFetchOnFailure = false,
            automaticExposureTracking = false,
            fetchOnStart = false,
            pollOnStart = true,
            automaticFetchOnAmplitudeIdentityChange = true,
            source = Source.INITIAL_VARIANTS,
            serverZone = ServerZone.EU,
            initialVariants = mapOf(
                "f1" to TestDataHelpers.createPigeonVariant(value = "on"),
            ),
        )
        val sdk = convertConfig(pigeon, mockApi)
        assertEquals("my-instance", sdk.instanceName)
        assertEquals("flag1,flag2", sdk.initialFlags)
        assertEquals("https://api.test.com", sdk.serverUrl)
        assertEquals("https://flags.test.com", sdk.flagsServerUrl)
        assertEquals(5000L, sdk.fetchTimeoutMillis)
        assertEquals(false, sdk.retryFetchOnFailure)
        assertEquals(false, sdk.automaticExposureTracking)
        assertEquals(false, sdk.fetchOnStart)
        assertEquals(true, sdk.pollOnStart)
        assertEquals(true, sdk.automaticFetchOnAmplitudeIdentityChange)
        assertEquals(SdkSource.INITIAL_VARIANTS, sdk.source)
        assertEquals(SdkServerZone.EU, sdk.serverZone)
        assertEquals(1, sdk.initialVariants.size)
        assertEquals("on", sdk.initialVariants["f1"]!!.value)
    }

    @Test
    fun convertConfig_source_localStorage_mapsToSdk() {
        val pigeon = TestDataHelpers.createPigeonConfig(source = Source.LOCAL_STORAGE)
        val sdk = convertConfig(pigeon, mockApi)
        assertEquals(SdkSource.LOCAL_STORAGE, sdk.source)
    }

    @Test
    fun convertConfig_serverZone_usAndEu_mapsToSdk() {
        val sdkUs = convertConfig(TestDataHelpers.createPigeonConfig(serverZone = ServerZone.US), mockApi)
        assertEquals(SdkServerZone.US, sdkUs.serverZone)
        val sdkEu = convertConfig(TestDataHelpers.createPigeonConfig(serverZone = ServerZone.EU), mockApi)
        assertEquals(SdkServerZone.EU, sdkEu.serverZone)
    }

    @Test
    fun convertConfig_defaultPigeonConfig_producesValidSdkConfig() {
        val pigeon = TestDataHelpers.createPigeonConfig()
        val sdk = convertConfig(pigeon, mockApi)
        assertEquals("test-instance", sdk.instanceName)
        assertEquals(10000L, sdk.fetchTimeoutMillis)
        assertEquals(true, sdk.retryFetchOnFailure)
        assertEquals(true, sdk.automaticExposureTracking)
        assertEquals(true, sdk.fetchOnStart)
        assertEquals(false, sdk.pollOnStart)
        assertEquals(false, sdk.automaticFetchOnAmplitudeIdentityChange)
        assertEquals(SdkSource.LOCAL_STORAGE, sdk.source)
        assertEquals(SdkServerZone.US, sdk.serverZone)
        assertNotNull(sdk.initialVariants)
        assertEquals(0, sdk.initialVariants.size)
    }

    // ---------- convertFetchOptions ----------

    @Test
    fun convertFetchOptions_null_returnsNull() {
        assertNull(convertFetchOptions(null))
    }

    @Test
    fun convertFetchOptions_withFlagKeys_mapsFlagKeys() {
        val pigeon = FetchOptions(flagKeys = listOf("flag-1", "flag-2"))
        val sdk = requireNotNull(convertFetchOptions(pigeon))
        assertEquals(listOf("flag-1", "flag-2"), sdk.flagKeys)
    }

    @Test
    fun convertFetchOptions_withNullFlagKeys_mapsNullFlagKeys() {
        val pigeon = FetchOptions(flagKeys = null)
        val sdk = requireNotNull(convertFetchOptions(pigeon))
        assertNull(sdk.flagKeys)
    }
}
