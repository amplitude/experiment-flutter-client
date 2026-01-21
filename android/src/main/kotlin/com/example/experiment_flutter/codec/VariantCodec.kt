package com.example.experiment_flutter.codec

import com.amplitude.experiment.Variant
import com.example.experiment_flutter.toMap
import org.json.JSONObject

/**
 * Codec for serializing and deserializing Variant objects to/from Maps
 * for method channel communication.
 */
object VariantCodec {
    /**
     * Parses a Variant from a Map representation.
     * @param variantMap The map containing variant data
     * @return A Variant object parsed from the map
     */
    fun fromMap(variantMap: Map<String, Any>): Variant {
        return Variant(
            value = variantMap["value"] as? String,
            payload = variantMap["payload"],
            expKey = variantMap["expKey"] as? String,
            key = variantMap["key"] as? String,
            metadata = (variantMap["metadata"] as? String)?.let { JSONObject(it).toMap() }
        )
    }

    /**
     * Converts a native Android Variant object to a Map that can be serialized
     * and sent to Flutter via method channels.
     * @param variant The variant to convert, or null
     * @return A map representation of the variant, or empty map if variant is null
     */
    fun toMap(variant: Variant?): Map<String, Any?> {
        if (variant == null) {
            return emptyMap()
        }

        val map = mutableMapOf<String, Any?>()
        variant.key?.let { map["key"] = it }
        variant.value?.let { map["value"] = it }
        variant.payload?.let { map["payload"] = it.toString() }
        variant.expKey?.let { map["expKey"] = it }
        variant.metadata?.let { map["metadata"] = JSONObject(it).toString() }

        return map
    }
}
