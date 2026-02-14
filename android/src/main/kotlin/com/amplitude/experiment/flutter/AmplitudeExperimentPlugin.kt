package com.amplitude.experiment.flutter

import android.app.Application
import android.content.Context
import com.amplitude.experiment.Experiment
import com.amplitude.experiment.ExperimentClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.concurrent.ConcurrentHashMap

class AmplitudeExperimentPlugin :
    FlutterPlugin,
    AmplitudeExperimentHostApi {
    private lateinit var ctxt: Context
    private var instances:  Map<String, ExperimentClient> = ConcurrentHashMap()
    private lateinit var providerApi: CustomProviderApi

    private val executor = java.util.concurrent.Executors.newCachedThreadPool()
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        ctxt = flutterPluginBinding.applicationContext
        AmplitudeExperimentHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
        providerApi = CustomProviderApi(flutterPluginBinding.binaryMessenger)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AmplitudeExperimentHostApi.setUp(flutterPluginBinding.binaryMessenger, null)
        executor.shutdown()
    }

    override fun init(
        apiKey: String,
        config: ExperimentConfigData
    ) {
        if (instances.contains(config.instanceName)) {
            return
        }

        val client = Experiment.initialize(ctxt as Application, apiKey, convertConfig(config, providerApi))
        instances += mapOf(config.instanceName to client)
    }

    override fun initWithAmplitude(
        apiKey: String,
        config: ExperimentConfigData
    ) {
        if (instances.contains(config.instanceName)) {
            return
        }

        val client = Experiment.initializeWithAmplitudeAnalytics(ctxt as Application, apiKey, convertConfig(config, providerApi))
        instances += mapOf(config.instanceName to client)
    }

    override fun start(
        instanceName: String,
        user: ExperimentUser?,
        callback: (Result<Unit>) -> Unit
    ) {
        executor.execute {
            try {
                getClient(instanceName).start(convertUser(user))
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun stop(instanceName: String) {
        getClient(instanceName).stop()
    }

    override fun fetch(
        instanceName: String,
        user: ExperimentUser?,
        options: FetchOptions?,
        callback: (Result<Unit>) -> Unit
    ) {
        executor.execute {
            try {
                getClient(instanceName).fetch(convertUser(user), convertFetchOptions(options)).get()
                callback(Result.success(Unit))
            } catch (e: Exception) {
               callback(Result.failure(e))
            }
        }
    }

    override fun variant(
        instanceName: String,
        user: ExperimentUser?,
        flagKey: String,
        fallbackVariant: Variant?
    ): Variant {
        val client = getClient(instanceName)
        convertUser(user)?.let { client.setUser(it) }
        return variantToPigeon(client.variant(flagKey, variantFromPigeon(fallbackVariant)))
    }

    override fun all(instanceName: String, user: ExperimentUser?): Map<String, Variant> {
        val client = getClient(instanceName)
        convertUser(user)?.let { client.setUser(it) }
        return variantsToPigeon(client.all())
    }

    override fun clear(instanceName: String) {
        getClient(instanceName).clear()
    }

    override fun exposure(instanceName: String, key: String) {
        getClient(instanceName).exposure(key)
    }

    override fun getUser(instanceName: String): ExperimentUser {
        val sdkUser = requireNotNull(getClient(instanceName).getUser()) { "native getUser() returned null for instance $instanceName" }
        return convertUser(sdkUser)
    }

    override fun setUser(
        instanceName: String,
        user: ExperimentUser
    ) {
        val sdkUser = requireNotNull(convertUser(user)) { "user conversion must not return null for non-null input" }
        getClient(instanceName).setUser(sdkUser)
    }

    override fun setTracksAssignment(
        instanceName: String,
        tracksAssignment: Boolean
    ) {
        getClient(instanceName).setTracksAssignment(tracksAssignment)
    }

    private fun getClient(instanceName: String): ExperimentClient {
        return instances[instanceName] ?: throw IllegalArgumentException("Instance $instanceName has not been initialized")
    }
}
