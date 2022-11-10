import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:flutter_blue_background/models/meter/gen_bgm_meter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final _flutterBlueBackgroundPlugin = FlutterBlueBackground();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _flutterBlueBackgroundPlugin.startBackgroundBluetooth();
    _flutterBlueBackgroundPlugin.subscriptionData().listen((event) {
      setState(() => text = event is List ? event[0].toString() : event);
    });
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterBlueBackgroundPlugin.getPlatformVersion() ??
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
              onPressed: () {
                _flutterBlueBackgroundPlugin.writeCharacteristic(
                  GenBgmMeter.instance.generateDeviceClockTimeCmd(),
                );
              },
              child: const Text('WriteData'),
            )
          ],
        ),
      ),
    );
  }
}
