import 'package:flutter/services.dart';
import 'package:flutter_blue_background/flutter_blue_background_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final MethodChannelFlutterBlueBackground platform =
      MethodChannelFlutterBlueBackground();
  const MethodChannel channel = MethodChannel('flutter_blue_background');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
