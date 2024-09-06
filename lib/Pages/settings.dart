import 'dart:io';
import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          _buildSettingsBox(
            icon: Icons.upload,
            label: 'Export data',
            function: exportCsv,
          ),
          setttingDividor(),
          _buildSettingsBox(
            icon: Icons.flag,
            label: 'Days per week goal',
            function: () {
              // Wrap showBottomSheet in a VoidCallback function
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return RestTimerOptions();
                },
              );
            },
          ),
          setttingDividor(),
          _buildSettingsBox(
            icon: Icons.refresh,
            label: 'Reset data',
            function: (){resetData(true, false);},
          ),
        ],
      ),
    );
  }

  Divider setttingDividor() => const Divider(
        thickness: 1,
        color: Colors.grey,
        height: 1,
      );
}

Widget _buildSettingsBox({
  required IconData icon,
  required String label,
  required VoidCallback? function,
}) {
  Color color = Colors.black;
  return GestureDetector(
    onTap: function,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 173, 173, 173).withOpacity(0.1), // Background color for the whole box
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 23,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios, color: color),
            ),
          ],
        ),
      ),
    ),
  );
}

void exportCsv() async{
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/output.csv';

      // Only share the file after ensuring it has been written
      final file = File(path);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Check out this CSV file!',
        );
      } else {
        debugPrint('Error: CSV file does not exist for sharing');
      }
    } catch (e) {
      debugPrint('Error sharing CSV file: $e');
    }
}

class RestTimerOptions extends StatefulWidget {
  const RestTimerOptions({super.key});

  @override
  _RestTimerOptionsState createState() => _RestTimerOptionsState();
}

class _RestTimerOptionsState extends State<RestTimerOptions> {
  int _selectedIndex = 1; // Default selection at index 5 (e.g., 25s)

  // List of rest timer options
  final List<String> _options = List.generate(7, (index) => '${index+1}');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250, // Adjusted height to display more items
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Rest Timer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('Default Rest Timer Setting'),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.005,  // Slight perspective to make it more visible
                diameterRatio: 1.5,  // Adjust this to control how many items show
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= _options.length) return null;

                    // Calculate opacity based on distance from the selected index
                    final double opacity = 1.0 - (index - _selectedIndex).abs() * 0.1;
                    final adjustedOpacity = opacity.clamp(0.3, 1.0); // Minimum opacity

                    return Opacity(
                      opacity: adjustedOpacity,
                      child: Center(
                        child: Text(
                          _options[index],
                          style: TextStyle(
                            fontSize: 20, // Adjusted font size for better visibility
                            color: _selectedIndex == index ? Colors.blue : Colors.black38,
                            fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _options.length,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _options[_selectedIndex]); // Return selected option
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}