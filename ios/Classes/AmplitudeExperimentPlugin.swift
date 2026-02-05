import AmplitudeExperiment
import Flutter
import UIKit

public class AmplitudeExperimentPlugin: NSObject, FlutterPlugin, AmplitudeExperimentHostApi {
    private var instances: [String: ExperimentClient] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AmplitudeExperimentPlugin()
        AmplitudeExperimentHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }

    private func requireClient(_ instanceName: String) throws -> ExperimentClient {
        guard let client = instances[instanceName] else {
            throw PigeonError(
                code: "INSTANCE_NOT_FOUND",
                message: "Experiment instance \(instanceName) not found",
                details: nil
            )
        }
        return client
    }

    func initializeExperiment(apiKey: String, config: ExperimentConfig) throws {
        let sdkConfig = ExperimentSdkCodec.convertConfig(config)
        let client = Experiment.initialize(apiKey: apiKey, config: sdkConfig)
        instances[sdkConfig.instanceName] = client
    }

    func initializeExperimentWithAmplitude(apiKey: String, config: ExperimentConfig) throws {
        let sdkConfig = ExperimentSdkCodec.convertConfig(config)
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: apiKey, config: sdkConfig)
        instances[sdkConfig.instanceName] = client
    }

    func start(instanceName: String, user: ExperimentUser?) throws {
        let client = try requireClient(instanceName)
        let sdkUser = ExperimentSdkCodec.convertUser(user)
        client.start(sdkUser, completion: nil)
    }

    func stop(instanceName: String) throws {
        let client = try requireClient(instanceName)
        client.stop()
    }

    func fetch(instanceName: String, user: ExperimentUser?) throws {
        let client = try requireClient(instanceName)
        let sdkUser = ExperimentSdkCodec.convertUser(user)
        let semaphore = DispatchSemaphore(value: 0)
        var fetchError: Error?
        client.fetch(user: sdkUser) { _, error in
            fetchError = error
            semaphore.signal()
        }
        semaphore.wait()
        if let e = fetchError {
            throw PigeonError(
                code: "FETCH_ERROR",
                message: e.localizedDescription,
                details: nil
            )
        }
    }

    func variant(instanceName: String, flagKey: String, fallbackVariant: Variant?) throws -> Variant {
        let client = try requireClient(instanceName)
        let fallback = ExperimentSdkCodec.convertVariant(fallbackVariant)
        let sdkVariant = client.variant(flagKey, fallback: fallback)
        return ExperimentSdkCodec.convertVariant(sdkVariant)
    }

    func all(instanceName: String) throws -> [String: Variant] {
        let client = try requireClient(instanceName)
        let allVariants = client.all()
        return allVariants.mapValues { ExperimentSdkCodec.convertVariant($0) }
    }

    func clear(instanceName: String) throws {
        let client = try requireClient(instanceName)
        client.clear()
    }

    func exposure(instanceName: String, key: String) throws {
        let client = try requireClient(instanceName)
        client.exposure(key: key)
    }

    func getUser(instanceName: String) throws -> ExperimentUser {
        let client = try requireClient(instanceName)
        let sdkUser = client.getUser()
        return ExperimentSdkCodec.convertUserToPigeon(sdkUser)
    }

    func setUser(instanceName: String, user: ExperimentUser) throws {
        let client = try requireClient(instanceName)
        guard let sdkUser = ExperimentSdkCodec.convertUser(user) else {
            throw PigeonError(
                code: "INVALID_ARGUMENT",
                message: "user is required",
                details: nil
            )
        }
        client.setUser(sdkUser)
    }

    func setTracksAssignment(instanceName: String, tracksAssignment: Bool) throws {
        let client = try requireClient(instanceName)
        client.setTracksAssignment(tracksAssignment)
    }
}
