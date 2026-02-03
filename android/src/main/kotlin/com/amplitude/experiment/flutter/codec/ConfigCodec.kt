package com.amplitude.experiment.flutter.codec

import com.amplitude.experiment.ExperimentConfig

/**
 * Codec for parsing ExperimentConfig from method channel arguments.
 */
object ConfigCodec {
    /**
     * Parses an ExperimentConfig from a Map representation.
     * @param configMap The map containing config data
     * @return An ExperimentConfig object parsed from the map, or null if configMap is null
     */
    fun fromMap(configMap: Map<String, Any>?): ExperimentConfig? {
        return configMap?.let {
            val builder = ExperimentConfig.builder()

            (it["instanceName"] as? String)?.let { builder.instanceName(it) }
            (it["fallbackVariant"] as? Map<String, Any>)?.let { 
                builder.fallbackVariant(VariantCodec.fromMap(it))
            }
            (it["fetchOnStart"] as? Boolean)?.let { builder.fetchOnStart(it) }
            (it["fetchTimeoutMillis"] as? Int)?.let { builder.fetchTimeoutMillis(it.toLong()) }
            (it["flagsServerUrl"] as? String)?.let { builder.flagsServerUrl(it) }
            (it["flagConfigPollingIntervalMillis"] as? Int)?.let { 
                builder.flagConfigPollingIntervalMillis(it.toLong())
            }
            (it["initialFlags"] as? String)?.let { builder.initialFlags(it) }
            (it["pollOnStart"] as? Boolean)?.let { builder.pollOnStart(it) }
            (it["retryFetchOnFailure"] as? Boolean)?.let { builder.retryFetchOnFailure(it) }
            (it["serverUrl"] as? String)?.let { builder.serverUrl(it) }
            (it["serverZone"] as? String)?.let { 
                builder.serverZone(EnumParser.parseServerZone(it))
            }
            (it["source"] as? String)?.let { 
                builder.source(EnumParser.parseSource(it))
            }
            (it["automaticExposureTracking"] as? Boolean)?.let { 
                builder.automaticExposureTracking(it)
            }
            (it["automaticFetchOnAmplitudeIdentityChange"] as? Boolean)?.let { 
                builder.automaticFetchOnAmplitudeIdentityChange(it)
            }

            (it["initialVariants"] as? Map<String, Any>)?.let { map ->
                val variants = map.mapValues { (_, value) -> 
                    VariantCodec.fromMap(value as Map<String, Any>)
                }
                builder.initialVariants(variants)
            }

            builder.build()
        }
    }
}
