<div align="center">
	<img src="https://i.giphy.com/media/04ksmd6y5Zhh9m07dy/giphy.webp" alt="Hello. I'm Ho Doan. I like code. Thanks for reading.">
</div>

# flutter_blue_background

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

#### *** proplem
- list task not retun all data

# waiting
- [read data record new -> old bread](https://github.com/DoanpPhiHo/flutter_blue_background.git)
- [save db native -> db flutter](https://github.com/DoanpPhiHo/flutter_blue_background.git)
- [convert code parse data flutter -> native](https://github.com/DoanpPhiHo/flutter_blue_background.git)
- * parse value skip
# complete
- # auto connect ble
- # write data
- # get data charactics
- # list task auto sync (add remove)
- # save list task db
- # listen value
# processing
- * read list task [ios](test)
- * read list task -> write value ble [ios](test)
- * save value db [ios](test)
- * read list data ble db [ios](test)
- * clear list data ble db [ios](test)
- * turn off ble [ios](test)

## Usage `FlutterBlueBackground`

# init plugins

# setting ios
 - update info.plist
  ```Info.plist
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>using blue</string>
  <key>NSBluetoothPeripheralUsageDescription</key>
  <string>using blue</string>
  <key>UIApplicationSupportsIndirectInputEvents</key>
  ```

# setting android
 - no need to do anything :)))

```dart
///init main app
Future<void> futute() async {
  Future.wait([
    FlutterBlueBackground.instance.initial(BlueBgModel()),
  ]);
  return;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: FutureBuilder(
        future: futute(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return const HomePage();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }),
  ));
}
```

# change default setting `BlueGbModel`

```dart
FlutterBlueBackground.instance.initial(
    BlueBgModel({
    baseUUID : '00001523-1212-efde-1523-785feabcd123',
    charUUID : '00001524-1212-efde-1523-785feabcd123',
    uuidService : const ['1808'],
  })
)
```

# start background auto connect ble

```dart
FlutterBlueBackground.instance.startBackgroundBluetooth()
```

# listen write value return data ble *`not support foreground service`

```dart
FlutterBlueBackground.instance.subscriptionData().listen((event) {
    // --- my code ---
    final data = event.cast<int>();
    log(data.parse);
    if (data.any((e) => e == 35)) {
        final res = data.sublist(2, 6);
        log(res.parse);
        setState(() => list = res);
    }
})
```

# auto gen value cmd

```dart
/// 0x23: Read device clock time
GenBgmMeter.instance.generateDeviceClockTimeCmd

/// 0x24: Read device model
GenBgmMeter.instance.generateDeviceModelCmd

/// 0x2b: Read storage number of data
GenBgmMeter.instance.generateStorageNumberOfDataCmd

/// 0x25: Read storage data date and time
GenBgmMeter.instance.generateStorageDataDateTimeCmd(index)

/// 0x26: Read storage data result
GenBgmMeter.instance.generateStorageDataResultCmd(index)
```

# write value ble
```dart
FlutterBlueBackground.instance.writeCharacteristic(
    GenBgmMeter.instance.generateDeviceClockTimeCmd,
);
```

# add task auto write data [parameters] (BlueAsyncSettings)
```dart
FlutterBlueBackground.instance.addTaskAsync(model)
```

# remove task auto write data [parameters] (`String` task name)
```dart
FlutterBlueBackground.instance.removeTaskAsync(nameTask)
```

# get list task auto write data
```dart
FlutterBlueBackground.instance.listTaskAsync()
```

# get list data result bg
```dart
FlutterBlueBackground.instance.listBleData()
```

### [example main app](/example/lib/main.dart)
### [page add task example](/example/lib/pages/async_settings/view/async_settings_page.dart)
### [page read, write ble example](/example/lib/pages/home/view/home_page.dart)