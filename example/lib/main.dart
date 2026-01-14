import 'dart:convert';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:experiment_flutter/experiment.dart';
import 'package:experiment_flutter/experiment_client.dart';
import 'package:experiment_flutter/experiment_config.dart';
import 'package:experiment_flutter/models/variant.dart';
import 'package:experiment_flutter/models/experiment_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _test = 'Boo =(';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Amplitude amplitude = Amplitude(Configuration(apiKey: 'YOUR_API_KEY'));
    await amplitude.isBuilt;

    await amplitude.setUserId('exp.flutter@test.com');
    // await amplitude.setDeviceId('1234567');

    ExperimentClient experiment = Experiment.initializeWithAmplitude(
      'YOUR_DEPLOYMENT_KEY',
      ExperimentConfig(),
    );

    /**
     
     */

    await experiment.isBuilt;
    await experiment.fetch();
    Variant? variant = await experiment.variant('VARIANT_KEY');
    // print(variant?.metadata?['evaluationId'].toString());
    ExperimentUser userFromExperiment = await experiment.getUser();
    // print(userFromExperiment.groups?['test']?.toString());
    // print(userFromExperiment.groupProperties.toString());
    // print(
    //   userFromExperiment.groupProperties?['org id']?['36958']?['features']
    //       ?.toString(),
    // );
    // print(userFromExperiment.userProperties?.toString());
    if (!mounted) return;

    setState(() {
      _test = variant?.toMap().toString() ?? 'No variant found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Text(
            // 'Running on: $_test\n$_fallbackVariant\n$_fallbackVariant2\n$_initialVariant\n',
            'Running on: $_test\n',
          ),
        ),
      ),
    );
  }
}
