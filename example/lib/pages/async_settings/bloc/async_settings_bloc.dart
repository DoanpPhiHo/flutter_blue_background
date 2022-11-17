import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:meta/meta.dart';

part 'async_settings_event.dart';
part 'async_settings_state.dart';

class AsyncSettingsBloc extends Bloc<AsyncSettingsEvent, AsyncSettingsState> {
  // ignore: unused_field
  final IAsyncSettings _asyncSettings;
  AsyncSettingsBloc(this._asyncSettings) : super(AsyncSettingsState.init()) {
    // _asyncSettings.listenToBlueAsyncSettings()?.listen((list) => add(
    //       AsyncUpdateSettingsEvent(list),
    //     ));
    on<AsyncInitSettingsEvent>(
      (event, emit) async => emit(
        state.copyWith(
          blueDatas: await FlutterBlueBackground.instance.listTaskAsync(),
          bleDatas: await FlutterBlueBackground.instance.listBleData(),
        ),
      ),
    );
    on<AsyncAddSettingsEvent>((event, emit) async {
      // await _asyncSettings.add(event.model);
      final result =
          await FlutterBlueBackground.instance.addTaskAsync(event.model);
      if (result) {
        add(AsyncAddItemSettingsEvent(event.model));
      }
    });
    on<AsyncUpdateSettingsEvent>(
      (event, emit) => emit(state.copyWith(blueDatas: event.list)),
    );
    on<AsyncAddItemSettingsEvent>(
      (event, emit) => emit(
        state.copyWith(blueDatas: [
          ...state.blueDatas,
          event.item,
        ]),
      ),
    );
    on<AsyncRemoveSettingsEvent>((event, emit) async {
      final result =
          await FlutterBlueBackground.instance.removeTaskAsync(event.nameTask);
      if (result) {
        emit(
          state.copyWith(
              blueDatas: state.blueDatas
                  .where((e) => e.nameTasks != event.nameTask)
                  .toList()),
        );
      }
    });
  }
  @override
  Future<void> close() {
    return super.close();
  }
}
