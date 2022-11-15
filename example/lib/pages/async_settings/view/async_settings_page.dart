import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:flutter_blue_background/models/meter/gen_bgm_meter.dart';
import 'package:flutter_blue_background_example/pages/async_settings/bloc/async_settings_bloc.dart';

class AsyncSettings extends StatefulWidget {
  const AsyncSettings._({super.key});

  static Widget push(IAsyncSettings asyncSettings, {Key? key}) => BlocProvider(
        create: (ctx) => AsyncSettingsBloc(asyncSettings),
        child: AsyncSettings._(
          key: key,
        ),
      );

  @override
  State<AsyncSettings> createState() => _AsyncSettingsState();
}

class _AsyncSettingsState extends State<AsyncSettings> {
  AsyncSettingsBloc get bloc => context.read<AsyncSettingsBloc>();
  final listBase = {
    '0x23': GenBgmMeter.instance.generateDeviceClockTimeCmd,
    '0x24': GenBgmMeter.instance.generateDeviceModelCmd,
    '0x2b': GenBgmMeter.instance.generateStorageNumberOfDataCmd,
    '0x25': GenBgmMeter.instance.generateStorageDataDateTimeCmd(),
    '0x26': GenBgmMeter.instance.generateStorageDataResultCmd(),
    'turn_off': GenBgmMeter.instance.turnOff,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AsyncSettings')),
      body: BlocBuilder<AsyncSettingsBloc, AsyncSettingsState>(
        buildWhen: (p, c) => !listEquals(p.blueDatas, c.blueDatas),
        builder: (context, state) => ListView(
          children: [
            for (final item in state.blueDatas)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(
                    width: 1,
                    color: Colors.amberAccent,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('name: ${item.nameTasks}'),
                    Text('list: ${item.value.join(', ')}'),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: Colors.green,
            ),
          ),
        ),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in listBase.entries)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(
                    width: 1,
                    color: Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(item.key)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => bloc.add(
                        AsyncAddSettingsEvent(
                          BlueAsyncSettings(
                            nameTasks: item.key,
                            value: item.value,
                          ),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
