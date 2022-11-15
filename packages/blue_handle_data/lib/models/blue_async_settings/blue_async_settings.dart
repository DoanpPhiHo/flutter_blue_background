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

  final Id id;
  @Index(type: IndexType.value, name: 'name_tasks')
  final String nameTasks;
  @Index(name: 'value')
  final List<int> value;
  @enumerated
  @Index(name: 'status')
  final Status status;
}
