import AmplitudeExperiment
import Foundation

/**
 * Codec for serializing and deserializing Variant objects to/from Maps
 * for method channel communication.
 */
enum VariantCodec {
    /**
     * Parses a Variant from a Map representation.
     * @param variantMap The map containing variant data
     * @return A Variant object parsed from the map
     */
    static func fromMap(_ variantMap: [String: Any]) -> Variant {
        let metadata: [String: Any]? = (variantMap["metadata"] as? String)
            .flatMap { $0.data(using: .utf8) }
            .flatMap {
                try? JSONSerialization.jsonObject(with: $0) as? [String: Any]
            }

        return Variant(
            variantMap["value"] as? String,
            payload: variantMap["payload"],
            expKey: variantMap["expKey"] as? String,
            key: variantMap["key"] as? String,
            metadata: metadata
        )
    }

    /**
     * Converts a native iOS Variant object to a Map that can be serialized
     * and sent to Flutter via method channels.
     * @param variant The variant to convert, or null
     * @return A map representation of the variant, or empty map if variant is null
     */
    static func toMap(_ variant: Variant?) -> [String: Any?] {
        guard let variant = variant else {
            return [:]
        }

        var map: [String: Any?] = [:]
        if let key = variant.key {
            map["key"] = key
        }
        if let value = variant.value {
            map["value"] = value
        }
        if let payload = variant.payload {
            map["payload"] = String(describing: payload)
        }
        if let expKey = variant.expKey {
            map["expKey"] = expKey
        }
        if let metadata = variant.metadata,
            let metadataData = try? JSONSerialization.data(
                withJSONObject: metadata
            ),
            let metadataString = String(data: metadataData, encoding: .utf8)
        {
            map["metadata"] = metadataString
        }

        return map
    }
}
