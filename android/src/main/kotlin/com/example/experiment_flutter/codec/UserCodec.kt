package com.example.experiment_flutter.codec

import android.util.Log
import com.amplitude.experiment.ExperimentUser
import com.example.experiment_flutter.toJSONObject
import com.example.experiment_flutter.toMap
import org.json.JSONObject

/**
 * Codec for serializing and deserializing ExperimentUser objects to/from Maps
 * for method channel communication.
 */
object UserCodec {
    /**
     * Parses an ExperimentUser from a Map representation.
     * @param userMap The map containing user data
     * @return An ExperimentUser object parsed from the map, or null if userMap is null
     */
    fun fromMap(userMap: Map<String, Any>?): ExperimentUser? {
        return userMap?.let { userArgs ->
            val builder = ExperimentUser.Builder()
            (userArgs["deviceId"] as? String)?.let { builder.deviceId(it) }
            (userArgs["userId"] as? String)?.let { builder.userId(it) }
            (userArgs["country"] as? String)?.let { builder.country(it) }
            (userArgs["city"] as? String)?.let { builder.city(it) }
            (userArgs["region"] as? String)?.let { builder.region(it) }
            (userArgs["dma"] as? String)?.let { builder.dma(it) }
            (userArgs["language"] as? String)?.let { builder.language(it) }
            (userArgs["platform"] as? String)?.let { builder.platform(it) }
            (userArgs["version"] as? String)?.let { builder.version(it) }
            (userArgs["os"] as? String)?.let { builder.os(it) }
            (userArgs["deviceModel"] as? String)?.let { builder.deviceModel(it) }
            (userArgs["deviceBrand"] as? String)?.let { builder.deviceBrand(it) }
            (userArgs["deviceManufacturer"] as? String)?.let { builder.deviceManufacturer(it) }
            (userArgs["carrier"] as? String)?.let { builder.carrier(it) }
            (userArgs["library"] as? String)?.let { builder.library(it) }

            // Decode userProperties from JSON string
            (userArgs["userProperties"] as? String)?.let { jsonString ->
                val jsonObject = JSONObject(jsonString)
                val userPropsMap = jsonObject.toMap() as Map<String, Any>
                builder.userProperties(userPropsMap)
            }

            // Decode groups from JSON string (Map<String, List<String>>)
            (userArgs["groups"] as? String)?.let { jsonString ->
                val jsonObject = JSONObject(jsonString)
                val groupsMap = jsonObject.toMap().mapValues { (_, value) ->
                    (value as? List<*>)?.map { it.toString() }?.toSet() ?: emptySet()
                } as Map<String, Set<String>>
                builder.groups(groupsMap)
            }

            // Decode groupProperties from JSON string (Map<String, Map<String, Map<String, Any?>>>)
            (userArgs["groupProperties"] as? String)?.let { jsonString ->
                val jsonObject = JSONObject(jsonString)
                val groupPropsMap = jsonObject.toMap().mapValues { (_, value) ->
                    (value as? Map<*, *>)?.mapValues { (_, innerValue) ->
                        (innerValue as? Map<*, *>)?.mapValues { it.value } as? Map<String, Any?>
                    } as? Map<String, Map<String, Any?>>
                } as Map<String, Map<String, Map<String, Any?>>>
                builder.groupProperties(groupPropsMap)
            }

            builder.build()
        }
    }

    /**
     * Converts a native Android ExperimentUser object to a Map that can be serialized
     * and sent to Flutter via method channels.
     * @param user The user to convert, or null
     * @return A map representation of the user, or empty map if user is null
     */
    fun toMap(user: ExperimentUser?): Map<String, Any?> {
        if (user == null) {
            return emptyMap()
        }

        val map = mutableMapOf<String, Any?>()
        user.deviceId?.let { map["deviceId"] = it }
        user.userId?.let { map["userId"] = it }
        user.country?.let { map["country"] = it }
        user.city?.let { map["city"] = it }
        user.region?.let { map["region"] = it }
        user.dma?.let { map["dma"] = it }
        user.language?.let { map["language"] = it }
        user.platform?.let { map["platform"] = it }
        user.version?.let { map["version"] = it }
        user.os?.let { map["os"] = it }
        user.deviceModel?.let { map["deviceModel"] = it }
        user.deviceBrand?.let { map["deviceBrand"] = it }
        user.deviceManufacturer?.let { map["deviceManufacturer"] = it }
        user.carrier?.let { map["carrier"] = it }
        user.library?.let { map["library"] = it }

        // Encode userProperties to JSON string
        user.userProperties?.let { userProps ->
            try {
                val jsonObject = userProps.toJSONObject()
                map["userProperties"] = jsonObject?.toString()
            } catch (e: Exception) {
                Log.e("ExperimentFlutter", "Error encoding userProperties: ${e.message}")
            }
        }

        // Encode groups to JSON string (Map<String, List<String>>)
        user.groups?.let { groups ->
            try {
                // Convert Set<String> to List<String> for Dart compatibility
                val groupsAsList = groups.mapValues { (_, value) ->
                    value.toList()
                }
                val jsonObject = groupsAsList.toJSONObject()
                map["groups"] = jsonObject?.toString()
            } catch (e: Exception) {
                Log.e("ExperimentFlutter", "Error encoding groups: ${e.message}")
            }
        }

        // Encode groupProperties to JSON string (Map<String, Map<String, Map<String, Any?>>>)
        user.groupProperties?.let { groupProps ->
            try {
                val jsonObject = groupProps.toJSONObject()
                map["groupProperties"] = jsonObject?.toString()
            } catch (e: Exception) {
                Log.e("ExperimentFlutter", "Error encoding groupProperties: ${e.message}")
            }
        }

        return map
    }
}
