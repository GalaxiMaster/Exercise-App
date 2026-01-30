import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class Workoutsettings extends ConsumerWidget {
  const Workoutsettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    return Scaffold(
      appBar: myAppBar(context, 'Workout Settings'),
      body: settingsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (settings) {
          return Column(
            children: [
              buildSettingsTile(context, icon: Icons.check, label: 'Tick Boxes', function: () {}, rightside:  ToggleSwitch(
                initialValue: settings['Tick Boxes'] ?? false,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateValue('Tick Boxes', value);
                  debugPrint('Check slider value changed: $value');
                },
                ),
              ),
              buildSettingsTile(context, icon: Icons.check, label: 'Vibrations', function: () {}, rightside:  ToggleSwitch(
                initialValue: settings['Vibrations'] ?? false,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateValue('Vibrations', value);
                  debugPrint('Vibrations slider value changed: $value');
                },
                ),
              ),
            ],
          );
        }
      )
    );
  }
  
}

class ToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  ToggleSwitchState createState() => ToggleSwitchState();
}

class ToggleSwitchState extends State<ToggleSwitch> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (value) {
        setState(() {
          _value = value;
          widget.onChanged(value);
        });
      },
    );
  }
}