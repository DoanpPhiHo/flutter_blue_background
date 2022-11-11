import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_blue_background_platform_interface.dart';
import 'models/blue_bg_model/blue_bg_model.dart';

/// An implementation of [FlutterBlueBackgroundPlatform] that uses method channels.
class MethodChannelFlutterBlueBackground extends FlutterBlueBackgroundPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_blue_background');

  static EventChannel eventChanel =
      const EventChannel('flutter_blue_background/write_data_status');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> startBackgroundBluetooth() async {
    return await methodChannel.invokeMethod<bool>('startBackground') ?? false;
  }

  @override
  Future<bool> writeCharacteristic(List<int> list) async {
    log('message flutter writeCharacteristic');
    return await methodChannel.invokeMethod<bool>(
            'writeCharacteristic', list) ??
        false;
  }

  @override
  Future<bool> initial(BlueBgModel bgModel) async {
    log('message flutter writeCharacteristic');
    return await methodChannel.invokeMethod<bool>(
            'initial', bgModel.toJson()) ??
        false;
  }

  @override
  Stream<dynamic> subscriptionData() async* {
    yield* eventChanel.receiveBroadcastStream();
  }
}
