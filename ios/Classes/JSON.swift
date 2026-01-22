import Foundation

/**
 * Helper extensions for JSON serialization/deserialization.
 * Similar to Android's JSON.kt but using Swift's JSONSerialization.
 */
extension Dictionary where Key == String {
    /**
     * Converts a Dictionary to a JSON string.
     * @return A JSON string representation, or nil if serialization fails
     */
    func toJSONString() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension Array {
    /**
     * Converts an Array to a JSON string.
     * @return A JSON string representation, or nil if serialization fails
     */
    func toJSONString() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension String {
    /**
     * Parses a JSON string to a Dictionary.
     * @return A Dictionary representation, or nil if parsing fails
     */
    func toDictionary() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }

    /**
     * Parses a JSON string to an Array.
     * @return An Array representation, or nil if parsing fails
     */
    func toArray() -> [Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
    }
}
