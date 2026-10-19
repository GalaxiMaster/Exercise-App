import 'package:exercise_app/Pages/Routines/routines.dart';
import 'package:exercise_app/Pages/Add_Workout/add_workout.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/workout_stats.dart';
import 'package:exercise_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool showExerciseInProgressTile = true;
  @override
  void initState() {
    super.initState();
    cacheData();
  }

  void cacheData() {
    ref.read(customExercisesProvider);
    ref.read(profileChartProvider);
  }

  @override
  Widget build(BuildContext context) {
    final routineDataAsync = ref.watch(routineDataProvider);
    bool workoutInProgress = ref.watch(currentWorkoutProvider).isNotEmpty;
    return Scaffold(
      appBar: myAppBar(context, 'Workout', 
        button: MyIconButton(
          icon: Icons.person,
          width: 37,
          height: 37,
          borderRadius: 10,
          iconHeight: 20,
          iconWidth: 20,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => 
                const Profile()
              ),
            );
          }
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Blank",
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    MyTextButton(
                      text: "Start Workout", 
                      color: const Color(0xff9DCEFF),
                      pressedColor: Colors.blue, 
                      textColor: const Color.fromARGB(255, 0, 0, 0), 
                      borderRadius: 15, 
                      width: double.infinity, 
                      height: 50,
                      onTap: () async {
                        attemptStartWorkout(workoutInProgress);
                      }
                    ),
                    const SizedBox(height: 20,),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Routines",
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    MyTextButton(
                      text: "New routine", 
                      color: const Color(0xff9DCEFF),
                      pressedColor: Colors.blue, 
                      textColor: const Color.fromARGB(255, 0, 0, 0), 
                      borderRadius: 15, 
                      width: double.infinity, 
                      height: 50,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => 
                            AddRoutine()
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 20),
                    routineDataAsync.when(
                      loading: () => const Text("No routines available"),
                      error: (e, _) => const Text("Error: No routines available"),
                      data: (routines) {
                        return routines.isNotEmpty
                          ? ListView.builder(
                            itemCount: routines.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                            itemBuilder: (context, index) {
                              MapEntry<String, dynamic> routine = routines.entries.toList()[index];
                              return _buildRoutineBox(data: routine.value, id: routine.key);
                            },
                          )
                          : const Text("No routines available");
                      },
                    )
                  ],
                ),
              ),
            ),
            if (workoutInProgress && showExerciseInProgressTile)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: WorkoutInProgressWidget(
                  hideCallback: () {
                    setState(() {
                      showExerciseInProgressTile = false;
                    });
                  },
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineBox({
    required Map data,
    required String id
  }) {
    Color color = HexColor.fromHex(data['data']?['color'] ?? '#9DCEFF');
    String label =  data['data']?['name'] ?? 'Unknown Routine';
    String exercises =  data['slots'].map((slot) => slot['title']).join('\n') ?? 'No exercises';
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        exercises,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: PopupMenuButton<String>(
                      onSelected: (value) async{
                        switch(value){
                          case 'Edit':
                            debugPrint('edit');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => 
                                AddRoutine( 
                                  routine: data, 
                                )
                              ),
                            );
                          case 'Share':
                            debugPrint('share');
                          case 'Color':
                            debugPrint('color');
                          
                            Color? color = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                Color tempColor = HexColor.fromHex(
                                  data['data']?['color'] ?? '#ffffff'
                                );

                                return AlertDialog(
                                  title: const Text('Pick a color'),
                                  content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: tempColor,
                                    paletteType: PaletteType.hueWheel,
                                    enableAlpha: false,
                                    onColorChanged: (color){
                                      setState(() => tempColor = color);
                                    },  
                                  ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();  // Close without saving
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Reset'),
                                      onPressed: () {
                                        data['data']['color'] = null;
                                        ref.read(routineDataProvider.notifier).updateValue(id, data);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Select'),
                                      onPressed: () {
                                        Navigator.of(context).pop(tempColor);  // Return selected color
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (color != null) {
                              ref.read(routineDataProvider.notifier).updateColor(id, color.toHex());
                            }

                          case 'Delete':
                            ref.read(routineDataProvider.notifier).deleteRoutine(id);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'Share', child: Text('Share', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey))),    
                          const PopupMenuItem(value: 'Color', child: Text('Color')),                    
                          const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                        ];
                      },
                      elevation: 2, // Adjust the shadow depth here (default is 8.0)
                      icon: Icon(Icons.more_vert, color: color,),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              MyTextButton(
                text: 'Start routine',
                color: color,
                pressedColor: Colors.blue,
                textColor: Colors.black,
                borderRadius: 12.5,
                width: double.infinity,
                height: 40,
                onTap: () => attemptStartWorkout(
                  false, // todo check if workout in progress
                  data: deepCopy(data),
                  metaData: WorkoutMetaData(routineId: id, color: color)
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15)
      ],
    );
  }

  void attemptStartWorkout(bool workoutInProgress, {Map<String, dynamic>? data, WorkoutMetaData? metaData}) async{
    void pushExercisePage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddWorkout(initialData: data != null ? WorkoutDetails.fromJson(data) : null, metaData: metaData,)),
      );
      setState(() {
        showExerciseInProgressTile = true;
      });
    }
    if (workoutInProgress && mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Workout already in progress'),
            content: const Text('Continue or discard it?'),
            actions: [
              TextButton(
                child: const Text('Discard', style: TextStyle(color: Colors.red),),
                onPressed: () {
                  ref.read(currentWorkoutProvider.notifier).writeState(<String, dynamic>{});
                  Navigator.of(context).pop(); // Dismiss the dialog
                  pushExercisePage();
                },
              ),
              TextButton(
                child: const Text('Resume'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  pushExercisePage();
                },
              ),
            ],
          );
        },
      );
    }else{
      if (!mounted) return;
      pushExercisePage();
    }
  }
}

class WorkoutInProgressWidget extends ConsumerWidget {
  final Function hideCallback;
  const WorkoutInProgressWidget({
    super.key, required this.hideCallback,
  });

  void onTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWorkout()),
    );
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutData = ref.read(currentWorkoutProvider);
    return Material(
      color: Color.fromARGB(255, 21, 21, 21),
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(context),
        splashColor: Colors.white24,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          height: 50,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () => onTap(context),
              ),
              const Text(
                'Workout in progress',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              StateFulTimeSinceText(startTime: DateTime.tryParse(workoutData['stats']?['startTime'] ?? '') ?? DateTime.now()), // todo add stateful time since widget
              Spacer(),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                onPressed: () => hideCallback(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}