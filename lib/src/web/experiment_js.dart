import 'dart:js_interop';

@JS('Experiment')
@staticInterop
class Experiment {
  external factory Experiment._();

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
}
