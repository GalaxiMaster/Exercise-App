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
          Map<String, dynamic> settings = snapshot.data!;
          return Column(
            children: [
              buildSettingsTile(context, icon: Icons.check, label: 'Tick Boxes', function: () {}, rightside:  ToggleSwitch(
                initialValue: settings['Tick Boxes'] ?? false,
                onChanged: (value) {
                  settings['Tick Boxes'] = value;
                  writeData(settings, path: 'settings', append: false);
                  debugPrint('Check slider value changed: $value');
                },
                ),
              ),
              buildSettingsTile(context, icon: Icons.check, label: 'Vibrations', function: () {}, rightside:  ToggleSwitch(
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