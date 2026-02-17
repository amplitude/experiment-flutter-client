<p align="center">
  <a href="https://amplitude.com" target="_blank" align="center">
    <img src="https://static.amplitude.com/lightning/46c85bfd91905de8047f1ee65c7c93d6fa9ee6ea/static/media/amplitude-logo-with-text.4fb9e463.svg" width="280">
  </a>
  <br />
</p>

# Amplitude Experiment Flutter SDK
> **Warning**
> This SDK is currently in alpha. APIs may change and there will likely be breaking changes leading up to the stable release.

This is Amplitude's official Experiment Flutter SDK for evaluating feature flags and running experiments across iOS, Android, and Web.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  amplitude_experiment: ^0.1.0-alpha.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize

**With Amplitude Analytics** — use this when your app already uses the [Amplitude Analytics Flutter SDK](https://pub.dev/packages/amplitude_flutter). The Experiment SDK automatically shares user identity and tracks exposures through Analytics.

```dart
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_experiment/amplitude_experiment.dart';

final amplitude = Amplitude(Configuration(apiKey: 'AMPLITUDE_API_KEY'));
await amplitude.isBuilt;

final experiment = await Experiment.initializeWithAmplitude(
  'DEPLOYMENT_KEY',
  ExperimentConfig(),
);
```

> The Experiment `instanceName` must match the Amplitude Analytics instance name (case-sensitive) for automatic identity sharing to work. Both SDKs default to `$default_instance`, so no action is needed for single-instance usage.

**Standalone** — use this when your app does not use Amplitude Analytics. You provide user context explicitly and wire up your own exposure tracking.

```dart
import 'package:amplitude_experiment/amplitude_experiment.dart';

final experiment = await Experiment.initialize(
  'DEPLOYMENT_KEY',
  ExperimentConfig(),
);
```

### 2. Fetch variants

```dart
await experiment.fetch();
```

When using the standalone client, pass an `ExperimentUser` with identity and targeting properties:

```dart
final user = ExperimentUser(
  userId: 'user@company.com',
  deviceId: 'abcdefg',
  userProperties: {'premium': true},
);
await experiment.fetch(user);
```

### 3. Access a variant

```dart
final variant = await experiment.variant('flag-key');
if (variant.value == 'on') {
  // Flag is enabled
}
```

### 4. Track exposures

When using `initializeWithAmplitude`, exposure events are tracked automatically on `variant()` calls. To disable this, set `automaticExposureTracking: false` in the config and call `exposure()` manually:

```dart
await experiment.exposure('flag-key');
```

For standalone clients, implement `ExposureTrackingProvider` to route exposure events to your analytics:

```dart
class MyExposureTracker implements ExposureTrackingProvider {
  @override
  void track(Exposure exposure) {
    // Forward to your analytics provider
    analytics.track('\$exposure', {
      'flag_key': exposure.flagKey,
      'variant': exposure.variant,
    });
  }
}

final experiment = await Experiment.initialize(
  'DEPLOYMENT_KEY',
  ExperimentConfig(
    exposureTrackingProvider: MyExposureTracker(),
  ),
);
```

## Configuration

All config fields have sensible defaults. Common options:

| Option | Default | Description |
|--------|---------|-------------|
| `instanceName` | `$default_instance` | Name for this client instance |
| `fallbackVariant` | `null` | Variant returned when a flag has no value |
| `source` | `Source.localStorage` | Where to read flag data from |
| `serverZone` | `ServerZone.us` | Data center region (`us` or `eu`) |
| `automaticExposureTracking` | `true` | Track exposures on `variant()` calls |
| `fetchOnStart` | `true` | Fetch flags when `start()` is called |

See `ExperimentConfig` API docs for the full list.

## Learn More

Visit the [Amplitude Experiment documentation](https://amplitude.com/docs/experiment) for guides on creating flags, targeting users, and running experiments.
