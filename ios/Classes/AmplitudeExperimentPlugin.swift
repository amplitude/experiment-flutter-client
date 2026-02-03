import AmplitudeExperiment
import Flutter
import UIKit

public class AmplitudeExperimentPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var instances: [String: ExperimentClient] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "experiment_flutter",
            binaryMessenger: registrar.messenger()
        )
        let instance = AmplitudeExperimentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let args = call.arguments as? [String: Any]

        if call.method == "init" {
            guard let apiKey = args?["apiKey"] as? String else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "apiKey is required",
                        details: nil
                    )
                )
                return
            }

            do {
                guard let config = try ConfigCodec.fromMap(args?["config"] as? [String: Any]) else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENT",
                            message: "config is required",
                            details: nil
                        )
                    )
                    return
                }
                
                let client = Experiment.initialize(apiKey: apiKey, config: config)
                instances[config.instanceName] = client
                result("experiment initialized")
            } catch {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "Invalid config: \(error.localizedDescription)",
                        details: nil
                    )
                )
            }
            return
        } else if call.method == "initWithAmplitude" {
            guard let apiKey = args?["apiKey"] as? String else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "apiKey is required",
                        details: nil
                    )
                )
                return
            }

            do {
                guard let config = try ConfigCodec.fromMap(args?["config"] as? [String: Any]) else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENT",
                            message: "config is required",
                            details: nil
                        )
                    )
                    return
                }
                
                let client = Experiment.initializeWithAmplitudeAnalytics(
                    apiKey: apiKey,
                    config: config
                )
                instances[config.instanceName] = client
                result("experiment initialized")
            } catch {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "Invalid config: \(error.localizedDescription)",
                        details: nil
                    )
                )
            }
            return
        }

        let instanceName =
            args?["instanceName"] as? String ?? "$default_instance"
        guard let client = instances[instanceName] else {
            result(
                FlutterError(
                    code: "INSTANCE_NOT_FOUND",
                    message: "Experiment instance \(instanceName) not found",
                    details: nil
                )
            )
            return
        }

        switch call.method {
        case "all":
            let allVariants = client.all()
            let variantMap = allVariants.mapValues { VariantCodec.toMap($0) }
            result(variantMap)

        case "fetch":
            let user = UserCodec.fromMap(args?["user"] as? [String: Any])
            client.fetch(user: user) { (_, error) in
                if let error = error {
                    result(
                        FlutterError(
                            code: "FETCH_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        )
                    )
                } else {
                    result("Instance [\(instanceName)] has fetched data")
                }
            }

        case "start":
            let user = UserCodec.fromMap(args?["user"] as? [String: Any])
            client.start(user, completion: nil)
            result("Instance [\(instanceName)] has started")

        case "stop":
            client.stop()
            result("Instance [\(instanceName)] has stopped")

        case "clear":
            client.clear()
            result("Instance [\(instanceName)] has been cleared")

        case "variant":
            guard let flagKey = args?["flagKey"] as? String else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "flagKey is required",
                        details: nil
                    )
                )
                return
            }
            let fallbackVariant = (args?["fallbackVariant"] as? [String: Any])
                .map { VariantCodec.fromMap($0) }
            let variant = client.variant(flagKey, fallback: fallbackVariant)
            result(VariantCodec.toMap(variant))

        case "setUser":
            guard let user = UserCodec.fromMap(args?["user"] as? [String: Any]) else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "user is required",
                        details: nil
                    )
                )
                return
            }
            client.setUser(user)
            result("User set")

        case "getUser":
            let user = client.getUser()
            result(UserCodec.toMap(user))

        case "exposure":
            guard let key = args?["key"] as? String else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "key is required",
                        details: nil
                    )
                )
                return
            }
            client.exposure(key: key)
            result("Exposure for \(key) was tracked")

        default:
            result(FlutterMethodNotImplemented)
        }
    }

}
