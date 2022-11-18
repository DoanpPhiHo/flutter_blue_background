import 'dart:io';

import 'package:flutter/foundation.dart';
// import 'package:isar/isar.dart';

// part 'blue_async_settings.g.dart';

enum Status {
  enable,
  disable,
}

// @collection
class BlueAsyncSettings {
  BlueAsyncSettings({
    this.id = 0, //Isar.autoIncrement,
    required this.nameTasks,
    required this.value,
    this.status = Status.enable,
  });
  factory BlueAsyncSettings.fromJson(Map<String, dynamic> json) =>
      BlueAsyncSettings(
        nameTasks: json['name'],
        value: Uint8List.fromList((json['value'] as List).cast<int>()),
      );

  final int id; //Id id;
  // @Index(type: IndexType.value, name: 'name_tasks')
  final String nameTasks;
  // @Index(name: 'value')
  final Uint8List value;
  // @enumerated
  // @Index(name: 'status')
  final Status status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_tasks': nameTasks,
        if (Platform.isAndroid) 'value': value,
        if (Platform.isIOS) 'value': value.toList()
      };
}
