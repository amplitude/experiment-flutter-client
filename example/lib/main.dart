import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:amplitude_experiment/amplitude_experiment.dart';

const String API_KEY = "client-QQEu7NCkqMmhdGdWl3Y4post5mZaVkCL";
const String USER_ID = "brian-bug-safari-1";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _variantValue;
  dynamic _variantPayload;

  @override
  void initState() {
    super.initState();
    initExperimentState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initExperimentState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await AmplitudeExperiment.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    var experiment = await AmplitudeExperiment.init(API_KEY);
    await experiment.start(USER_ID, null);
    var variant = await experiment.getVariant("brian-bug-safari");

    setState(() {
      _variantValue = variant?.value;
      _variantPayload = variant?.payload;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('value: $_variantValue\npayload: $_variantPayload'),
        ),
      ),
    );
  }
}
