import 'package:exercise_app/Pages/Account/account.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/importing_page.dart';
import 'package:exercise_app/Pages/Account/sign_in.dart';
import 'package:exercise_app/Pages/SettingsPages/workout_settings.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsWatch = ref.watch(settingsProvider);
    return Scaffold(
      appBar: myAppBar(context, 'Settings'),
      body: settingsWatch.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (settings) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              settingsHeader('Preferences', context),
              buildSettingsTile(
                context,
                icon: Icons.person,
                label: 'Account',
                function: () async{ // When clicked, toggle a button somewhere that makes sure you can't click it twice, either by just having a backend variable or a loading widget on screen while its
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null){
                    user = FirebaseAuth.instance.currentUser;
                    if (!context.mounted) return;
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
                        builder: (context) => const SignInPage(),
                      ),
                    );  
                  }
                },
              ),
              buildSettingsTile(
                context,
                icon: Icons.flag,
                label: 'Days per week goal',
                function: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return GoalOptions(initialGoal: settings['Day Goal'],);
                    },
                  ).then((res){
                    if (res == null) return;
                    ref.read(settingsProvider.notifier).updateValue('Day Goal', res);

                  });
                },
              ),
              buildSettingsTile(
                context,
                icon: Icons.accessibility,
                label: 'Measurements',
                function: () async{
                  await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return MeasurementPopup(initialMeasurement: (settings['Bodyweight'] ?? '0'),);
                    },
                  );
                },
              ),
              buildSettingsTile(
                context,
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
              settingsHeader('Functions', context),
              buildSettingsTile(
                context,
                icon: Icons.upload,
                label: 'Export data',
                function: () => exportJson(context),
              ),
              setttingDividor(),
              buildSettingsTile(
                context,
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
              buildSettingsTile(
                context, 
                icon: Icons.refresh,
                label: 'Reset data',
                function: (){resetDataButton(context, ref);},
              ),
              buildSettingsTile(
                context, 
                icon: Icons.move_down,
                label: 'Move exercises',
                function: (){
                  moveExercises(context, ref);
                },
              ),
            ],
          );
      },
      ),
    );
  }
  Divider setttingDividor() => Divider(
        thickness: .3,
        color: Colors.grey.withValues(alpha: 0.5),
        height: 1,
      );
}

class GoalOptions extends ConsumerStatefulWidget {
  final String initialGoal;
  const GoalOptions({super.key, required this.initialGoal});

  @override
  // ignore: library_private_types_in_public_api
  _GoalOptionsState createState() => _GoalOptionsState();
}

class _GoalOptionsState extends ConsumerState<GoalOptions> {
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
    String startingPoint = widget.initialGoal;
    setState(() {
      _selectedIndex = _options.contains(startingPoint) ? _options.indexOf(startingPoint) : _selectedIndex;
    });
    Future.microtask((){
      _scrollController.jumpToItem(_selectedIndex); // Move to the starting point
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
                perspective: 0.009,
                diameterRatio: 2,
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
              Navigator.pop(context, _options[_selectedIndex]);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

void resetDataButton(BuildContext context, WidgetRef ref){
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
              Map providerKeys = {
                'output': workoutDataProvider,
                'settings': settingsProvider,
                'current': currentWorkoutProvider,
                'records': recordsProvider
              };
              for (MapEntry provider in providerKeys.entries){
                try {
                  ref.read(provider.value.notifier).updateState(<String, dynamic>{});
                } catch (e){
                  debugPrint('${provider.key} could not be reset: $e');
                }
              }
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    }
  );
}

void moveExercises(BuildContext context, WidgetRef ref) async{
  Map data = ref.read(workoutDataProvider).value ?? {};
  List? problemExercises = [];
  for (String day in data.keys){
    for (String exercise in data[day]['sets'].keys){
      if (exerciseMuscles[exercise] == null && !problemExercises.contains(exercise)){
        problemExercises.add(exercise);
      }
    }
  }
  problemExercises.isEmpty ? problemExercises = null : null;
  List? resultFromList = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>  WorkoutList(setting: 'choose', problemExercises: problemExercises, problemExercisesTitle: 'Invalid exercises',),
    ),
  );
  if (resultFromList == null) return;

  String resultFrom = resultFromList.first;
  if (!context.mounted) return;
  List? resultToList = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const WorkoutList(setting: 'choose',),
    ),
  );
  if (resultToList == null) return;
  String resultTo = resultToList.first;

  // Create a new map to preserve key order
  Map<String, dynamic> newData = {};

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
    ref.read(workoutDataProvider.notifier).updateValue(day, newData[day]);
  }
}

class MeasurementPopup extends ConsumerWidget{
  final String initialMeasurement;
  const MeasurementPopup({super.key, required this.initialMeasurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      ref.read(settingsProvider.notifier).updateValue('Bodyweight', value);
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