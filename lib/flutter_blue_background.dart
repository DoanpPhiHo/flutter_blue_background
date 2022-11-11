import 'flutter_blue_background_platform_interface.dart';
import 'models/blue_bg_model/blue_bg_model.dart';

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

  Stream<dynamic> subscriptionData() {
    return FlutterBlueBackgroundPlatform.instance.subscriptionData();
  }
}
