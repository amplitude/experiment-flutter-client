package com.example.experiment_flutter

import android.app.Application
import android.content.Context
import android.util.Log
import com.amplitude.experiment.Experiment
import com.amplitude.experiment.ExperimentClient
import com.amplitude.experiment.ExperimentConfig
import com.amplitude.experiment.ExperimentUser
import com.amplitude.experiment.ServerZone
import com.amplitude.experiment.Source
import com.amplitude.experiment.Variant
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject

/** ExperimentFlutterPlugin */
class ExperimentFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler {

    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var ctxt: Context

    private var instances:  Map<String, ExperimentClient> = mutableMapOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        ctxt = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "experiment_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "init") {
            val config = getConfiguration(call)!!
            val client = Experiment.initialize(ctxt as Application, call.argument<String>("apiKey")!!, config)
            instances += mapOf(config.instanceName to client)
            result.success("experiment initialized")
            return
        } else if (call.method == "initWithAmplitude") {
            val config = getConfiguration(call)!!
            val client = Experiment.initializeWithAmplitudeAnalytics(ctxt as Application, call.argument<String>("apiKey")!!, config)
            instances += mapOf(config.instanceName to client)
            result.success("experiment initialized")
            return
        }

        val instanceName = call.argument<String>("instanceName") ?: "\$default_instance"
        val client = instances[instanceName] ?: throw IllegalArgumentException("Experiment instance $instanceName not found")
        when (call.method) {
            "all" -> {
                val allVariants = client.all()
                val variantMap = allVariants.mapValues { variantToMap(it.value) }
                result.success(variantMap)
            }

            "fetch" -> {
                client.fetch(getExperimentUser(call)).get()
                result.success("Instance [$instanceName] has fetched data")
            }

            "start" -> {
                client.start(getExperimentUser(call))
                result.success("Instance [$instanceName] has started")
            }

            "stop" -> {
                client.stop()
                result.success("Instance [$instanceName] has stopped")
            }

            "clear" -> {
                client.clear()
                result.success("Instance [$instanceName] has been cleared")
            }

            "getVariant" -> {
                val flagKey = call.argument<String>("flagKey")
                    ?: throw IllegalArgumentException("flagKey is required")
                result.success(variantToMap(client.variant(flagKey)))
            }

            "variant" -> {
                val flagKey = call.argument<String>("flagKey")
                    ?: throw IllegalArgumentException("flagKey is required")
                val fallbackVariant = call.argument<Map<String, Any>>("fallbackVariant")?.let { parseVariant(it) }
                result.success(variantToMap(client.variant(flagKey, fallbackVariant)))
            }

            "setUser" -> {
                client.setUser(getExperimentUser(call)!!)
                result.success("User set")
            }

            "getUser" -> {
                result.success(experimentUserToMap(client.getUser()))
            }

            "exposure" -> {
                val key = call.argument<String>("key") ?: throw IllegalArgumentException("key is required")
                client.exposure(key)
                result.success("Exposure for $key was tracked")
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getConfiguration(call: MethodCall): ExperimentConfig? {
        return call.argument<Map<String, Any>>("config")?.let {
                configMap ->
            val builder = ExperimentConfig.builder()

            (configMap["instanceName"] as? String)?.let { builder.instanceName(it)}
            (configMap["fallbackVariant"] as? Map<String, Any>)?.let { builder.fallbackVariant(parseVariant(it))}
            (configMap["fetchOnStart"] as? Boolean)?.let { builder.fetchOnStart(it)}
            (configMap["fetchTimeoutMillis"] as? Int)?.let { builder.fetchTimeoutMillis(it.toLong())}
            (configMap["flagsServerUrl"] as? String)?.let { builder.flagsServerUrl(it)}
            (configMap["flagConfigPollingIntervalMillis"] as? Int)?.let { builder.flagConfigPollingIntervalMillis(it.toLong())}
            (configMap["initialFlags"] as? String)?.let { builder.initialFlags(it)}
            (configMap["pollOnStart"] as? Boolean)?.let { builder.pollOnStart(it)}
            (configMap["retryFetchOnFailure"] as? Boolean)?.let { builder.retryFetchOnFailure(it)}
            (configMap["serverUrl"] as? String)?.let { builder.serverUrl(it)}
            (configMap["serverZone"] as? String)?.let { builder.serverZone(parseServerZone(it))}
            (configMap["source"] as? String)?.let { builder.source(parseSource(it))}
            (configMap["automaticExposureTracking"] as? Boolean)?.let { builder.automaticExposureTracking(it)}
            (configMap["automaticFetchOnAmplitudeIdentityChange"] as? Boolean)?.let { builder.automaticFetchOnAmplitudeIdentityChange(it)}

            (configMap["initialVariants"] as? Map<String, Any>)?.let {
                    map -> map.mapValues { (_, value) -> parseVariant(value as Map<String, Any>)}
            }?.let {builder.initialVariants( it )}

            builder.build()
        }
    }
//    private fun getConfiguration(call: MethodCall): ExperimentConfig {
//        val config = ExperimentConfig.builder()
//
//        call.argument<String>("instanceName")?.let {config.instanceName(it)}
//        call.argument<Map<String, Any>>("fallbackVariant")?.let {  config.fallbackVariant(parseVariant(it))}
//        call.argument<Boolean>("fetchOnStart")?.let {config.fetchOnStart(it)}
//        call.argument<Int>("fetchTimeoutMillis")?.let {config.fetchTimeoutMillis(it.toLong())}
//        call.argument<String>("flagsServerUrl")?.let {config.flagsServerUrl(it)}
//        call.argument<Int>("flagConfigPollingIntervalMillis")?.let {config.flagConfigPollingIntervalMillis(it.toLong())}
//        call.argument<String>("initialFlags")?.let {config.initialFlags(it)}
//        call.argument<Boolean>("pollOnStart")?.let {config.pollOnStart(it)}
//        call.argument<Boolean>("retryFetchOnFailure")?.let { config.retryFetchOnFailure(it) }
//        call.argument<String>("serverUrl")?.let {config.serverUrl(it)}
//        call.argument<String>("serverZone")?.let {config.serverZone(parseServerZone(it))}
//        call.argument<String>("source")?.let {config.source(parseSource(it))}
//        call.argument<Boolean>("automaticExposureTracking")?.let { config.automaticExposureTracking(it) }
//        call.argument<Boolean>("automaticFetchOnAmplitudeIdentityChange")?.let { config.automaticFetchOnAmplitudeIdentityChange(it) }
//
//        // Parse initialVariants
//        call.argument<Map<String, Any>>("initialVariants")?.let {
//                map -> map.mapValues { (_, value) -> parseVariant(value as Map<String, Any>) }
//        }?.let { config.initialVariants(it) }
//
//        return config.build()
//    }

    private fun parseVariant(args: Map<String, Any>) : Variant {
         return Variant( value = args["key"] as? String,
                payload = args["payload"],
                expKey = args["expKey"] as? String,
                key = args["key"] as? String,
                metadata = (args["metadata"] as? String)?.let { JSONObject(it).toMap() })
    }

    private fun parseSource(source: String) : Source {
        return when(source) {
            "localStorage" ->
                Source.LOCAL_STORAGE
            "initialVariants" ->
                Source.INITIAL_VARIANTS
            else ->
                throw IllegalArgumentException()
        }
    }

    private fun parseServerZone(serverZone: String) : ServerZone {
        return when(serverZone) {
            "us" ->
                ServerZone.US
            "eu" ->
                ServerZone.EU
            else ->
                throw IllegalArgumentException()
        }
    }

    /**
     * Converts a native Android Variant object to a Map that can be serialized
     * and sent to Flutter via method channels.
     */
    private fun variantToMap(variant: Variant?): Map<String, Any?> {
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

    private fun getExperimentUser(call: MethodCall): ExperimentUser? {
         return call.argument<Map<String, Any>>("user")?.let {
            userArgs ->
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
                 try {
                     val jsonObject = JSONObject(jsonString)
                     val userPropsMap = jsonObject.toMap() as Map<String, Any>
                     builder.userProperties(userPropsMap)
                 } catch (e: Exception) {
                     Log.e("ExperimentFlutter", "Error parsing userProperties: ${e.message}")
                 }
             }

             // Decode groups from JSON string (Map<String, List<String>>)
             (userArgs["groups"] as? String)?.let { jsonString ->
                 try {
                     val jsonObject = JSONObject(jsonString)
                     val groupsMap = jsonObject.toMap().mapValues { (_, value) ->
                         (value as? List<*>)?.map { it.toString() }?.toSet() ?: emptySet()
                     } as Map<String, Set<String>>
                     builder.groups(groupsMap)
                 } catch (e: Exception) {
                     Log.e("ExperimentFlutter", "Error parsing groups: ${e.message}")
                 }
             }

             // Decode groupProperties from JSON string (Map<String, Map<String, Map<String, Any?>>>)
             (userArgs["groupProperties"] as? String)?.let { jsonString ->
                 try {
                     val jsonObject = JSONObject(jsonString)
                     val groupPropsMap = jsonObject.toMap().mapValues { (_, value) ->
                         (value as? Map<*, *>)?.mapValues { (_, innerValue) ->
                             (innerValue as? Map<*, *>)?.mapValues { it.value } as? Map<String, Any?>
                         } as? Map<String, Map<String, Any?>>
                     } as Map<String, Map<String, Map<String, Any?>>>
                     builder.groupProperties(groupPropsMap)
                 } catch (e: Exception) {
                     Log.e("ExperimentFlutter", "Error parsing groupProperties: ${e.message}")
                 }
             }

             builder.build()
        }
    }

    private fun experimentUserToMap(user: ExperimentUser?): Map<String, Any?> {
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
