import 'dart:developer';
import 'dart:typed_data';

class GenBgmMeter {
  GenBgmMeter._();
  static final GenBgmMeter instance = GenBgmMeter._();

  /// 0x23: Read device clock time
  List<int> get generateDeviceClockTimeCmd => _generateCmd(cmd: 35);

  /// 0x24: Read device model
  List<int> get generateDeviceModelCmd => _generateCmd(cmd: 36);

  /// 0x25: Read storage data date and time
  List<int> generateStorageDataDateTimeCmd({int index = 0}) =>
      _generateCmd(cmd: 37, data0: index);

  /// 0x26: Read storage data result
  List<int> generateStorageDataResultCmd({int index = 0}) =>
      _generateCmd(cmd: 38, data0: index);

  /// 0x2b: Read storage number of data
  List<int> get generateStorageNumberOfDataCmd => _generateCmd(cmd: 43);
  List<int> _generateCmd({
    required int cmd,
    int data0 = 0,
    int data1 = 0,
    int data2 = 0,
    int data3 = 0,
  }) {
    log(cmd.toString());
    final List<int> array =
        MeterCmdUtil.instance.appendOneByteCheckSumToCmd(Uint8List.fromList([
      81,
      cmd,
      data0,
      data1,
      data2,
      data3,
      163,
    ]));

    return array;
  }
}

class MeterCmdUtil {
  MeterCmdUtil._();
  static final MeterCmdUtil instance = MeterCmdUtil._();
  List<int> appendOneByteCheckSumToCmd(List<int> sourceCmd) {
    final int checkSum =
        _calOneByteCheckSum(sourceCmd, 0, sourceCmd.length - 1);
    final List<int> array = List.empty(growable: true);
    array.addAll(sourceCmd);
    array.add(checkSum);

    return array;
  }

  int _calOneByteCheckSum(List<int> cmd, int startIndex, int endIndex) {
    int num = 0;
    for (int i = startIndex; i <= endIndex; i++) {
      num += cmd[i];
    }

    return num & 255;
  }
}
