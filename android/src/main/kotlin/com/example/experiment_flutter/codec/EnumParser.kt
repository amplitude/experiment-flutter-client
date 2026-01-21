package com.example.experiment_flutter.codec

import com.amplitude.experiment.ServerZone
import com.amplitude.experiment.Source

/**
 * Utility object for parsing enum values from method channel arguments.
 */
object EnumParser {
    /**
     * Parses a Source enum from a string value.
     * @param source The string representation of the source
     * @return The corresponding Source enum value
     * @throws IllegalArgumentException if the source value is invalid
     */
    fun parseSource(source: String): Source {
        return when (source) {
            "localStorage" -> Source.LOCAL_STORAGE
            "initialVariants" -> Source.INITIAL_VARIANTS
            else -> throw IllegalArgumentException("Invalid source value: $source")
        }
    }

    /**
     * Parses a ServerZone enum from a string value.
     * @param serverZone The string representation of the server zone
     * @return The corresponding ServerZone enum value
     * @throws IllegalArgumentException if the serverZone value is invalid
     */
    fun parseServerZone(serverZone: String): ServerZone {
        return when (serverZone) {
            "us" -> ServerZone.US
            "eu" -> ServerZone.EU
            else -> throw IllegalArgumentException("Invalid serverZone value: $serverZone")
        }
    }
}
