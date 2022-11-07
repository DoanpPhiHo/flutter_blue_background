import 'flutter_blue_background_platform_interface.dart';

class FlutterBlueBackground {
  Future<String?> getPlatformVersion() {
    return FlutterBlueBackgroundPlatform.instance.getPlatformVersion();
  }

  Future<void> startBackgroundBluetooth() {
    return FlutterBlueBackgroundPlatform.instance.startBackgroundBluetooth();
  }

  Future<bool> writeCharacteristic(List<int> list) {
    return FlutterBlueBackgroundPlatform.instance.writeCharacteristic(list);
  }

  Stream<dynamic> subscriptionData() {
    return FlutterBlueBackgroundPlatform.instance.subscriptionData();
  }
}
