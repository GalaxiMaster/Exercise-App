import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      
      body: const Column(
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: MyTextButton(
              text: "Start Workout", 
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 40, 
              width: 400, 
              height: 50,
            )
           ),
          ],
          ),
      );
  }
}

AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Breakfast',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      actions: const [
        Center(
          child: MyIconButton(
            filepath: 'Assets/profile.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: Color.fromRGBO(163, 163, 163, .7),
            color: Color.fromARGB(255, 245, 241, 241),
            iconHeight: 20,
            iconWidth: 20,
            ),
        )
      ],
    );
  }
