import Foundation

/**
 * Helper functions for creating test data structures used in unit tests.
 */
enum TestDataHelpers {
    /**
     * Creates a test config map with all fields populated.
     */
    static func createTestConfigMap(
        instanceName: String = "test-instance",
        fetchOnStart: Bool = true,
        fetchTimeoutMillis: Int = 10000,
        flagsServerUrl: String = "https://flags.example.com",
        serverUrl: String = "https://api.example.com",
        serverZone: String = "us",
        source: String = "localStorage",
        retryFetchOnFailure: Bool = true,
        pollOnStart: Bool = false,
        automaticExposureTracking: Bool = true,
        automaticFetchOnAmplitudeIdentityChange: Bool = false,
        initialFlags: String? = nil,
        flagConfigPollingIntervalMillis: Int? = nil,
        fallbackVariant: [String: Any]? = nil,
        initialVariants: [String: [String: Any]]? = nil
    ) -> [String: Any] {
        var map: [String: Any] = [
            "instanceName": instanceName,
            "fetchOnStart": fetchOnStart,
            "fetchTimeoutMillis": fetchTimeoutMillis,
            "flagsServerUrl": flagsServerUrl,
            "serverUrl": serverUrl,
            "serverZone": serverZone,
            "source": source,
            "retryFetchOnFailure": retryFetchOnFailure,
            "pollOnStart": pollOnStart,
            "automaticExposureTracking": automaticExposureTracking,
            "automaticFetchOnAmplitudeIdentityChange": automaticFetchOnAmplitudeIdentityChange
        ]
        
        if let initialFlags = initialFlags {
            map["initialFlags"] = initialFlags
        }
        if let flagConfigPollingIntervalMillis = flagConfigPollingIntervalMillis {
            map["flagConfigPollingIntervalMillis"] = flagConfigPollingIntervalMillis
        }
        if let fallbackVariant = fallbackVariant {
            map["fallbackVariant"] = fallbackVariant
        }
        if let initialVariants = initialVariants {
            map["initialVariants"] = initialVariants
        }
        
        return map
    }

    /**
     * Creates a test variant map with all fields populated.
     */
    static func createTestVariantMap(
        key: String = "test-key",
        value: String = "test-value",
        payload: Any? = nil,
        expKey: String? = "exp-123",
        metadata: String? = nil
    ) -> [String: Any] {
        var map: [String: Any] = [
            "key": key,
            "value": value
        ]
        
        if let payload = payload {
            map["payload"] = payload
        }
        if let expKey = expKey {
            map["expKey"] = expKey
        }
        if let metadata = metadata {
            map["metadata"] = metadata
        }
        
        return map
    }

    /**
     * Creates a test user map with basic fields.
     */
    static func createTestUserMap(
        deviceId: String? = "device-123",
        userId: String? = "user-123",
        country: String? = "US",
        city: String? = "San Francisco",
        region: String? = "CA",
        dma: String? = nil,
        language: String? = "en",
        platform: String? = "iOS",
        version: String? = "1.0.0",
        os: String? = "iOS",
        deviceModel: String? = "iPhone",
        deviceBrand: String? = "Apple",
        deviceManufacturer: String? = "Apple",
        carrier: String? = nil,
        library: String? = nil,
        userProperties: String? = nil,
        groups: String? = nil,
        groupProperties: String? = nil
    ) -> [String: Any] {
        var map: [String: Any] = [:]
        
        if let deviceId = deviceId {
            map["deviceId"] = deviceId
        }
        if let userId = userId {
            map["userId"] = userId
        }
        if let country = country {
            map["country"] = country
        }
        if let city = city {
            map["city"] = city
        }
        if let region = region {
            map["region"] = region
        }
        if let dma = dma {
            map["dma"] = dma
        }
        if let language = language {
            map["language"] = language
        }
        if let platform = platform {
            map["platform"] = platform
        }
        if let version = version {
            map["version"] = version
        }
        if let os = os {
            map["os"] = os
        }
        if let deviceModel = deviceModel {
            map["deviceModel"] = deviceModel
        }
        if let deviceBrand = deviceBrand {
            map["deviceBrand"] = deviceBrand
        }
        if let deviceManufacturer = deviceManufacturer {
            map["deviceManufacturer"] = deviceManufacturer
        }
        if let carrier = carrier {
            map["carrier"] = carrier
        }
        if let library = library {
            map["library"] = library
        }
        if let userProperties = userProperties {
            map["userProperties"] = userProperties
        }
        if let groups = groups {
            map["groups"] = groups
        }
        if let groupProperties = groupProperties {
            map["groupProperties"] = groupProperties
        }
        
        return map
    }

    /**
     * Creates a test user map with complex JSON fields.
     */
    static func createTestUserMapWithComplexFields() -> [String: Any] {
        return createTestUserMap(
            userId: "user-123",
            userProperties: #"{"prop1":"value1","prop2":"value2"}"#,
            groups: #"{"group1":["member1","member2"],"group2":["member3"]}"#,
            // groupProperties expects 3-level structure: Map<String, Map<String, Map<String, Any?>>>
            groupProperties: #"{"group1":{"properties":{"role":"admin","level":"high"}}}"#
        )
    }
}
