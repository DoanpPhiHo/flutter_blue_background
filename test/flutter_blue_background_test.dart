import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:flutter_blue_background/flutter_blue_background_method_channel.dart';
import 'package:flutter_blue_background/flutter_blue_background_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBlueBackgroundPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBlueBackgroundPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> startBackgroundBluetooth() {
    throw UnimplementedError();
  }

  @override
  Stream subscriptionData() {
    throw UnimplementedError();
  }

  @override
  Future<bool> writeCharacteristic(List<int> list) {
    throw UnimplementedError();
  }

  @override
  Future<bool> initial(BlueBgModel bgModel) {
    throw UnimplementedError();
  }

  @override
  Future<bool> addTaskAsync(BlueAsyncSettings model) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeTaskAsync(String model) {
    throw UnimplementedError();
  }

  @override
  Future<List<BlueAsyncSettings>> readListTaskAsync() {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearBleData() {
    throw UnimplementedError();
  }

  @override
  Future<List<BleValueDb>> listBleData() {
    throw UnimplementedError();
  }

  @override
  Stream listenDevice() {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterBlueBackgroundPlatform initialPlatform =
      FlutterBlueBackgroundPlatform.instance;

  test('$MethodChannelFlutterBlueBackground is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBlueBackground>());
  });

  test('getPlatformVersion', () async {
    final FlutterBlueBackground flutterBlueBackgroundPlugin =
        FlutterBlueBackground.instance;
    final MockFlutterBlueBackgroundPlatform fakePlatform =
        MockFlutterBlueBackgroundPlatform();
    FlutterBlueBackgroundPlatform.instance = fakePlatform;

    expect(await flutterBlueBackgroundPlugin.getPlatformVersion(), '42');
  });
}
