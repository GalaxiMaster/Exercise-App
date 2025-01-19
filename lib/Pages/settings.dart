import 'dart:io';
import 'package:exercise_app/Pages/account.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/importing_page.dart';
import 'package:exercise_app/Pages/sign_in.dart';
import 'package:exercise_app/Pages/workoutSettings.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

  class Settings extends StatelessWidget {
    const Settings({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: myAppBar(context, 'Settings'),
        body: FutureBuilder(
        future: getAllSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            Map? settings = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                settingsheader('Preferences'),
                _buildSettingsBox(
                  icon: Icons.person,
                  label: 'Account',
                  function: () async{ // When clicked, toggle a button somewhere that makes sure you can't click it twice, either by just having a backend variable or a loading widget on screen while its
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null){
                      await reAuthUser(user, context);
                      user = FirebaseAuth.instance.currentUser;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountPage(accountDetails: user!),
                        ),
                      );  
                    }else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInPage(),
                        ),
                      );  
                    }
                  },
                ),
                _buildSettingsBox(
                  icon: Icons.flag,
                  label: 'Days per week goal',
                  function: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return const GoalOptions();
                      },
                    );
                  },
                ),
                _buildSettingsBox(
                  icon: Icons.accessibility,
                  label: 'Measurements',
                  function: () async{
                    await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return MeasurementPopup(initialMeasurement: (settings?['bodyweight'] ?? '0'),);
                      },
                    );
                    settings = await getAllSettings();
                  },
                ),
                _buildSettingsBox(
                  icon: Icons.local_activity,
                  label: 'Workout',
                  function: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Workoutsettings(),
                      ),
                    );              
                  },
                ),
                // setttingDividor(),
                settingsheader('Functions'),
                _buildSettingsBox(
                  icon: Icons.upload,
                  label: 'Export data',
                  function: exportJson,
                ),
                setttingDividor(),
                _buildSettingsBox(
                  icon: Icons.download,
                  label: 'Import data',
                  function: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImportingPage(),
                      ),
                    );   
                    // importData(context);
                  },
                ),
                _buildSettingsBox(
                  icon: Icons.refresh,
                  label: 'Reset data',
                  function: (){resetDataButton(context);},
                ),
                setttingDividor(),
                _buildSettingsBox(
                  icon: Icons.move_down,
                  label: 'Move exercises',
                  function: (){moveExercises(context);},
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
        ),
      );
    }

    Padding settingsheader(String header) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          header,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: .8
          ),
        ),
      );
    }
  Future<String> getBodyweight() async {
    Map data = await getAllSettings();
    return data['bodyweight'] ?? '';
  }
    Divider setttingDividor() => Divider(
          thickness: .3,
          color: Colors.grey.withOpacity(0.5),
          height: 1,
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
  // ignore: library_private_types_in_public_api
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
    Map data = await getAllSettings();
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
                            color: _selectedIndex == index ? Colors.blue : const Color.fromARGB(96, 255, 255, 255),
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

void resetDataButton(BuildContext context){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure you want to delete your data'),
        content: const Text('Doing so will reset ALL of your data'),
        actions: <Widget>[
          TextButton(
            child: const Text('cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red),),
            onPressed: () {
              resetData(true, true, true);
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    }
  );
}

void updateSettings(String option, String value) async{
  Map data = await readData(path: 'settings');
  data[option] = value;
  debugPrint(data.toString());
  writeData(data, path: 'settings', append: false);
}

void moveExercises(BuildContext context) async{
  List? problemExercises = [];
  Map data = await readData();
  for (String day in data.keys){
    for (String exercise in data[day]['sets'].keys){
      if (exerciseMuscles[exercise] == null && !problemExercises.contains(exercise)){
        problemExercises.add(exercise);
      }
    }
  }
  problemExercises.isEmpty ? problemExercises = null : null;
  List? resultFromList = await Navigator.push(
    // ignore: use_build_context_synchronously
    context,
    MaterialPageRoute(
      builder: (context) =>  WorkoutList(setting: 'choose', problemExercises: problemExercises, problemExercisesTitle: 'Invalid exercises',),
    ),
  );
if (resultFromList == null) return; // TODO clean slightly

String resultFrom = resultFromList[0];
List? resultToList = await Navigator.push(
  // ignore: use_build_context_synchronously
  context,
  MaterialPageRoute(
    builder: (context) => const WorkoutList(setting: 'choose',),
  ),
);
if (resultToList == null) return; // TODO clean slightly
String resultTo = resultToList[0];

// Create a new map to preserve key order
Map newData = {};

for (var day in data.keys) {
  newData[day] = {
    'stats': {},
    'sets': {}  // Create an empty 'sets' map to populate later
  };
  
  // Iterate over the original keys in order
  for (var exercise in data[day]['sets'].keys) {
    if (exercise == resultFrom) {
      newData[day]['stats'] = data[day]['stats'];
      newData[day]['sets'][resultTo] = data[day]['sets'][exercise];
    } else {
      // Keep the original key and value
      newData[day]['stats'] = data[day]['stats'];
      newData[day]['sets'][exercise] = data[day]['sets'][exercise];
    }
  }
}
resetData(true, false, false);
writeData(newData);



  
}

class MeasurementPopup extends StatelessWidget{
  final String initialMeasurement;
  const MeasurementPopup({super.key, required this.initialMeasurement});



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bodyweight (kg): ',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 50,
                  width: 65,
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
                    ],
                    initialValue: initialMeasurement,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      // border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16, // Adjust hint text size
                      ),
                    ),
                    onChanged: (value){
                      updateSettings('bodyweight', value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
