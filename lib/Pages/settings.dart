  import 'dart:io';
  import 'package:exercise_app/file_handling.dart';
  import 'package:flutter/material.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:share_plus/share_plus.dart';

  class Settings extends StatelessWidget {
    const Settings({super.key});

    @override
    Widget build(BuildContext context) {
      createSettings();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            _buildSettingsBox(
              icon: Icons.upload,
              label: 'Export data',
              function: exportJson,
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
                    return GoalOptions();
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

  void exportJson() async{
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/output.json';

        // Only share the file after ensuring it has been written
        final file = File(path);
        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(path)],
            text: 'Check out my workout data',
          );
        } else {
          debugPrint('Error: Json file does not exist for sharing');
        }
      } catch (e) {
        debugPrint('Error sharing Json file: $e');
      }
  }


class GoalOptions extends StatefulWidget {
  const GoalOptions({super.key});

  @override
  _GoalOptionsState createState() => _GoalOptionsState();
}

class _GoalOptionsState extends State<GoalOptions> {
  int _selectedIndex = 1; // Default selection
  final List<String> _options = List.generate(7, (index) => '${index + 1}');
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: _selectedIndex);
    _loadStartingPoint();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Load the starting point asynchronously
  Future<void> _loadStartingPoint() async {
    String startingPoint = await getStartingPoint();
    setState(() {
      _selectedIndex = _options.contains(startingPoint) ? _options.indexOf(startingPoint) : _selectedIndex;
    });
    _scrollController.jumpToItem(_selectedIndex); // Move to the starting point
  }

  Future<String> getStartingPoint() async {
    Map data = await getSettings();
    return data['Day Goal'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Day Goal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('Amount of times per week you want to go'),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.005,
                diameterRatio: 1.5,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= _options.length) return null;

                    final double opacity = 1.0 - (index - _selectedIndex).abs() * 0.1;
                    final adjustedOpacity = opacity.clamp(0.3, 1.0);

                    return Opacity(
                      opacity: adjustedOpacity,
                      child: Center(
                        child: Text(
                          _options[index],
                          style: TextStyle(
                            fontSize: 20,
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
              Navigator.pop(context);
              updateSettings('Day Goal', _options[_selectedIndex]);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}




  void updateSettings(String option, String value) async{
    Map data = await readData(path: 'settings');
    data[option] = value;
    debugPrint(data.toString());
    writeData(data, path: 'settings', append: false);
  }

  Future<Map> getSettings() async{
    Map daata = await readData(path: 'settings');
    return daata;
  }
  void createSettings() async{
    Map data = await readData(path: 'settings');
    if (data.isEmpty){
      Map settings = {
        'Day Goal' : '1'
      };
      writeData(settings, path: 'settings',append: false);
    }
  }