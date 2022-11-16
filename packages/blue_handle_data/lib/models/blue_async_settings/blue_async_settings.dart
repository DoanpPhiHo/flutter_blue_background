import 'package:isar/isar.dart';

part 'blue_async_settings.g.dart';

enum Status {
  enable,
  disable,
}

@collection
class BlueAsyncSettings {
  BlueAsyncSettings({
    this.id = Isar.autoIncrement,
    required this.nameTasks,
    required this.value,
    this.status = Status.enable,
  });
  factory BlueAsyncSettings.fromJson(Map<String, dynamic> json) =>
      BlueAsyncSettings(
        nameTasks: json['name'],
        value: (json['value'] as String)
            .split(',')
            .map((e) => int.parse(e))
            .toList(),
      );

  final Id id;
  @Index(type: IndexType.value, name: 'name_tasks')
  final String nameTasks;
  @Index(name: 'value')
  final List<int> value;
  @enumerated
  @Index(name: 'status')
  final Status status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_tasks': nameTasks,
        'value': value.join(','),
      };
}