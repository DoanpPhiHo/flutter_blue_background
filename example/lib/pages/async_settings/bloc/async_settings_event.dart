part of 'async_settings_bloc.dart';

@immutable
abstract class AsyncSettingsEvent {}

class AsyncAddSettingsEvent extends AsyncSettingsEvent {
  final BlueAsyncSettings model;

  AsyncAddSettingsEvent(this.model);
}

class AsyncRemoveSettingsEvent extends AsyncSettingsEvent {}

class AsyncUpdateSettingsEvent extends AsyncSettingsEvent {
  final List<BlueAsyncSettings> list;

  AsyncUpdateSettingsEvent(this.list);
}

class AsyncClearSettingsEvent extends AsyncSettingsEvent {}
