part of 'async_settings_bloc.dart';

@immutable
abstract class AsyncSettingsEvent {}

class AsyncAddSettingsEvent extends AsyncSettingsEvent {
  final BlueAsyncSettings model;

  AsyncAddSettingsEvent(this.model);
}

class AsyncInitSettingsEvent extends AsyncSettingsEvent {
  AsyncInitSettingsEvent();
}

class AsyncRemoveSettingsEvent extends AsyncSettingsEvent {
  final String nameTask;

  AsyncRemoveSettingsEvent(this.nameTask);
}

class AsyncUpdateSettingsEvent extends AsyncSettingsEvent {
  final List<BlueAsyncSettings> list;

  AsyncUpdateSettingsEvent(this.list);
}

class AsyncAddItemSettingsEvent extends AsyncSettingsEvent {
  final BlueAsyncSettings item;

  AsyncAddItemSettingsEvent(this.item);
}

class AsyncClearSettingsEvent extends AsyncSettingsEvent {}
