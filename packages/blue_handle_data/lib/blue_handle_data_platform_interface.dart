import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'blue_handle_data_method_channel.dart';

abstract class BlueHandleDataPlatform extends PlatformInterface {
  /// Constructs a BlueHandleDataPlatform.
  BlueHandleDataPlatform() : super(token: _token);

  static final Object _token = Object();

  static BlueHandleDataPlatform _instance = MethodChannelBlueHandleData();

  /// The default instance of [BlueHandleDataPlatform] to use.
  ///
  /// Defaults to [MethodChannelBlueHandleData].
  static BlueHandleDataPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BlueHandleDataPlatform] when
  /// they register themselves.
  static set instance(BlueHandleDataPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
