import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:flutter_blue_background/models/meter/gen_bgm_meter.dart';

import '../../async_settings/view/async_settings_page.dart';

extension ParseString on List<int> {
  String get parse {
    return '[${map((e) => e.toString()).join(', ')}]';
  }
}

extension StringTime on DateTime {
  String get valueStr => '$day $month $year $hour:$minute:$second';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _platformVersion = 'Unknown';
  String text = '';
  List<int> list = [107, 45, 55, 16];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    FlutterBlueBackground.instance.startBackgroundBluetooth();
    FlutterBlueBackground.instance.subscriptionData().listen((event) {
      setState(() => text = event is List ? (event.cast<int>().parse) : event);
      if (event is List) {
        final data = event.cast<int>();
        log(data.parse);
        if (data.any((e) => e == 35)) {
          final res = data.sublist(2, 6);
          log(res.parse);
          setState(() => list = res);
        }
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('Running on: $_platformVersion\n')),
          Center(child: Text('data: $text\n')),
          if (list.isNotEmpty)
            Text(MeterUtil.instance.readBGMTime(list).valueStr),
          ElevatedButton(
            onPressed: () async {
              await FlutterBlueBackground.instance.writeCharacteristic(
                GenBgmMeter.instance.generateDeviceClockTimeCmd,
              );
              await Future.delayed(const Duration(seconds: 1));
              await FlutterBlueBackground.instance.writeCharacteristic(
                GenBgmMeter.instance.generateDeviceModelCmd,
              );
              await Future.delayed(const Duration(seconds: 1));
              await FlutterBlueBackground.instance.writeCharacteristic(
                GenBgmMeter.instance.generateStorageNumberOfDataCmd,
              );
              await Future.delayed(const Duration(seconds: 1));
              await FlutterBlueBackground.instance.writeCharacteristic(
                GenBgmMeter.instance.generateStorageDataDateTimeCmd(),
              );
              await Future.delayed(const Duration(seconds: 1));
              await FlutterBlueBackground.instance.writeCharacteristic(
                GenBgmMeter.instance.generateStorageDataResultCmd(),
              );
            },
            child: const Text('WriteData'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AsyncSettings.push(/*getIt()*/),
                ),
              );
            },
            child: const Text('Settings'),
          )
        ],
      ),
    );
  }
}
