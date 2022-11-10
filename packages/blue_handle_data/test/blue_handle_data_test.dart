import 'package:blue_handle_data/blue_handle_data.dart';
import 'package:blue_handle_data/blue_handle_data_method_channel.dart';
import 'package:blue_handle_data/blue_handle_data_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBlueHandleDataPlatform
    with MockPlatformInterfaceMixin
    implements BlueHandleDataPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BlueHandleDataPlatform initialPlatform =
      BlueHandleDataPlatform.instance;

  test('$MethodChannelBlueHandleData is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBlueHandleData>());
  });

  test('getPlatformVersion', () async {
    final BlueHandleData blueHandleDataPlugin = BlueHandleData();
    final MockBlueHandleDataPlatform fakePlatform =
        MockBlueHandleDataPlatform();
    BlueHandleDataPlatform.instance = fakePlatform;

    expect(await blueHandleDataPlugin.getPlatformVersion(), '42');
  });
}
