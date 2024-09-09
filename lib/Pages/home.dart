import 'dart:convert';
import 'dart:io';
import 'package:exercise_app/Pages/RoutineController.dart';
import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List routines = [];

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    List loadedRoutines = await getAllRoutines();
    debugPrint("${loadedRoutines}identify");
    setState(() {
      routines = loadedRoutines;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context), // Pass context to appBar
      body: Padding(
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
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 15, 
              width: double.infinity, 
              height: 50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    Addworkout()
                  ),
                );
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
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 15, 
              width: double.infinity, 
              height: 50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    AddRoutine(onRoutineSaved: () {
                      Navigator.pop(context); // Go back to the previous page
                      _loadRoutines(); // Reload routines when we come back
                    })
                  ),
                );
              }
            ),
            const SizedBox(height: 20),
            routines.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      var routine = routines[index];
                      return _buildStreakRestBox(data: routine);
                    },
                  ),
                )
              : const Text("No routines available"),
          ],
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) { // Accept context as a parameter
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Workout',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      actions: [
        Center(
          child: MyIconButton(
            filepath: 'Assets/profile.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: const Color.fromRGBO(163, 163, 163, .7),
            color: const Color.fromARGB(255, 245, 241, 241),
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
        )
      ],
    );
  }

  void deleteRoutine(String name) async{
    final dir = await getApplicationDocumentsDirectory();
    String  filepath = '${dir.path}/routines/$name.json';
    debugPrint(filepath);
    final File file = File(filepath);
    if (await file.exists()) {
      await file.delete();   
      _loadRoutines();
    }
  }
  Widget _buildStreakRestBox({
  required Map data,
}) {
  Color color = Colors.blue;
  String label =  data['data']?['name'] ?? 'Unknown Routine';
  String exercises =  data['sets'].keys?.join('\n') ?? 'No exercises';
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Row(                
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // Align the text to the left within this column
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
                    onSelected: (value) {
                      switch(value){
                        case 'Edit':
                          debugPrint('edit');
                                          Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    AddRoutine(onRoutineSaved: () {
                      Navigator.pop(context); // Go back to the previous page
                      _loadRoutines(); // Reload routines when we come back
                    }, sets: data,o_name: label,)
                  ),
                );
                        case 'Share':
                          debugPrint('share');
                        case 'Delete':
                          deleteRoutine(label);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'Share', child: Text('Share')),                        
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
              pressedColor: Colors.black,
              color: color,
              borderRadius: 12.5,
              width: double.infinity,
              height: 40,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    Addworkout(sets: data)
                  ),
                );
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 15)
    ],
  );
}
}

Future<List> getAllRoutines() async {
  List routines = [];
  final dir = await getApplicationDocumentsDirectory();
  String  filepath = '${dir.path}/routines';
  final directory = Directory(filepath);

  if (await directory.exists()) {
    await for (var entity in directory.list()) {
      if (entity is File) {
        String contents = await entity.readAsString();
        // entity.delete();
        debugPrint('File: ${entity.path} identify');
        Map jsonData = jsonDecode(contents);
        routines.add(jsonData);
      } else if (entity is Directory) {
        debugPrint('Directory: ${entity.path}');
      }
    }
  } else {
    debugPrint("Directory does not exist");
  }
  debugPrint(routines.toString());
  return routines;
}

