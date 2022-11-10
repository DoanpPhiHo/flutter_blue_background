import '../models/glucose.dart';
import '../models/metro_info.dart';

class MeterUtil {
  const MeterUtil._();
  static const MeterUtil instance = MeterUtil._();
  DateTime readBGMTime(List<int> data) {
    final int day = data[0] & 0x1F;
    final int month = ((data[0] & 0xE0) >> 5) + ((data[1] & 1) << 3);
    final int year = (data[1] >> 1) + 2000;
    final int minute = data[2] & 0x3F;
    final int hour = data[3] & 0x1F;

    return DateTime(year, month, day, hour, minute);
  }
}

class BlueAsyncDataHandle {
  bool handleRawRecordData({required int cmd, required List<int> data}) {
    _decodeRecordData(cmd: cmd, data: data);
    return false;
  }

  void _decodeRecordData({required int cmd, required List<int> data}) {
    // ignore: unused_local_variable
    BloodGlucose bloodGlucose;

    final rx25rx26 = [
      data[2],
      data[3],
      data[4],
      data[5],
      data[2],
      data[3],
      data[4],
      data[5],
    ];
    bloodGlucose = BloodGlucose.fromDataBytes(rx25rx26);
    // switch (bloodGlucose.bloodParametersMeasurement) {
    //   case BloodParametersMeasurement.glucose:
    //     glucoseRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.hct:
    //     hctRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.ketone:
    //     ketoneRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.ua:
    //     uaRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.chol:
    //     cholRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.hb:
    //     hbRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.lactate:
    //     lactateRecords.add(bloodGlucose);
    //     break;
    //   case BloodParametersMeasurement.undetected:
    //     break;
    // }

    // rawRecordDataList = [];
  }

  /// return DateTime | MeterInfo | null
  ///
  dynamic handleRawMeterInfoData({required int cmd, required List<int> data}) {
    switch (MeterCmdType.values[cmd]) {
      case MeterCmdType.readDeviceClockTime:
        return MeterUtil.instance
            .readBGMTime([data[2], data[3], data[4], data[5]]);
      case MeterCmdType.readDeviceModel:
        return _readMeterInfo(data: data);
      case MeterCmdType.readStorageNumberOfData:
        return _decodeRecordAmount();
      case MeterCmdType.readDeviceSerialNumberPart1:
      case MeterCmdType.readDeviceSerialNumberPart2:
      // ignore: no_default_cases
      default:
        break;
    }
  }

  MeterInfo? _readMeterInfo({List<int>? data}) {
    if (data == null) {
      return null;
    }
    return MeterInfo(
      projectNo: '${data[3].toRadixString(16)}${data[2].toRadixString(16)}',
      subModel: String.fromCharCode(64 + data[4]),
      userNumber: data[5],
    );
  }

  MeterInfo? _decodeRecordAmount({List<int>? data}) {
    if (data == null) {
      return MeterInfo();
    }
    final List<int> byteData = data;
    int num = (byteData[3] << 8) + byteData[2];
    final meterInfo = _readMeterInfo();
    switch (meterInfo?.projectNo) {
      case '4255':
      case '4240':
        num = (num != 65535) ? (num + 1) : 0;
        if (num > 448) {
          num = 448;
        }
        break;
      case '4230':
        {
          final String deviceModelInHex =
              '${data[3].toRadixString(16)}${data[2].toRadixString(16)}';
          if (deviceModelInHex == '0000' ||
              meterInfo?.subModel.toUpperCase() == 'D') {
            num = (num != 65535) ? (num + 1) : 0;
          }
          break;
        }
      default:
        break;
    }
    return meterInfo?.copyWith(numberOfData: num);
  }
}
