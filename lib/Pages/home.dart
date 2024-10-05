import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:exercise_app/Pages/routine_controller.dart';
import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map> routines = [];
  bool isCurrent = false;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
    getIsCurrent();
  }

  void getIsCurrent() async {
    Map data = await readData(path: 'current');
    setState(() {
      isCurrent = data['sets'] == null ? false : data['sets'].toString() != {}.toString();
    });
  }

  Future<void> _loadRoutines() async {
    List loadedRoutines = await getAllRoutines();
    setState(() {
      routines = List<Map>.from(loadedRoutines);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        context,
        'Workout',
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
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "Blank",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 5),
              MyTextButton(
                text: "Start Workout",
                pressedColor: Colors.blue,
                color: Colors.black,
                borderRadius: 15,
                width: double.infinity,
                height: 50,
                onTap: () {
                  if (isCurrent){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Workout already in progress'),
                          content: const Text('Continue or discard it?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Discard', style: TextStyle(color: Colors.red),),
                              onPressed: () {
                                resetData(false, true, false);
                                Navigator.of(context).pop(); // Dismiss the dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Addworkout()),
                                ).then((_) {
                                  getIsCurrent();  // Call the method after returning from Addworkout
                                });
                              },
                            ),
                            TextButton(
                              child: const Text('Resume'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Dismiss the dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Addworkout()),
                                ).then((_) {
                                  getIsCurrent();  // Call the method after returning from Addworkout
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Addworkout()),
                    ).then((_) {
                      getIsCurrent();  // Call the method after returning from Addworkout
                    });
                  }
                }
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "Routines",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 5),
              MyTextButton(
                text: "New routine",
                pressedColor: Colors.blue,
                color: Colors.black,
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
                  ? CustomReorderableListView(
                      children: routines.asMap().entries.map((entry) {
                        return _buildReorderableRoutineWidget(entry.value, entry.key);
                      }).toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = routines.removeAt(oldIndex);
                          routines.insert(newIndex, item);
                        });
                        _saveRoutineOrder();
                      },
                    )
                  : 
                const Text("No routines available"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReorderableRoutineWidget(Map data, int index) {
    return CustomReorderableDraggable(
      key: ValueKey(index),
      index: index,
      child: _buildStreakRestBox(data: data),
    );
  }

  Widget _buildStreakRestBox({required Map data}) {
    Color color = Colors.blue;
    String label = data['data']?['name'] ?? 'Unknown Routine';
    String exercises = data['sets'].keys?.join('\n') ?? 'No exercises';

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
                      onSelected: (value) {
                        // ... (Keep your existing menu logic here)
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'Share', child: Text('Share')),
                          const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                        ];
                      },
                      elevation: 2,
                      icon: Icon(Icons.more_vert, color: color),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              MyTextButton(
                text: 'Start routine',
                pressedColor: Colors.blue,
                color: Colors.black,
                borderRadius: 12.5,
                width: double.infinity,
                height: 40,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Addworkout(sets: data)),
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

  void _saveRoutineOrder() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/routine_order.json');
    final orderData = routines.map((routine) => routine['data']['name']).toList();
    await file.writeAsString(jsonEncode(orderData));
  }

  void deleteRoutine(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    String filepath = '${dir.path}/routines/$name.json';
    final File file = File(filepath);
    if (await file.exists()) {
      await file.delete();
      _loadRoutines();
    }
  }


Future<List> getAllRoutines() async {
  List routines = [];
  final dir = await getApplicationDocumentsDirectory();
  String filepath = '${dir.path}/routines';
  final directory = Directory(filepath);

  // Load the saved order
  final orderFile = File('${dir.path}/routine_order.json');
  List<String> order = [];
  if (await orderFile.exists()) {
    order = List<String>.from(jsonDecode(await orderFile.readAsString()));
  }

  if (await directory.exists()) {
    Map<String, Map> routineMap = {};
    await for (var entity in directory.list()) {
      if (entity is File) {
        String contents = await entity.readAsString();
        Map jsonData = jsonDecode(contents);
        String name = jsonData['data']['name'];
        routineMap[name] = jsonData;
      }
    }

    // Add routines in the saved order
    for (String name in order) {
      if (routineMap.containsKey(name)) {
        routines.add(routineMap[name]);
        routineMap.remove(name);
      }
    }

    // Add any remaining routines not in the saved order
    routines.addAll(routineMap.values);
  } else {
    debugPrint("Directory does not exist");
  }

  return routines;
}
}
class CustomReorderableListView extends StatefulWidget {
  final List<Widget> children;
  final Function(int, int) onReorder;

  const CustomReorderableListView({
    Key? key,
    required this.children,
    required this.onReorder,
  }) : super(key: key);

  @override
  _CustomReorderableListViewState createState() => _CustomReorderableListViewState();
}

class _CustomReorderableListViewState extends State<CustomReorderableListView> {
  int? draggedIndex;
  double dragPosition = 0;
  List<GlobalKey> itemKeys = [];

  @override
  void initState() {
    super.initState();
    itemKeys = List.generate(widget.children.length, (_) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        final child = widget.children[index];
        if (child is CustomReorderableDraggable) {
          return CustomReorderableDraggable(
            key: itemKeys[index],
            index: index,
            child: child.child,
            onDragStarted: () {
              setState(() {
                draggedIndex = index;
              });
            },
            onDragUpdate: (details) {
              setState(() {
                dragPosition += details.delta.dy;
                int newIndex = _getNewIndex(details.globalPosition);
                if (newIndex != -1 && newIndex != draggedIndex) {
                  widget.onReorder(draggedIndex!, newIndex);
                  draggedIndex = newIndex;
                  itemKeys.insert(newIndex, itemKeys.removeAt(draggedIndex!));
                }
              });
            },
            onDragEnd: (details) {
              setState(() {
                draggedIndex = null;
                dragPosition = 0;
              });
            },
          );
        }
        return child;
      }),
    );
  }

  int _getNewIndex(Offset globalPosition) {
    for (int i = 0; i < itemKeys.length; i++) {
      if (i == draggedIndex) continue; // Skip the dragged item
      
      final RenderBox? renderBox = itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final Size size = renderBox.size;
        final Offset position = renderBox.localToGlobal(Offset.zero);
        
        if (globalPosition.dy > position.dy && globalPosition.dy < position.dy + size.height) {
          if (draggedIndex! < i) {
            // Moving downwards
            return globalPosition.dy > position.dy + size.height / 2 ? i + 1 : i;
          } else {
            // Moving upwards
            return globalPosition.dy < position.dy + size.height / 2 ? i : i + 1;
          }
        }
      }
    }
    
    // If we're below all items, move to the end
    if (globalPosition.dy > itemKeys.last.currentContext!.findRenderObject()!.paintBounds.bottom) {
      return itemKeys.length - 1;
    }
    
    // If we're above all items, move to the beginning
    if (globalPosition.dy < itemKeys.first.currentContext!.findRenderObject()!.paintBounds.top) {
      return 0;
    }
    
    return -1; // No change
  }
}

class CustomReorderableDraggable extends StatelessWidget {
  final int index;
  final Widget child;
  final VoidCallback? onDragStarted;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DraggableDetails)? onDragEnd;

  const CustomReorderableDraggable({
    Key? key,
    required this.index,
    required this.child,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      axis: Axis.vertical,
      feedback: Material(
        elevation: 5,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: child,
      ),
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      child: child,
    );
  }
}