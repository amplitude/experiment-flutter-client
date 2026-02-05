package com.amplitude.experiment.flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import org.mockito.Mockito

/**
 * Shared test data and plugin setup for unit tests.
 * Provides Pigeon (Host API) types and avoids repeating mock boilerplate.
 */
object TestDataHelpers {

    // ---------- Pigeon (Flutter) types for Host API ----------

    /**
     * Creates a Pigeon [Variant] for use in Host API tests.
     */
    fun createPigeonVariant(
        key: String? = "test-key",
        value: String? = "test-value",
        payload: Any? = null,
        expKey: String? = "exp-123",
        metadata: Map<String, Any?>? = null,
    ): Variant = Variant(
        key = key,
        value = value,
        payload = payload,
        expKey = expKey,
        metadata = metadata,
    )

    /**
     * Creates a Pigeon [ExperimentUser] for use in Host API tests.
     */
    fun createPigeonUser(
        deviceId: String? = "device-123",
        userId: String? = "user-123",
        country: String? = "US",
        city: String? = "San Francisco",
        region: String? = "CA",
        dma: String? = null,
        language: String? = "en",
        platform: String? = "Android",
        version: String? = "1.0.0",
        os: String? = "Android",
        deviceModel: String? = "Pixel",
        deviceBrand: String? = "Google",
        deviceManufacturer: String? = "Google",
        carrier: String? = null,
        library: String? = null,
        ipAddress: String? = null,
        userProperties: Map<String, Any>? = null,
        groups: Map<String, List<String>>? = null,
        groupProperties: Map<String, Map<String, Map<String, Any?>>>? = null,
    ): ExperimentUser = ExperimentUser(
        deviceId = deviceId,
        userId = userId,
        country = country,
        city = city,
        region = region,
        dma = dma,
        language = language,
        platform = platform,
        version = version,
        os = os,
        deviceModel = deviceModel,
        deviceBrand = deviceBrand,
        deviceManufacturer = deviceManufacturer,
        carrier = carrier,
        library = library,
        ipAddress = ipAddress,
        userProperties = userProperties,
        groups = groups,
        groupProperties = groupProperties,
    )

    /**
     * Creates a Pigeon [ExperimentConfig] for use in Host API tests.
     */
    fun createPigeonConfig(
        instanceName: String = "test-instance",
        logLevel: LogLevel = LogLevel.WARN,
        fallbackVariant: Variant = createPigeonVariant(),
        initialFlags: String? = null,
        initialVariants: Map<String, Variant> = emptyMap(),
        source: Source = Source.LOCAL_STORAGE,
        serverZone: ServerZone = ServerZone.US,
        serverUrl: String = "https://api.example.com",
        flagsServerUrl: String = "https://flags.example.com",
        fetchTimeoutMillis: Long = 10000L,
        retryFetchOnFailure: Boolean = true,
        automaticExposureTracking: Boolean = true,
        fetchOnStart: Boolean = true,
        pollOnStart: Boolean = false,
        automaticFetchOnAmplitudeIdentityChange: Boolean = false,
    ): ExperimentConfig = ExperimentConfig(
        logLevel = logLevel,
        instanceName = instanceName,
        fallbackVariant = fallbackVariant,
        initialFlags = initialFlags,
        initialVariants = initialVariants,
        source = source,
        serverZone = serverZone,
        serverUrl = serverUrl,
        flagsServerUrl = flagsServerUrl,
        fetchTimeoutMillis = fetchTimeoutMillis,
        retryFetchOnFailure = retryFetchOnFailure,
        automaticExposureTracking = automaticExposureTracking,
        fetchOnStart = fetchOnStart,
        pollOnStart = pollOnStart,
        automaticFetchOnAmplitudeIdentityChange = automaticFetchOnAmplitudeIdentityChange,
    )

    /**
     * Attaches the plugin to a mock [FlutterPlugin.FlutterPluginBinding] and returns the plugin.
     * Use this to get a plugin instance ready for Host API calls (init, variant, etc.).
     */
    fun createAttachedPlugin(): Pair<AmplitudeExperimentPlugin, FlutterPlugin.FlutterPluginBinding> {
        val plugin = AmplitudeExperimentPlugin()
        val mockBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        val mockContext = Mockito.mock(android.content.Context::class.java)
        val mockBinaryMessenger = Mockito.mock(io.flutter.plugin.common.BinaryMessenger::class.java)
        Mockito.`when`(mockBinding.applicationContext).thenReturn(mockContext)
        Mockito.`when`(mockBinding.binaryMessenger).thenReturn(mockBinaryMessenger)
        plugin.onAttachedToEngine(mockBinding)
        return plugin to mockBinding
    }
}
