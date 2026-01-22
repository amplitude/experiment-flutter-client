import AmplitudeExperiment
import Foundation

/**
 * Utility object for parsing enum values from method channel arguments.
 */
enum EnumParser {
    /**
     * Parses a Source enum from a string value.
     * @param source The string representation of the source
     * @return The corresponding Source enum value
     * @throws IllegalArgumentException if the source value is invalid
     */
    static func parseSource(_ source: String) throws -> Source {
        switch source {
        case "localStorage":
            return .LocalStorage
        case "initialVariants":
            return .InitialVariants
        default:
            throw NSError(
                domain: "ExperimentFlutter",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid source value: \(source)"]
            )
        }
    }

    /**
     * Parses a ServerZone enum from a string value.
     * @param serverZone The string representation of the server zone
     * @return The corresponding ServerZone enum value
     * @throws IllegalArgumentException if the serverZone value is invalid
     */
    static func parseServerZone(_ serverZone: String) throws -> ServerZone {
        switch serverZone {
        case "us":
            return .US
        case "eu":
            return .EU
        default:
            throw NSError(
                domain: "ExperimentFlutter",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid serverZone value: \(serverZone)"]
            )
        }
    }
}
