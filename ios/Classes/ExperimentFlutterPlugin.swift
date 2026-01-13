import Flutter
import UIKit
import AmplitudeExperiment

public class ExperimentFlutterPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  private var instances: [String: ExperimentClient] = [:]
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "experiment_flutter", binaryMessenger: registrar.messenger())
    let instance = ExperimentFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
      result("iOS \(UIDevice.current.systemVersion)")
      return
    }
    
    let args = call.arguments as? [String: Any]
    
    if call.method == "init" {
      guard let apiKey = args?["apiKey"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "apiKey is required", details: nil))
        return
      }
      
      let config = getConfiguration(from: args)
      let client = Experiment.initialize(apiKey: apiKey, config: config)
      instances[config.instanceName] = client
      result("experiment initialized")
      return
    } else if call.method == "initWithAmplitude" {
      guard let apiKey = args?["apiKey"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "apiKey is required", details: nil))
        return
      }
      
      let config = getConfiguration(from: args)
      let client = Experiment.initializeWithAmplitudeAnalytics(apiKey: apiKey, config: config)
      instances[config.instanceName] = client
      result("experiment initialized")
      return
    }
    
    let instanceName = args?["instanceName"] as? String ?? "$default_instance"
    guard let client = instances[instanceName] else {
      result(FlutterError(code: "INSTANCE_NOT_FOUND", message: "Experiment instance \(instanceName) not found", details: nil))
      return
    }
    
    switch call.method {
    case "all":
      let allVariants = client.all()
      let variantMap = allVariants.mapValues { variantToMap($0) }
      result(variantMap)
      
    case "fetch":
      let user = getExperimentUser(from: args)
      client.fetch(user: user) { (_, error) in
        if let error = error {
          result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
        } else {
          result("Instance [\(instanceName)] has fetched data")
        }
      }
      
    case "start":
      let user = getExperimentUser(from: args)
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
        result(FlutterError(code: "INVALID_ARGUMENT", message: "flagKey is required", details: nil))
        return
      }
      let fallbackVariant = (args?["fallbackVariant"] as? [String: Any]).map { parseVariant(from: $0) }
      let variant = client.variant(flagKey, fallback: fallbackVariant)
      result(variantToMap(variant))
      
    case "setUser":
      guard let user = getExperimentUser(from: args) else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "user is required", details: nil))
        return
      }
      client.setUser(user)
      result("User set")
      
    case "getUser":
      let user = client.getUser()
      result(experimentUserToMap(user))
      
    case "exposure":
      guard let key = args?["key"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "key is required", details: nil))
        return
      }
      client.exposure(key: key)
      result("Exposure for \(key) was tracked")
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func getConfiguration(from args: [String: Any]?) -> ExperimentConfig {
    let builder = ExperimentConfigBuilder()
    
    if let instanceName = args?["instanceName"] as? String {
      builder.instanceName(instanceName)
    }
    
    if let fallbackVariantDict = args?["fallbackVariant"] as? [String: Any] {
      builder.fallbackVariant(parseVariant(from: fallbackVariantDict))
    }
    
    if let fetchOnStart = args?["fetchOnStart"] as? Bool {
      builder.fetchOnStart(fetchOnStart)
    }
    
    if let fetchTimeoutMillis = args?["fetchTimeoutMillis"] as? Int {
      builder.fetchTimeoutMillis(fetchTimeoutMillis)
    }
    
    if let flagsServerUrl = args?["flagsServerUrl"] as? String {
      builder.flagsServerUrl(flagsServerUrl)
    }
    
    if let flagConfigPollingIntervalMillis = args?["flagConfigPollingIntervalMillis"] as? Int {
      builder.flagConfigPollingIntervalMillis(flagConfigPollingIntervalMillis)
    }
    
    if let initialFlags = args?["initialFlags"] as? String {
      builder.initialFlags(initialFlags)
    }
    
    if let pollOnStart = args?["pollOnStart"] as? Bool {
      builder.pollOnStart(pollOnStart)
    }
    
    if let serverUrl = args?["serverUrl"] as? String {
      builder.serverUrl(serverUrl)
    }
    
    if let serverZoneString = args?["serverZone"] as? String {
      builder.serverZone(parseServerZone(from: serverZoneString))
    }
    
    if let sourceString = args?["source"] as? String {
      builder.source(parseSource(from: sourceString))
    }
    
    if let automaticExposureTracking = args?["automaticExposureTracking"] as? Bool {
      builder.automaticExposureTracking(automaticExposureTracking)
    }
    
    if let automaticFetchOnAmplitudeIdentityChange = args?["automaticFetchOnAmplitudeIdentityChange"] as? Bool {
      builder.automaticFetchOnAmplitudeIdentityChange(automaticFetchOnAmplitudeIdentityChange)
    }
      
    if let initialVariantsDict = args?["initialVariants"] as? [String: Any] {
      let initialVariants = initialVariantsDict.mapValues { parseVariant(from: $0 as! [String: Any]) }
      builder.initialVariants(initialVariants)
    }
    
    return builder.build()
  }
  
    private func parseVariant(from args: [String: Any]) -> Variant {
        let _metadata: [String: Any]? = (args["metadata"] as? String)
            .flatMap { $0.data(using: .utf8) }
            .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        
        return Variant(
            args["value"] as? String,
            payload: args["payload"],
            expKey: args["expKey"] as? String,
            key: args["key"] as? String,
            metadata: _metadata,
      )
    }
  
  private func parseSource(from source: String) -> Source {
    switch source {
    case "localStorage":
      return .LocalStorage
    case "initialVariants":
      return .InitialVariants
    default:
      return .LocalStorage
    }
  }
  
  private func parseServerZone(from serverZone: String) -> ServerZone {
    switch serverZone {
    case "us":
      return .US
    case "eu":
      return .EU
    default:
      return .US
    }
  }
  
  private func variantToMap(_ variant: Variant?) -> [String: Any?] {
    guard let variant = variant else {
      return [:]
    }
    
    var map: [String: Any?] = [:]
    if let key = variant.key {
      map["key"] = key
    }
    if let value = variant.value {
      map["value"] = value
    }
    if let payload = variant.payload {
      map["payload"] = String(describing: payload)
    }
    if let expKey = variant.expKey {
      map["expKey"] = expKey
    }
    if let metadata = variant.metadata,
       let metadataData = try? JSONSerialization.data(withJSONObject: metadata),
       let metadataString = String(data: metadataData, encoding: .utf8) {
      map["metadata"] = metadataString
    }
    
    return map
  }
  
  private func getExperimentUser(from args: [String: Any]?) -> ExperimentUser? {
    guard let userArgs = args?["user"] as? [String: Any] else {
      return nil
    }
    
    let builder = ExperimentUserBuilder()
    
    if let deviceId = userArgs["deviceId"] as? String {
      builder.deviceId(deviceId)
    }
    if let userId = userArgs["userId"] as? String {
      builder.userId(userId)
    }
    if let country = userArgs["country"] as? String {
      builder.country(country)
    }
    if let city = userArgs["city"] as? String {
      builder.city(city)
    }
    if let region = userArgs["region"] as? String {
      builder.region(region)
    }
    if let dma = userArgs["dma"] as? String {
      builder.dma(dma)
    }
    if let language = userArgs["language"] as? String {
      builder.language(language)
    }
    if let platform = userArgs["platform"] as? String {
      builder.platform(platform)
    }
    if let version = userArgs["version"] as? String {
      builder.version(version)
    }
    if let os = userArgs["os"] as? String {
      builder.os(os)
    }
    if let deviceModel = userArgs["deviceModel"] as? String {
      builder.deviceModel(deviceModel)
    }
    if let deviceManufacturer = userArgs["deviceManufacturer"] as? String {
      builder.deviceManufacturer(deviceManufacturer)
    }
    if let carrier = userArgs["carrier"] as? String {
      builder.carrier(carrier)
    }
    if let library = userArgs["library"] as? String {
      builder.library(library)
    }
    
    // Decode userProperties from JSON string
    if let userPropertiesString = userArgs["userProperties"] as? String,
       let userPropertiesData = userPropertiesString.data(using: .utf8),
       let userProperties = try? JSONSerialization.jsonObject(with: userPropertiesData) as? [String: Any] {
      builder.userProperties(userProperties)
    }
    
    // Decode groups from JSON string (Map<String, List<String>>)
    if let groupsString = userArgs["groups"] as? String,
       let groupsData = groupsString.data(using: .utf8),
       let groupsDict = try? JSONSerialization.jsonObject(with: groupsData) as? [String: Any] {
      var groups: [String: [String]] = [:]
      for (key, value) in groupsDict {
        if let list = value as? [String] {
          groups[key] = list
        }
      }
      builder.groups(groups)
    }
    
    // Decode groupProperties from JSON string (Map<String, Map<String, Map<String, Any?>>>)
    if let groupPropertiesString = userArgs["groupProperties"] as? String,
       let groupPropertiesData = groupPropertiesString.data(using: .utf8),
       let groupPropertiesDict = try? JSONSerialization.jsonObject(with: groupPropertiesData) as? [String: Any] {
      var groupProperties: [String: [String: [String: Any?]]] = [:]
      for (groupKey, groupValue) in groupPropertiesDict {
        if let groupMap = groupValue as? [String: Any] {
          var innerMap: [String: [String: Any?]] = [:]
          for (propertyKey, propertyValue) in groupMap {
            if let propertyMap = propertyValue as? [String: Any] {
              var finalMap: [String: Any?] = [:]
              for (key, value) in propertyMap {
                finalMap[key] = value
              }
              innerMap[propertyKey] = finalMap
            }
          }
          groupProperties[groupKey] = innerMap
        }
      }
      builder.groupProperties(groupProperties)
    }
    
    return builder.build()
  }
  
  private func experimentUserToMap(_ user: ExperimentUser?) -> [String: Any?] {
    guard let user = user else {
      return [:]
    }
    
    var map: [String: Any?] = [:]
    
    if let deviceId = user.deviceId {
      map["deviceId"] = deviceId
    }
    if let userId = user.userId {
      map["userId"] = userId
    }
    if let country = user.country {
      map["country"] = country
    }
    if let city = user.city {
      map["city"] = city
    }
    if let region = user.region {
      map["region"] = region
    }
    if let dma = user.dma {
      map["dma"] = dma
    }
    if let language = user.language {
      map["language"] = language
    }
    if let platform = user.platform {
      map["platform"] = platform
    }
    if let version = user.version {
      map["version"] = version
    }
    if let os = user.os {
      map["os"] = os
    }
    if let deviceModel = user.deviceModel {
      map["deviceModel"] = deviceModel
    }
    if let deviceManufacturer = user.deviceManufacturer {
      map["deviceManufacturer"] = deviceManufacturer
    }
    if let carrier = user.carrier {
      map["carrier"] = carrier
    }
    if let library = user.library {
      map["library"] = library
    }
    
    // Encode userProperties to JSON string
    if let userProperties = user.userProperties,
       let userPropertiesData = try? JSONSerialization.data(withJSONObject: userProperties),
       let userPropertiesString = String(data: userPropertiesData, encoding: .utf8) {
      map["userProperties"] = userPropertiesString
    }
    
    // Encode groups to JSON string (Map<String, List<String>>)
    if let groups = user.groups {
      var groupsAsList: [String: [String]] = [:]
      for (key, value) in groups {
        groupsAsList[key] = Array(value)
      }
      if let groupsData = try? JSONSerialization.data(withJSONObject: groupsAsList),
         let groupsString = String(data: groupsData, encoding: .utf8) {
        map["groups"] = groupsString
      }
    }
    
    // Encode groupProperties to JSON string (Map<String, Map<String, Map<String, Any?>>>)
    if let groupProperties = user.groupProperties,
       let groupPropertiesData = try? JSONSerialization.data(withJSONObject: groupProperties),
       let groupPropertiesString = String(data: groupPropertiesData, encoding: .utf8) {
      map["groupProperties"] = groupPropertiesString
    }
    
    return map
  }
}
