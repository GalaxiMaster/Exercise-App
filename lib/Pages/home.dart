import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
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
      leading: Center(
          child: MyIconButton(
            filepath: 'Assets/Arrow - Left 2.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: Color.fromRGBO(163, 163, 163, .7),
            color: Color.fromARGB(255, 245, 241, 241),
            iconHeight: 20,
            iconWidth: 20,
            ),
        ),
      actions: [
        Center(
          child: MyIconButton(
            filepath: 'Assets/dots.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: Color.fromRGBO(163, 163, 163, .7),
            color: Color.fromARGB(255, 245, 241, 241),
            ),
        )
      ],
    );
  }
