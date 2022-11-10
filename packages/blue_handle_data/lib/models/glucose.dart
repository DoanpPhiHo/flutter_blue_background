import 'package:convert/convert.dart';

class SpecRangeStruct {
  SpecRangeStruct({
    required this.specType,
    required this.bReadSpecRangeOK,
    required this.lowValue,
    required this.highValue,
  });

  final BloodParametersMeasurement specType;
  final bool bReadSpecRangeOK;
  final int lowValue;
  final int highValue;
}

abstract class AbstractRecord {
  AbstractRecord({required this.measureDateTime});
  late List<int> recordRawBytes;
  final DateTime measureDateTime;

  @override
  String toString() =>
      'MeasureTime: $measureDateTime, RawData: ${hex.encode(recordRawBytes)}';
}

enum MeterCmdType {
  readDeviceClockTime(35),
  readDeviceModel(36),
  readStorageDataTime(37),
  readStorageDataResult(38),
  readDeviceSerialNumberPart1(39),
  readDeviceSerialNumberPart2(40),
  readStorageNumberOfData(43);

  const MeterCmdType(this.value);
  final int value;
}

enum BloodParameter1 { gen, ac, pc, qc, exercise, bedTime }

enum BloodParametersMeasurement {
  undetected(-1),
  glucose(0),
  hct(6),
  ketone(7),
  ua(8),
  chol(9),
  hb(11),
  lactate(12);

  const BloodParametersMeasurement(this.value);
  final int value;
}

enum BloodMeasuredStatus {
  normal(0),
  invalid(-1),
  low(1),
  high(2),
  undefine(3);

  const BloodMeasuredStatus(this.value);
  final int value;
}

class BloodGlucose extends AbstractRecord {
  BloodGlucose(
    DateTime measureDateTime,
    List<int> recordRawBytes, {
    required this.value,
    required this.codeNo,
    required this.bloodParameter1,
    this.bloodParametersMeasurement = BloodParametersMeasurement.undetected,
    required this.ambient,
    this.measuredStatus = BloodMeasuredStatus.undefine,
  }) : super(measureDateTime: measureDateTime);
  factory BloodGlucose.fromDataBytes(List<int> rx25Andrx26DataBytes) {
    int num = 0;
    final int day = rx25Andrx26DataBytes[0] & 31;
    final int month = ((rx25Andrx26DataBytes[0] & 224) >> 5) +
        ((rx25Andrx26DataBytes[1] & 1) << 3);
    final int year = (rx25Andrx26DataBytes[1] >> 1) + 2000;
    final int minute = rx25Andrx26DataBytes[2] & 63;
    final int hour = rx25Andrx26DataBytes[3] & 31;
    // print('Measure date time: $measureDateTime');
    num = (rx25Andrx26DataBytes[3] & 224) >> 5;
    final valueInt = rx25Andrx26DataBytes[5] * 256 + rx25Andrx26DataBytes[4];
    final int num2 = (rx25Andrx26DataBytes[7] & 192) ~/ 64;
    final int num3 = (rx25Andrx26DataBytes[7] & 60) ~/ 4;
    BloodParameter1 blood = BloodParameter1.qc;
    switch (num2) {
      case 0:
        blood = BloodParameter1.gen;
        switch (num) {
          case 1:
            blood = BloodParameter1.exercise;
            break;
          case 2:
            blood = BloodParameter1.bedTime;
            break;
        }
        break;
      case 1:
        blood = BloodParameter1.ac;
        break;
      case 2:
        blood = BloodParameter1.pc;
        break;
      case 3:
        blood = BloodParameter1.qc;
        break;
      default:
        blood = BloodParameter1.qc;
        break;
    }
    BloodParametersMeasurement bloodP = BloodParametersMeasurement.lactate;
    switch (num3) {
      case 0:
        bloodP = BloodParametersMeasurement.glucose;
        break;
      case 6:
        bloodP = BloodParametersMeasurement.hct;
        break;
      case 7:
        bloodP = BloodParametersMeasurement.ketone;
        break;
      case 8:
        bloodP = BloodParametersMeasurement.ua;
        break;
      case 9:
        bloodP = BloodParametersMeasurement.chol;
        break;
      case 11:
        bloodP = BloodParametersMeasurement.hb;
        break;
      case 12:
        bloodP = BloodParametersMeasurement.lactate;
        break;
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 10:
        bloodP = BloodParametersMeasurement.undetected;
        break;
    }
    return BloodGlucose(
      DateTime(year, month, day, hour, minute),
      rx25Andrx26DataBytes,
      value: valueInt,
      codeNo: rx25Andrx26DataBytes[7] & 63,
      bloodParameter1: blood,
      ambient: rx25Andrx26DataBytes[6],
      bloodParametersMeasurement: bloodP,
    );
  }
  final int value;
  final int codeNo;
  final BloodParameter1 bloodParameter1;
  final BloodParametersMeasurement bloodParametersMeasurement;
  final int ambient;
  final BloodMeasuredStatus measuredStatus;

  @override
  String toString() =>
      'MeasureTime: $measureDateTime, value: $value, codeNo: $codeNo, BloodParam1: $bloodParameter1, BloodMeasurement: $bloodParametersMeasurement, Ambient: $ambient, RawData: ${hex.encode(recordRawBytes)}\n';
}
