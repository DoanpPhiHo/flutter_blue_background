class BleValueDb {
  BleValueDb({
    required this.time,
    required this.value,
  });
  factory BleValueDb.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'] as String;
    final List<int> date =
        timeStr.split(' ')[0].split('/').map((e) => int.parse(e)).toList();
    final List<int> time =
        timeStr.split(' ')[1].split(':').map((e) => int.parse(e)).toList();

    final value =
        (json['value'] as String).split(',').map((e) => int.parse(e)).toList();

    return BleValueDb(
      time: DateTime(date[0], date[1], date[2], time[0], time[1], time[2]),
      value: value,
    );
  }

  final DateTime time;
  final List<int> value;
}
