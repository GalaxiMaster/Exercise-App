import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class CustomExerciseSettings extends ConsumerStatefulWidget {
  const CustomExerciseSettings({super.key});
  @override
  CustomExerciseSettingsState createState() => CustomExerciseSettingsState();
}

class CustomExerciseSettingsState extends ConsumerState<CustomExerciseSettings> {
  @override
  Widget build(BuildContext context) {
    final customExercisesAsync = ref.watch(customExercisesProvider);
    return Scaffold(
      appBar: myAppBar(
        context, 'Custom Exercise Settings',
        button: IconButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomExerciseSettings(),
              ),
            );
          }, 
          icon: Icon(Icons.settings)
        )
      ),
      body: customExercisesAsync.when(
        data: (map) {
          return Stack(
            children: [
              ListView.builder(
                itemCount: map.length,
                itemBuilder: (context, index){
                  MapEntry exercise = map.entries.toList()[index];
                  return _buildExerciseItem(exercise);
                }
              )
              // if (multiSelect)
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 50),
              //     child: GestureDetector(
              //       onTap: (){
              //         if(widget.setting == 'choose' ){
              //           Navigator.pop(context, selectedItems);
              //         }
              //         else{
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => ExerciseScreen(exercises: selectedItems)
              //               )
              //           );
              //         }
              //       },
              //       child: Container(
              //         decoration: BoxDecoration(
              //           color: Colors.blue,
              //           borderRadius: BorderRadius.circular(50)
              //         ),
              //         height: 50,
              //         width: double.infinity,
              //         child: Center(
              //           child: Text(
              //             'Choose ${selectedItems.length} exercise(s)',
              //             style: const TextStyle(
              //               fontSize: 20
              //             ),
              //           )
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ]
          );
        },
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
  Widget _buildExerciseItem(MapEntry exercise) {
    return InkWell(
      // onTap: (){
      //   if (multiSelect){
      //     setState(() {
      //       if (selectedItems.contains(exercise)){
      //         selectedItems.remove(exercise);
      //         if (selectedItems.isEmpty){
      //           multiSelect = false;
      //         }
      //       }else{
      //         if (!multiSelect){
      //           multiSelect = true;
      //         }
      //         selectedItems.add(exercise);
      //       }  
      //     });
      //   }else{
      //     if(widget.setting == 'choose' ){
      //       Navigator.pop(context, [exercise]);
      //     }
      //     else{
      //       Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => ExerciseScreen(exercises: [exercise])
      //           )
      //       );
      //     }
      //   }
      // },
      // onLongPress: (){
      //   if (widget.multiSelect){
      //     setState(() {
      //       if (selectedItems.contains(exercise)){
      //         selectedItems.remove(exercise);
      //         if (selectedItems.isEmpty){
      //           multiSelect == false;
      //         }
      //       }else{
      //         if (!multiSelect){
      //           multiSelect = true;
      //         }
      //         selectedItems.add(exercise);
      //       }  
      //     });
      //   }
      // },
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            // if (selectedItems.contains(exercise))
            // Padding(
            //   padding: const EdgeInsets.only(left: 20),
            //   child: Container(
            //     width: 2,
            //     height: 60,
            //     decoration: const BoxDecoration(
            //       color: Colors.blue,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/profile.svg",
                      height: 35,
                      width: 35,
                      colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                  )
                  // : assetExists[exercise] == true
                  //     ? Image.asset(
                  //         "assets/Exercises/$exercise.png",
                  //         height: 50,
                  //         width: 50,
                  //       )
                  //     : Padding(
                  //         padding: const EdgeInsets.all(8),
                  //         child: SvgPicture.asset(
                  //           "assets/profile.svg",
                  //           height: 35,
                  //           width: 35,
                  //         ),
                  //       ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.key,
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
                Text('Primary: ${exercise.value['Primary'].keys.toList().join(', ')}'),
                if (exercise.value['Secondary'].length > 0)
                Text('Secondary: ${exercise.value['Secondary'].keys.toList().join(', ')}')
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: IconButton(
                onPressed: (){
                  ref.read(customExercisesProvider.notifier).deleteExercise(exercise.key);
                }, 
                icon: Icon(Icons.delete)
              )
            )
          ],
        ),
      ),
    );
  }
}