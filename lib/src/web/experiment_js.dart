import 'dart:js_interop';

@JS('Experiment')
extension type Experiment._(JSObject _) implements JSObject {
  external static ExperimentClient initialize(String apiKey, JSObject? config);
  external static ExperimentClient initializeWithAmplitudeAnalytics(
    String apiKey,
    JSObject? config,
  );
}

// Extension type for the Experiment Client instance
extension type ExperimentClient(JSObject _) implements JSObject {
  // start(user?: ExperimentUser): Promise<void>
  external JSPromise start([JSObject? user]);

  // stop(): void
  external void stop();

  // fetch(user?: ExperimentUser, options?: FetchOptions): Promise<Client>
  external JSPromise fetch([JSObject? user, JSObject? options]);

  // variant(key: string, fallback?: string | Variant): Variant
  external JSObject variant(String key, [JSAny? fallback]);

  // all(): Variants (returns Map<string, Variant>)
  external JSObject all();

  // clear(): void
  external void clear();

  // exposure(key: string): void
  external void exposure(String key);

  // getUser(): ExperimentUser
  external JSObject getUser();

  // setUser(user: ExperimentUser): void
  external void setUser(JSObject user);

  // setTracksAssignment(tracksAssignment: boolean): void
  external void setTracksAssignment(bool tracksAssignment);
}

@JS('Object.keys')
external JSArray<JSString> objectKeys(JSObject o);

extension type JSExposureTrackingProvider._(JSObject _) implements JSObject {
  external factory JSExposureTrackingProvider({JSFunction track});
}

extension type JSUserProvider._(JSObject _) implements JSObject {
  external factory JSUserProvider({JSFunction getUser});
}

extension type JSExperimentConfig._(JSObject _) implements JSObject {
  external set exposureTrackingProvider(JSExposureTrackingProvider? value);
  external set userProvider(JSUserProvider? value);
}
