import AmplitudeExperiment
import Foundation

/**
 * Codec for serializing and deserializing ExperimentUser objects to/from Maps
 * for method channel communication.
 */
enum UserCodec {
    /**
     * Parses an ExperimentUser from a Map representation.
     * @param userMap The map containing user data
     * @return An ExperimentUser object parsed from the map, or nil if userMap is nil
     */
    static func fromMap(_ userMap: [String: Any]?) -> ExperimentUser? {
        guard let userArgs = userMap else {
            return nil
        }

        let builder = ExperimentUserBuilder()

        if let deviceId = userArgs["deviceId"] as? String {
            builder.deviceId(deviceId)
        }
        if let userId = userArgs["userId"] as? String {
            builder.userId(userId)
        }
        if let country = userArgs["country"] as? String {
            builder.country(country)
        }
        if let city = userArgs["city"] as? String {
            builder.city(city)
        }
        if let region = userArgs["region"] as? String {
            builder.region(region)
        }
        if let dma = userArgs["dma"] as? String {
            builder.dma(dma)
        }
        if let language = userArgs["language"] as? String {
            builder.language(language)
        }
        if let platform = userArgs["platform"] as? String {
            builder.platform(platform)
        }
        if let version = userArgs["version"] as? String {
            builder.version(version)
        }
        if let os = userArgs["os"] as? String {
            builder.os(os)
        }
        if let deviceModel = userArgs["deviceModel"] as? String {
            builder.deviceModel(deviceModel)
        }
        if let deviceManufacturer = userArgs["deviceManufacturer"] as? String {
            builder.deviceManufacturer(deviceManufacturer)
        }
        if let carrier = userArgs["carrier"] as? String {
            builder.carrier(carrier)
        }
        if let library = userArgs["library"] as? String {
            builder.library(library)
        }

        // Decode userProperties from JSON string
        if let userPropertiesString = userArgs["userProperties"] as? String,
            let userPropertiesData = userPropertiesString.data(using: .utf8),
            let userProperties = try? JSONSerialization.jsonObject(
                with: userPropertiesData
            ) as? [String: Any]
        {
            builder.userProperties(userProperties)
        }

        // Decode groups from JSON string (Map<String, List<String>>)
        if let groupsString = userArgs["groups"] as? String,
            let groupsData = groupsString.data(using: .utf8),
            let groupsDict = try? JSONSerialization.jsonObject(with: groupsData)
                as? [String: Any]
        {
            var groups: [String: [String]] = [:]
            for (key, value) in groupsDict {
                if let list = value as? [String] {
                    groups[key] = list
                }
            }
            builder.groups(groups)
        }

        // Decode groupProperties from JSON string (Map<String, Map<String, Map<String, Any?>>>)
        if let groupPropertiesString = userArgs["groupProperties"] as? String,
            let groupPropertiesData = groupPropertiesString.data(using: .utf8),
            let groupPropertiesDict = try? JSONSerialization.jsonObject(
                with: groupPropertiesData
            ) as? [String: Any]
        {
            var groupProperties: [String: [String: [String: Any?]]] = [:]
            for (groupKey, groupValue) in groupPropertiesDict {
                if let groupMap = groupValue as? [String: Any] {
                    var innerMap: [String: [String: Any?]] = [:]
                    for (propertyKey, propertyValue) in groupMap {
                        if let propertyMap = propertyValue as? [String: Any] {
                            var finalMap: [String: Any?] = [:]
                            for (key, value) in propertyMap {
                                finalMap[key] = value
                            }
                            innerMap[propertyKey] = finalMap
                        }
                    }
                    groupProperties[groupKey] = innerMap
                }
            }
            builder.groupProperties(groupProperties)
        }

        return builder.build()
    }

    /**
     * Converts a native iOS ExperimentUser object to a Map that can be serialized
     * and sent to Flutter via method channels.
     * @param user The user to convert, or nil
     * @return A map representation of the user, or empty map if user is nil
     */
    static func toMap(_ user: ExperimentUser?) -> [String: Any?] {
        guard let user = user else {
            return [:]
        }

        var map: [String: Any?] = [:]

        if let deviceId = user.deviceId {
            map["deviceId"] = deviceId
        }
        if let userId = user.userId {
            map["userId"] = userId
        }
        if let country = user.country {
            map["country"] = country
        }
        if let city = user.city {
            map["city"] = city
        }
        if let region = user.region {
            map["region"] = region
        }
        if let dma = user.dma {
            map["dma"] = dma
        }
        if let language = user.language {
            map["language"] = language
        }
        if let platform = user.platform {
            map["platform"] = platform
        }
        if let version = user.version {
            map["version"] = version
        }
        if let os = user.os {
            map["os"] = os
        }
        if let deviceModel = user.deviceModel {
            map["deviceModel"] = deviceModel
        }
        if let deviceManufacturer = user.deviceManufacturer {
            map["deviceManufacturer"] = deviceManufacturer
        }
        if let carrier = user.carrier {
            map["carrier"] = carrier
        }
        if let library = user.library {
            map["library"] = library
        }

        // Encode userProperties to JSON string
        if let userProperties = user.userProperties,
            let userPropertiesData = try? JSONSerialization.data(
                withJSONObject: userProperties
            ),
            let userPropertiesString = String(
                data: userPropertiesData,
                encoding: .utf8
            )
        {
            map["userProperties"] = userPropertiesString
        }

        // Encode groups to JSON string (Map<String, List<String>>)
        if let groups = user.groups {
            var groupsAsList: [String: [String]] = [:]
            for (key, value) in groups {
                groupsAsList[key] = Array(value)
            }
            if let groupsData = try? JSONSerialization.data(
                withJSONObject: groupsAsList
            ),
                let groupsString = String(data: groupsData, encoding: .utf8)
            {
                map["groups"] = groupsString
            }
        }

        // Encode groupProperties to JSON string (Map<String, Map<String, Map<String, Any?>>>)
        if let groupProperties = user.groupProperties,
            let groupPropertiesData = try? JSONSerialization.data(
                withJSONObject: groupProperties
            ),
            let groupPropertiesString = String(
                data: groupPropertiesData,
                encoding: .utf8
            )
        {
            map["groupProperties"] = groupPropertiesString
        }

        return map
    }
}
