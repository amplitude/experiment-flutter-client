import 'package:amplitude_experiment/src/generated/amplitude_experiment_api.g.dart'
    as pigeon;
import 'package:amplitude_experiment/src/models/variant.dart';
import 'package:amplitude_experiment/src/models/experiment_user.dart';
import 'package:amplitude_experiment/src/models/exposure.dart';
import 'package:amplitude_experiment/src/models/fetch_options.dart';
import 'package:amplitude_experiment/src/models/enums.dart';

// ── Variant ──────────────────────────────────────────

extension VariantToPigeon on Variant {
  pigeon.Variant toPigeon() => pigeon.Variant(
        key: key,
        value: value,
        payload: payload,
        expKey: expKey,
        metadata: metadata,
      );
}

Variant variantFromPigeon(pigeon.Variant p) => Variant(
      key: p.key,
      value: p.value,
      payload: p.payload,
      expKey: p.expKey,
      metadata: p.metadata,
    );

// ── ExperimentUser ───────────────────────────────────

extension ExperimentUserToPigeon on ExperimentUser {
  pigeon.ExperimentUser toPigeon() => pigeon.ExperimentUser(
        deviceId: deviceId,
        userId: userId,
        country: country,
        city: city,
        region: region,
        dma: dma,
        language: language,
        platform: platform,
        version: version,
        os: os,
        deviceModel: deviceModel,
        deviceBrand: deviceBrand,
        deviceManufacturer: deviceManufacturer,
        carrier: carrier,
        library: library,
        ipAddress: ipAddress,
        userProperties: userProperties,
        groups: groups,
        groupProperties: groupProperties,
      );
}

ExperimentUser experimentUserFromPigeon(pigeon.ExperimentUser p) =>
    ExperimentUser(
      deviceId: p.deviceId,
      userId: p.userId,
      country: p.country,
      city: p.city,
      region: p.region,
      dma: p.dma,
      language: p.language,
      platform: p.platform,
      version: p.version,
      os: p.os,
      deviceModel: p.deviceModel,
      deviceBrand: p.deviceBrand,
      deviceManufacturer: p.deviceManufacturer,
      carrier: p.carrier,
      library: p.library,
      ipAddress: p.ipAddress,
      userProperties: p.userProperties,
      groups: p.groups,
      groupProperties: p.groupProperties,
    );

// ── Exposure ─────────────────────────────────────────

Exposure exposureFromPigeon(pigeon.Exposure p) => Exposure(
      flagKey: p.flagKey,
      variant: p.variant,
      experimentKey: p.experimentKey,
      metadata: p.metadata,
      time: p.time,
    );

// ── FetchOptions ─────────────────────────────────────

extension FetchOptionsToPigeon on FetchOptions {
  pigeon.FetchOptions toPigeon() => pigeon.FetchOptions(flagKeys: flagKeys);
}

// ── Enums ────────────────────────────────────────────

pigeon.LogLevel logLevelToPigeon(LogLevel l) => pigeon.LogLevel.values[l.index];

pigeon.Source sourceToPigeon(Source s) => pigeon.Source.values[s.index];

pigeon.ServerZone serverZoneToPigeon(ServerZone z) =>
    pigeon.ServerZone.values[z.index];
