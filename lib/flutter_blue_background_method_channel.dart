import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_blue_background.dart';
import 'flutter_blue_background_platform_interface.dart';

/// An implementation of [FlutterBlueBackgroundPlatform] that uses method channels.
class MethodChannelFlutterBlueBackground extends FlutterBlueBackgroundPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_blue_background');

  static EventChannel eventChanel =
      const EventChannel('flutter_blue_background/write_data_status');
  static EventChannel eventChanelDb =
      const EventChannel('flutter_blue_background/db');

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
    return await methodChannel.invokeMethod<bool>(
            'writeCharacteristic', list) ??
        false;
  }

  @override
  Future<List<BlueAsyncSettings>> readListTaskAsync() async {
    final result = await methodChannel.invokeMethod('get_list_task_async');
    return (jsonDecode(result) as List)
        .map((e) => BlueAsyncSettings.fromJson(e))
        .toList();
  }

  @override
  Future<bool> initial(BlueBgModel bgModel) async {
    return await methodChannel.invokeMethod<bool>(
            'initial', bgModel.toJson()) ??
        false;
  }

  @override
  Future<bool> addTaskAsync(BlueAsyncSettings model) async {
    return await methodChannel.invokeMethod<bool>(
            'add_task_async', model.toJson()) ??
        false;
  }

  @override
  Future<bool> removeTaskAsync(String model) async {
    return await methodChannel.invokeMethod<bool>('remove_task_async', model) ??
        false;
  }

  @override
  Stream<dynamic> subscriptionData() async* {
    yield* eventChanel.receiveBroadcastStream();
  }
}
