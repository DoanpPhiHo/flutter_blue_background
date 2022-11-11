import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_blue_background_method_channel.dart';
import 'models/blue_bg_model/blue_bg_model.dart';

abstract class FlutterBlueBackgroundPlatform extends PlatformInterface {
  /// Constructs a FlutterBlueBackgroundPlatform.
  FlutterBlueBackgroundPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBlueBackgroundPlatform _instance =
      MethodChannelFlutterBlueBackground();

  /// The default instance of [FlutterBlueBackgroundPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBlueBackground].
  static FlutterBlueBackgroundPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBlueBackgroundPlatform] when
  /// they register themselves.
  static set instance(FlutterBlueBackgroundPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> startBackgroundBluetooth() {
    throw UnimplementedError(
        'startBackgroundBluetooth() has not been implemented.');
  }

  Stream<dynamic> subscriptionData() {
    throw UnimplementedError('subscriptionData() has not been implemented.');
  }

  Future<bool> writeCharacteristic(List<int> list) {
    throw UnimplementedError('writeCharacteristic() has not been implemented.');
  }

  Future<bool> initial(BlueBgModel bgModel) {
    throw UnimplementedError('writeCharacteristic() has not been implemented.');
  }
}
