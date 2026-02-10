package com.amplitude.experiment.flutter


import com.amplitude.experiment.flutter.ExperimentConfigData as FlutterConfig
import com.amplitude.experiment.ExperimentConfig
import com.amplitude.experiment.flutter.Variant as FlutterVariant
import com.amplitude.experiment.Variant
import com.amplitude.experiment.flutter.ExperimentUser as FlutterExperimentUser
import com.amplitude.experiment.ExperimentUser
import com.amplitude.experiment.ExperimentUserProvider
import com.amplitude.experiment.flutter.Exposure as FlutterExposure
import com.amplitude.experiment.Exposure
import com.amplitude.experiment.ExposureTrackingProvider

fun convertUser(flutterUser: FlutterExperimentUser?): ExperimentUser? {
    return flutterUser?.let {
        val builder = ExperimentUser.Builder()
         builder.deviceId(it.deviceId)
         builder.userId(it.userId)
         builder.country(it.country)
         builder.city(it.city)
         builder.region(it.region)
         builder.dma(it.dma)
         builder.language(it.language)
         builder.platform(it.platform)
         builder.version(it.version)
         builder.os(it.os)
         builder.deviceModel(it.deviceModel)
         builder.deviceBrand(it.deviceBrand)
         builder.deviceManufacturer(it.deviceManufacturer)
         builder.carrier(it.carrier)
         builder.library(it.library)

        builder.userProperties(it.userProperties)
        builder.groups(convertGroupProperties(it.groups))
        builder.groupProperties(it.groupProperties)
        builder.build()
    }
}

fun convertConfig(flutterConfig: FlutterConfig, api: CustomProviderApi): ExperimentConfig {
    val builder = ExperimentConfig.builder()
    builder.instanceName(flutterConfig.instanceName)
    builder.initialFlags(flutterConfig.initialFlags)
    builder.initialVariants(convertVariants(flutterConfig.initialVariants))
    builder.source(parseSource(flutterConfig.source))
    builder.serverZone(parseServerZone(flutterConfig.serverZone))
    builder.serverUrl(flutterConfig.serverUrl)
    builder.flagsServerUrl(flutterConfig.flagsServerUrl)
    builder.fetchTimeoutMillis(flutterConfig.fetchTimeoutMillis)
    builder.retryFetchOnFailure(flutterConfig.retryFetchOnFailure)
    builder.automaticExposureTracking(flutterConfig.automaticExposureTracking)
    builder.fetchOnStart(flutterConfig.fetchOnStart)
    builder.pollOnStart(flutterConfig.pollOnStart)
    builder.automaticFetchOnAmplitudeIdentityChange(flutterConfig.automaticFetchOnAmplitudeIdentityChange)
    if (flutterConfig.hasTrackingProvider) {
        builder.exposureTrackingProvider(generateExposureTrackingProvider(flutterConfig.instanceName, api))
    }
//    if (flutterConfig.hasUserProvider) {
//        builder.userProvider(generateUserProvider(flutterConfig.instanceName, api))
//    }
    return builder.build()
}

fun convertExposure(exposure: Exposure): FlutterExposure {
    return FlutterExposure(exposure.flagKey, exposure.variant, exposure.experimentKey, exposure.metadata)
}

fun convertVariant(flutterVariant: FlutterVariant?): Variant? {
    return flutterVariant?.let { Variant(it.value, it.payload, it.expKey, it.key, it.metadata)}
}

fun convertVariant(variant: Variant): FlutterVariant {
    return FlutterVariant(variant.key, variant.value, jsonToMap(variant.payload), variant.expKey, jsonToMap(variant.metadata))
}

private fun convertVariants(flutterVariants :Map<String, FlutterVariant>): Map<String, Variant> {
    return flutterVariants.mapValues { (_, fv) -> convertVariant(fv)!! }
}

private fun convertGroupProperties(flutterGroupProperties: Map<String, List<String>>?) :Map<String, Set<String>>? {
return flutterGroupProperties?.let { it.mapValues { (_, value) -> value.toSet() } }
}

private fun parseSource(flutterSource: Source): com.amplitude.experiment.Source {
    return when (flutterSource) {
        Source.LOCAL_STORAGE -> com.amplitude.experiment.Source.LOCAL_STORAGE
        Source.INITIAL_VARIANTS -> com.amplitude.experiment.Source.INITIAL_VARIANTS
    }
}

private fun parseServerZone(flutterServerZone: ServerZone): com.amplitude.experiment.ServerZone {
    return when (flutterServerZone) {
        ServerZone.US -> com.amplitude.experiment.ServerZone.US
        ServerZone.EU -> com.amplitude.experiment.ServerZone.EU
    }
}

private fun jsonToMap(value: Any?): Map<String, Any?>? {
    if (value == null) return null
    if (value is Map<*, *>) return value as Map<String, Any?>
    if (value is org.json.JSONObject) {
        val map = mutableMapOf<String, Any?>()
        value.keys().forEach { key ->
            map[key] = jsonToStandard(value.get(key))
        }
        return map
    }
    return null
}

private fun jsonToStandard(value: Any?): Any? {
    return when (value) {
        null, org.json.JSONObject.NULL -> null
        is org.json.JSONObject -> jsonToMap(value)
        is org.json.JSONArray -> (0 until value.length()).map { jsonToStandard(value.get(it)) }
        else -> value  // String, Int, Double, Boolean — already supported
    }
}

private fun generateExposureTrackingProvider(instanceName: String, api: CustomProviderApi): ExposureTrackingProvider {
    return object : ExposureTrackingProvider {
        override fun track(exposure: Exposure) {
            api.track(
                instanceName,convertExposure(exposure),
            ) {}
        }
    }
}

//private fun generateUserProvider(instanceName: String, api: CustomProviderApi): ExperimentUserProvider {
//    return object : ExperimentUserProvider {
//        override fun getUser(): ExperimentUser {
//            api.getUser(
//                instanceName
//            ) { response -> response.onSuccess { flutterUser ->
//                result = convertUser(flutterUser)
//            }}
//            return result
//        }
//    }
//}
