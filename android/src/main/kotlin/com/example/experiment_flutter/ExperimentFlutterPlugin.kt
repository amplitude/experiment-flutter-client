package com.example.experiment_flutter

import android.app.Application
import android.content.Context
import com.amplitude.experiment.Experiment
import com.amplitude.experiment.ExperimentClient
import com.example.experiment_flutter.codec.ConfigCodec
import com.example.experiment_flutter.codec.UserCodec
import com.example.experiment_flutter.codec.VariantCodec
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

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
            val config = ConfigCodec.fromMap(call.argument<Map<String, Any>>("config"))
                ?: throw IllegalArgumentException("config is required")
            val client = Experiment.initialize(ctxt as Application, call.argument<String>("apiKey")!!, config)
            instances += mapOf(config.instanceName to client)
            result.success("experiment initialized")
            return
        } else if (call.method == "initWithAmplitude") {
            val config = ConfigCodec.fromMap(call.argument<Map<String, Any>>("config"))
                ?: throw IllegalArgumentException("config is required")
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
                val variantMap = allVariants.mapValues { VariantCodec.toMap(it.value) }
                result.success(variantMap)
            }

            "fetch" -> {
                val user = try {
                    UserCodec.fromMap(call.argument<Map<String, Any>>("user"))
                } catch (e: Exception) {
                    result.error("Invalid argument exception",
                        "Invalid user definition",
                        e)
                    return
                }
                client.fetch(user).get()
                result.success("Instance [$instanceName] has fetched data")
            }

            "start" -> {
                val user = try {
                    UserCodec.fromMap(call.argument<Map<String, Any>>("user"))
                } catch (e: Exception) {
                    result.error("Invalid argument exception",
                        "Invalid user definition",
                        e)
                    return
                }
                client.start(user)
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
                result.success(VariantCodec.toMap(client.variant(flagKey)))
            }

            "variant" -> {
                val flagKey = call.argument<String>("flagKey")
                    ?: throw IllegalArgumentException("flagKey is required")
                val fallbackVariant = call.argument<Map<String, Any>>("fallbackVariant")?.let { 
                    VariantCodec.fromMap(it)
                }
                result.success(VariantCodec.toMap(client.variant(flagKey, fallbackVariant)))
            }

            "setUser" -> {
                val user = try {
                    UserCodec.fromMap(call.argument<Map<String, Any>>("user"))
                } catch (e: Exception) {
                    result.error("Invalid argument exception",
                        "Invalid user definition",
                        e)
                    return
                }
                if (user == null) {
                    result.error("Invalid argument exception",
                        "Invalid user definition",
                        null)
                    return
                }
                client.setUser(user)
                result.success("User set")
            }

            "getUser" -> {
                result.success(UserCodec.toMap(client.getUser()))
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
}
