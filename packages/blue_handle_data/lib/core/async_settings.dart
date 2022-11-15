import 'package:isar/isar.dart';

import '../models/blue_async_settings/blue_async_settings.dart';

abstract class IAsyncSettings {
  Future<Isar?> openDb();
  Future<List<BlueAsyncSettings>?> gets();
  Future<BlueAsyncSettings?> get(int id);
  Future<void> clear();
  Future<void> add(BlueAsyncSettings value);
  Stream<List<BlueAsyncSettings>>? listenToBlueAsyncSettings();
}

class AsyncSettingsYmlp extends IAsyncSettings {
  AsyncSettingsYmlp() {
    db = openDb();
  }
  late Future<Isar?> db;
  @override
  Future<void> add(BlueAsyncSettings value) async {
    final isar = await db;
    isar?.writeTxnSync<int>(() => isar.blueAsyncSettings.putSync(value));
  }

  @override
  Future<void> clear() async {
    final isar = await db;
    isar?.writeTxn(() => isar.clear());
  }

  @override
  Future<Isar?> openDb() async {
    if (Isar.instanceNames.isEmpty) {
      return Isar.open([BlueAsyncSettingsSchema]);
    } else {
      return Future.value(Isar.getInstance());
    }
  }

  @override
  Future<BlueAsyncSettings?> get(int id) async {
    final isar = await db;
    return await isar?.blueAsyncSettings.filter().idEqualTo(id).findFirst();
  }

  @override
  Future<List<BlueAsyncSettings>?> gets() async {
    final isar = await db;
    return isar?.blueAsyncSettings.where().findAll();
  }

  @override
  Stream<List<BlueAsyncSettings>>? listenToBlueAsyncSettings() async* {
    final isar = await db;
    if (isar != null) {
      yield* isar.blueAsyncSettings.where().watch(fireImmediately: true);
    }
  }
}
