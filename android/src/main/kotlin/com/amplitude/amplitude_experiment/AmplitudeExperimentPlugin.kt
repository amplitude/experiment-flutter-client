package com.amplitude.amplitude_experiment

import android.app.Application
import android.util.Log
import androidx.annotation.NonNull
import com.amplitude.skylab.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import org.json.JSONObject

class AmplitudeExperimentPlugin: FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var application: Application
  private var client: SkylabClient? = null

  // Runs call incoming method calls
  private val io = CoroutineScope(Job() + Dispatchers.IO)

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    application = flutterPluginBinding.applicationContext as Application
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "amplitude_experiment")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "initialize" -> io.launchResult(result) {
        val apiKey: String = call.argumentNotNull("apiKey")
        init(apiKey)
      }
      "start" -> io.launchResult(result) {
        start(call.parseSkylabUser())
      }
      "getVariant" -> io.launchResult(result) {
        val flagKey: String = call.argumentNotNull("flagKey")
        getVariant(flagKey)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // Initialization

  private fun init(apiKey: String) {
    Log.w("Experiment", "init")
    client = Skylab.init(application, apiKey, SkylabConfig.builder().build())
  }

  // Start

  private fun MethodCall.parseSkylabUser(): SkylabUser {
    // TODO parse all user fields out out of the call arguments
    return SkylabUser.builder()
      .setUserId(this.argument("userId"))
      .setDeviceId(this.argument("deviceId"))
      .build()
  }

  private fun start(user: SkylabUser) {
    Log.w("Experiment", "start: $client")
    client?.start(user)?.get()
  }

  // Get variant

  private fun getVariant(flagKey: String): Map<String, Any?>? {
    Log.w("Experiment", "getVariant")
    val variant = client?.getVariant(flagKey)
    val value = variant?.value
    return if (value == null) {
      null
    } else {

      // TODO handle json array
      val payload = if (variant.payload is JSONObject) {
        (variant.payload as JSONObject).toMap()
      } else {
        variant.payload
      }
      mapOf("value" to value, "payload" to payload)
    }
  }
}

// Helpers

private fun <T> CoroutineScope.launchResult(result: Result, block: () -> T) {
  launch {
    try {
      val out = block.invoke()
      launch(Dispatchers.Main) {
        if (out is Unit) {
          result.success(null)
        } else {
          result.success(out)
        }
      }
    } catch (e: Exception) {
      launch(Dispatchers.Main) {
        result.error(e::class.simpleName, e.message, e)
      }
    }
  }
}

private fun <T : Any> MethodCall.argumentNotNull(key: String): T {
  return checkNotNull(argument(key)) { "method argument \'$key\' must not be null" }
}

private fun JSONObject.toMap(): Map<String, Any?> {
  val map = mutableMapOf<String, Any?>()
  for (key in keys()) {
    map[key] = this[key]
  }
  return map
}