part of 'async_settings_bloc.dart';

class AsyncSettingsState {
  final List<BlueAsyncSettings> blueDatas;

  AsyncSettingsState({
    required this.blueDatas,
  });
  factory AsyncSettingsState.init() => AsyncSettingsState(
        blueDatas: const [],
      );
  AsyncSettingsState copyWith({
    List<BlueAsyncSettings>? blueDatas,
  }) =>
      AsyncSettingsState(
        blueDatas: blueDatas ?? this.blueDatas,
      );
}
