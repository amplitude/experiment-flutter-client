package com.example.experiment_flutter

/**
 * Helper functions for creating test data structures used in unit tests.
 */
object TestDataHelpers {
    /**
     * Creates a test config map with all fields populated.
     */
    fun createTestConfigMap(
        instanceName: String = "test-instance",
        fetchOnStart: Boolean = true,
        fetchTimeoutMillis: Int = 10000,
        flagsServerUrl: String = "https://flags.example.com",
        serverUrl: String = "https://api.example.com",
        serverZone: String = "us",
        source: String = "localStorage",
        retryFetchOnFailure: Boolean = true,
        pollOnStart: Boolean = false,
        automaticExposureTracking: Boolean = true,
        automaticFetchOnAmplitudeIdentityChange: Boolean = false,
        initialFlags: String? = null,
        flagConfigPollingIntervalMillis: Int? = null,
        fallbackVariant: Map<String, Any>? = null,
        initialVariants: Map<String, Map<String, Any>>? = null
    ): Map<String, Any> {
        val map = mutableMapOf<String, Any>(
            "instanceName" to instanceName,
            "fetchOnStart" to fetchOnStart,
            "fetchTimeoutMillis" to fetchTimeoutMillis,
            "flagsServerUrl" to flagsServerUrl,
            "serverUrl" to serverUrl,
            "serverZone" to serverZone,
            "source" to source,
            "retryFetchOnFailure" to retryFetchOnFailure,
            "pollOnStart" to pollOnStart,
            "automaticExposureTracking" to automaticExposureTracking,
            "automaticFetchOnAmplitudeIdentityChange" to automaticFetchOnAmplitudeIdentityChange
        )
        
        initialFlags?.let { map["initialFlags"] = it }
        flagConfigPollingIntervalMillis?.let { map["flagConfigPollingIntervalMillis"] = it }
        fallbackVariant?.let { map["fallbackVariant"] = it }
        initialVariants?.let { map["initialVariants"] = it }
        
        return map
    }

    /**
     * Creates a test variant map with all fields populated.
     */
    fun createTestVariantMap(
        key: String = "test-key",
        value: String = "test-value",
        payload: Any? = null,
        expKey: String? = "exp-123",
        metadata: String? = null
    ): Map<String, Any> {
        val map = mutableMapOf<String, Any>(
            "key" to key,
            "value" to value
        )
        
        payload?.let { map["payload"] = it }
        expKey?.let { map["expKey"] = it }
        metadata?.let { map["metadata"] = it }
        
        return map
    }

    /**
     * Creates a test user map with basic fields.
     */
    fun createTestUserMap(
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
        userProperties: String? = null,
        groups: String? = null,
        groupProperties: String? = null
    ): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        
        deviceId?.let { map["deviceId"] = it }
        userId?.let { map["userId"] = it }
        country?.let { map["country"] = it }
        city?.let { map["city"] = it }
        region?.let { map["region"] = it }
        dma?.let { map["dma"] = it }
        language?.let { map["language"] = it }
        platform?.let { map["platform"] = it }
        version?.let { map["version"] = it }
        os?.let { map["os"] = it }
        deviceModel?.let { map["deviceModel"] = it }
        deviceBrand?.let { map["deviceBrand"] = it }
        deviceManufacturer?.let { map["deviceManufacturer"] = it }
        carrier?.let { map["carrier"] = it }
        library?.let { map["library"] = it }
        userProperties?.let { map["userProperties"] = it }
        groups?.let { map["groups"] = it }
        groupProperties?.let { map["groupProperties"] = it }
        
        return map
    }

    /**
     * Creates a test user map with complex JSON fields.
     */
    fun createTestUserMapWithComplexFields(): Map<String, Any> {
        return createTestUserMap(
            userId = "user-123",
            userProperties = """{"prop1":"value1","prop2":"value2"}""",
            groups = """{"group1":["member1","member2"],"group2":["member3"]}""",
            // groupProperties expects 3-level structure: Map<String, Map<String, Map<String, Any?>>>
            groupProperties = """{"group1":{"properties":{"role":"admin","level":"high"}}}"""
        )
    }
}
