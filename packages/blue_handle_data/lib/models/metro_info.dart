class MeterInfo {
  MeterInfo({
    DateTime? clockTime,
    this.numberOfData = -1,
    this.subModel = '',
    this.projectNo = '',
    this.userNumber = -1,
  }) {
    deviceClockTime = clockTime ?? DateTime(0000);
  }
  late DateTime deviceClockTime;
  final String projectNo;
  final String subModel;
  final int userNumber;
  final int numberOfData;

  MeterInfo copyWith({
    DateTime? deviceClockTime,
    String? projectNo,
    String? subModel,
    int? userNumber,
    int? numberOfData,
  }) =>
      MeterInfo(
        clockTime: deviceClockTime ?? this.deviceClockTime,
        numberOfData: numberOfData ?? this.numberOfData,
        subModel: subModel ?? this.subModel,
        projectNo: projectNo ?? this.projectNo,
        userNumber: userNumber ?? this.userNumber,
      );

  @override
  String toString() => 'DeviceClockTime: $deviceClockTime'
      ', ProjectNo: $projectNo'
      ', SubModel: $subModel'
      ', UserNumber(0 or 1 means single user ,2 means 2 users,4 means 4 users): $userNumber'
      ', Number of data: $numberOfData';
}
