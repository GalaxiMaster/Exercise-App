import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});


  @override
  Widget build(BuildContext context) {
    List<String> settingsOptions = ['export data', 'days per week goal', 'reset data'];
    return Scaffold(
      appBar: AppBar(title: Text('Settings'),),
      body: Column(
        children: [

        ],
      )
    );
  }
}