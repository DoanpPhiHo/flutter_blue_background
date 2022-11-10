
import 'blue_handle_data_platform_interface.dart';

class BlueHandleData {
  Future<String?> getPlatformVersion() {
    return BlueHandleDataPlatform.instance.getPlatformVersion();
  }
}
