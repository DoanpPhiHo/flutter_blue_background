part of 'async_settings_bloc.dart';

class AsyncSettingsState {
  final List<BlueAsyncSettings> blueDatas;
  final List<BleValueDb> bleDatas;

  AsyncSettingsState({
    required this.blueDatas,
    required this.bleDatas,
  });
  factory AsyncSettingsState.init() => AsyncSettingsState(
        blueDatas: const [],
        bleDatas: const [],
      );
  AsyncSettingsState copyWith({
    List<BlueAsyncSettings>? blueDatas,
    List<BleValueDb>? bleDatas,
  }) =>
      AsyncSettingsState(
        blueDatas: blueDatas ?? this.blueDatas,
        bleDatas: bleDatas ?? this.bleDatas,
      );
}
