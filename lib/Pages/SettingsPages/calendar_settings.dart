import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarSettings extends ConsumerStatefulWidget{
  const CalendarSettings({super.key});
  
  @override
  CalendarSettingsState createState() => CalendarSettingsState();
}

class CalendarSettingsState extends ConsumerState<CalendarSettings> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    return Scaffold(
      appBar: myAppBar(context, 'Calendar Settings'),
      body: settingsAsync.when(
        data: (settings) => Column(
            children: [
              _buildSettingsBox(icon: Icons.check, label: 'Colored days', rightside: ToggleSwitch(
                initialValue: settings['CalendarSettings']['MultiYear']['MultiColor'] ?? false,
                onChanged: (value) {
                  settings['CalendarSettings']['MultiYear']['MultiColor'] = value;
                  ref.read(settingsProvider.notifier).updateValue('CalendarSettings', settings['CalendarSettings']);
                  debugPrint('Check slider value changed: $value');
                },
                ),
              ),
              _buildSettingsBox(icon: Icons.check, label: 'Buffer 1st', rightside: ToggleSwitch(
                initialValue: settings['CalendarSettings']['MultiYear']['Buffer1st'] ?? false,
                onChanged: (value) {
                  settings['CalendarSettings']['MultiYear']['Buffer1st'] = value;
                  ref.read(settingsProvider.notifier).updateValue('CalendarSettings', settings['CalendarSettings']);
                  debugPrint('Buffer 1st slider value changed: $value');
                },
                ),
              ),
            ],
          ),
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      )
    );
  }
  
}
Widget _buildSettingsBox({
    required IconData icon,
    required String label,
    VoidCallback? function,
    Widget? rightside
  }) {
    return GestureDetector(
      onTap: function ?? (){},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 173, 173, 173).withValues(alpha: 0.1), // Background color for the whole box
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: const TextStyle(
                   fontSize: 23,
                ),
              ),
              const Spacer(),
              rightside ??
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios),
                ),
            ],
          ),
        ),
      ),
    );
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