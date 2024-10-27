import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IndividualDayScreen extends StatefulWidget {
  final DateTime date;
  final Map dayData;
  final Function reload;
  const IndividualDayScreen({super.key, required this.date, required this.dayData, required this.reload});
  @override
  // ignore: library_private_types_in_public_api
  _IndividualDayScreenState createState() => _IndividualDayScreenState();
}

class _IndividualDayScreenState extends State<IndividualDayScreen> {
  @override
  build(BuildContext context) {
    String dataStr = DateFormat('yyyy-MM-dd').format(widget.date);
    return Scaffold(
      appBar: myAppBar(context, dataStr),
      body: Column(
        
      ),
    );
  }

}