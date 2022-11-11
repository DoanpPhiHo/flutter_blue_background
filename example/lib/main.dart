import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:flutter_blue_background/models/meter/gen_bgm_meter.dart';

extension ParseString on List<int> {
  String get parse {
    return '[${map((e) => e.toString()).join(', ')}]';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBlueBackground.instance.initial(BlueBgModel());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String text = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    FlutterBlueBackground.instance.startBackgroundBluetooth();
    FlutterBlueBackground.instance.subscriptionData().listen((event) {
      log(event);
      setState(() => text = event is List ? (event.cast<int>().parse) : event);
    });
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterBlueBackground.instance.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text('Running on: $_platformVersion\n')),
            Center(child: Text('data: $text\n')),
            ElevatedButton(
              onPressed: () async {
                await Future.wait([
                  // FlutterBlueBackground.instance.writeCharacteristic(
                  //   GenBgmMeter.instance.generateDeviceClockTimeCmd,
                  // ),
                  // FlutterBlueBackground.instance.writeCharacteristic(
                  //   GenBgmMeter.instance.generateDeviceModelCmd,
                  // ),
                  // FlutterBlueBackground.instance.writeCharacteristic(
                  //   GenBgmMeter.instance.generateStorageNumberOfDataCmd,
                  // ),
                  // FlutterBlueBackground.instance.writeCharacteristic(
                  //   GenBgmMeter.instance.generateStorageDataDateTimeCmd(),
                  // ),
                  FlutterBlueBackground.instance.writeCharacteristic(
                    GenBgmMeter.instance.generateStorageDataResultCmd(),
                  ),
                ]);
              },
              child: const Text('WriteData'),
            )
          ],
        ),
      ),
    );
  }
}
