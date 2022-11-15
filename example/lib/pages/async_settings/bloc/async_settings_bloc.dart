import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:meta/meta.dart';

part 'async_settings_event.dart';
part 'async_settings_state.dart';

class AsyncSettingsBloc extends Bloc<AsyncSettingsEvent, AsyncSettingsState> {
  final IAsyncSettings _asyncSettings;
  AsyncSettingsBloc(this._asyncSettings) : super(AsyncSettingsState.init()) {
    _asyncSettings.listenToBlueAsyncSettings()?.listen((list) => add(
          AsyncUpdateSettingsEvent(list),
        ));
    on<AsyncAddSettingsEvent>((event, emit) async {
      await _asyncSettings.add(event.model);
    });
    on<AsyncUpdateSettingsEvent>(
      (event, emit) => emit(state.copyWith(blueDatas: event.list)),
    );
  }
}
