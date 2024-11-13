import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';

class Workoutsettings extends StatefulWidget{
  const Workoutsettings({super.key});
  
  @override
  // ignore: library_private_types_in_public_api
  _WorkoutsettingsState createState() => _WorkoutsettingsState();
}

class _WorkoutsettingsState extends State<Workoutsettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Workout Settings'),
      body: FutureBuilder(
        future: getAllSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
          Map settings = snapshot.data!;
          return Column(
            children: [
              _buildSettingsBox(icon: Icons.check, label: 'Tick Boxes', function: () {}, rightside:  ToggleSwitch(
                initialValue: settings['Tick Boxes'] ?? false,
                onChanged: (value) {
                  settings['Tick Boxes'] = value;
                  writeData(settings, path: 'settings', append: false);
                  debugPrint('Check slider value changed: $value');
                },
                ),
              ),
              _buildSettingsBox(icon: Icons.check, label: 'Vibrations', function: () {}, rightside:  ToggleSwitch(
                initialValue: settings['Vibrations'] ?? true,
                onChanged: (value) {
                  settings['Vibrations'] = value;
                  writeData(settings, path: 'settings', append: false);
                  debugPrint('Vibrations slider value changed: $value');
                },
                ),
              ),
            ],
          );
        } else{
          return const Text('Error');
        }
      } 
      )
    );
  }
  
}
Widget _buildSettingsBox({
    required IconData icon,
    required String label,
    required VoidCallback? function,
    Widget? rightside
  }) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 173, 173, 173).withOpacity(0.1), // Background color for the whole box
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
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
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