import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> diInit() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerLazySingleton<IAsyncSettings>(() => AsyncSettingsYmlp());
}

Future<void> clear() async {
  await getIt.popScope();
}
