package com.amplitude.experiment.flutter


import com.amplitude.experiment.flutter.ExperimentConfig as FlutterConfig
import com.amplitude.experiment.ExperimentConfig
import com.amplitude.experiment.flutter.Variant as FlutterVariant
import com.amplitude.experiment.Variant
import com.amplitude.experiment.flutter.ExperimentUser as FlutterExperimentUser
import com.amplitude.experiment.ExperimentUser
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

fun convertConfig(flutterConfig: FlutterConfig): ExperimentConfig {
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
    return builder.build()
}

fun convertVariant(flutterVariant: FlutterVariant?): Variant? {
    return flutterVariant?.let { Variant(it.value, it.payload, it.expKey, it.key, it.metadata)}
}

fun convertVariant(variant: Variant): FlutterVariant {
    return FlutterVariant(variant.key, variant.value, variant.payload, variant.expKey, variant.metadata)
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
