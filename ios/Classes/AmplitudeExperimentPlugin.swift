import AmplitudeExperiment
import Flutter
import UIKit

public class AmplitudeExperimentPlugin: NSObject, FlutterPlugin, AmplitudeExperimentHostApi {
    private var instances: [String: ExperimentClient] = [:]
    var providerApi: CustomProviderApi!

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AmplitudeExperimentPlugin()
        let messenger = registrar.messenger()
        AmplitudeExperimentHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
        instance.providerApi = CustomProviderApi(binaryMessenger: messenger)
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

    func initializeExperiment(apiKey: String, config: ExperimentConfigData) throws {
        let sdkConfig = ExperimentSdkCodec.convertConfig(config, api: providerApi)
        let client = Experiment.initialize(apiKey: apiKey, config: sdkConfig)
        instances[config.instanceName] = client
    }

    func initializeExperimentWithAmplitude(apiKey: String, config: ExperimentConfigData) throws {
        let sdkConfig = ExperimentSdkCodec.convertConfig(config, api: providerApi)
        let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: apiKey, config: sdkConfig)
        instances[config.instanceName] = client
    }

    func start(instanceName: String, user: ExperimentUser?, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let client = try requireClient(instanceName)
            let sdkUser = ExperimentSdkCodec.convertUser(user)
            client.start(sdkUser) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func stop(instanceName: String) throws {
        let client = try requireClient(instanceName)
        client.stop()
    }

    func fetch(instanceName: String, user: ExperimentUser?, options: FetchOptions?, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let client = try requireClient(instanceName)
            let sdkUser = ExperimentSdkCodec.convertUser(user)
            let sdkOptions = ExperimentSdkCodec.convertFetchOptions(options)
            client.fetch(user: sdkUser, options: sdkOptions) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func variant(instanceName: String, user: ExperimentUser, flagKey: String, fallbackVariant: Variant?) throws -> Variant {
        let client = try requireClient(instanceName)
        if let sdkUser = ExperimentSdkCodec.convertUser(user) {
            client.setUser(sdkUser)
        }
        let fallback = ExperimentSdkCodec.convertVariant(fallbackVariant)
        let sdkVariant = client.variant(flagKey, fallback: fallback)
        return ExperimentSdkCodec.convertVariant(sdkVariant)
    }

    func all(instanceName: String, user: ExperimentUser) throws -> [String: Variant] {
        let client = try requireClient(instanceName)
        if let sdkUser = ExperimentSdkCodec.convertUser(user) {
            client.setUser(sdkUser)
        }
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
