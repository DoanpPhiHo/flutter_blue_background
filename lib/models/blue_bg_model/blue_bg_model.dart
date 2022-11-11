import 'dart:io';

import '../../flutter_blue_background.dart';

class BlueBgModel {
  BlueBgModel({
    this.baseUUID = '00001523-1212-efde-1523-785feabcd123',
    this.charUUID = '00001524-1212-efde-1523-785feabcd123',
    this.uuidService = const ['1808'],
  });

  final String baseUUID;
  final String charUUID;
  final List<String> uuidService;
  Map<String, dynamic> toJson() => {
        'baseUUID': baseUUID,
        'charUUID': charUUID,
        if (Platform.isIOS) 'uuidService': uuidService,
        if (Platform.isAndroid)
          'uuidService': uuidService.map((e) => Uuid.parse(e).data).toList(),
      };
}
