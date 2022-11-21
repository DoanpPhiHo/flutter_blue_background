import 'package:flutter/material.dart';

import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:flutter_blue_background_example/pages/home/view/home_page.dart';

import 'pages/utils/di.dart';

Future<void> futute() async {
  await Future.wait([
    FlutterBlueBackground.instance.initial(BlueBgModel()),
    diInit(),
  ]);
  return;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: FutureBuilder(
        future: futute(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return const HomePage();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }),
  ));
}
