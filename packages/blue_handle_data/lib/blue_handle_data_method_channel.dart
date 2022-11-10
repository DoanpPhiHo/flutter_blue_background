import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'blue_handle_data_platform_interface.dart';

/// An implementation of [BlueHandleDataPlatform] that uses method channels.
class MethodChannelBlueHandleData extends BlueHandleDataPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('blue_handle_data');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
