import 'package:blue_handle_data/blue_handle_data.dart';

import 'flutter_blue_background_platform_interface.dart';
import 'models/blue_bg_model/blue_bg_model.dart';

export 'package:blue_handle_data/blue_handle_data.dart';

export 'models/blue_bg_model/blue_bg_model.dart';
export 'models/uuid.dart';

class FlutterBlueBackground {
  FlutterBlueBackground._();
  static FlutterBlueBackground instance = FlutterBlueBackground._();
  Future<String?> getPlatformVersion() {
    return FlutterBlueBackgroundPlatform.instance.getPlatformVersion();
  }

  Future<void> startBackgroundBluetooth() {
    return FlutterBlueBackgroundPlatform.instance.startBackgroundBluetooth();
  }

  Future<bool> writeCharacteristic(List<int> list) {
    return FlutterBlueBackgroundPlatform.instance.writeCharacteristic(list);
  }

  Future<bool> initial(BlueBgModel bgModel) {
    return FlutterBlueBackgroundPlatform.instance.initial(bgModel);
  }

  Future<bool> addTaskAsync(BlueAsyncSettings model) {
    return FlutterBlueBackgroundPlatform.instance.addTaskAsync(model);
  }

  Future<bool> removeTaskAsync(String model) {
    return FlutterBlueBackgroundPlatform.instance.removeTaskAsync(model);
  }

  Future<List<BlueAsyncSettings>> listTaskAsync() {
    return FlutterBlueBackgroundPlatform.instance.readListTaskAsync();
  }

  Future<List<BleValueDb>> listBleData() {
    return FlutterBlueBackgroundPlatform.instance.listBleData();
  }

  Future<bool> clearBleData() {
    return FlutterBlueBackgroundPlatform.instance.clearBleData();
  }

  Stream<dynamic> subscriptionData() {
    return FlutterBlueBackgroundPlatform.instance.subscriptionData();
  }

  Stream<dynamic> listenDevice() {
    return FlutterBlueBackgroundPlatform.instance.subscriptionData();
  }
}
