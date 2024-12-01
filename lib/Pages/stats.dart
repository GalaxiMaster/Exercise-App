import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  Map exerciseData = {};
  Map stats = {'days' : [], 'volume' : [], 'time' : [], 'sets' : 0, 'exercises' : 0};
  @override
  initState(){
    super.initState();  
    _loadHighlightedDays();
  }
  Future<void> _loadHighlightedDays() async {
    var data = await gatherData();
    debugPrint(data.toString());
    Map totalVolume = {};
    List<int> totalTime = [];
    List days = [];
    int sets = 0;
    int exercises = 0;
    for (var day in data.keys) {
      days.add(day);
      totalTime.add((DateTime.parse(data[day]['stats']['endTime']).difference(DateTime.parse(data[day]['stats']['startTime'])).inMinutes));
      for (var exercise in data[day]['sets'].keys){
        exercises++;
        for (var set in data[day]['sets'][exercise]){
          sets++;
          if (totalVolume.containsKey(day)){
            totalVolume[day] += (double.parse(set['weight'].toString()) * double.parse(set['reps'].toString()));
          } else{
            totalVolume[day] = (double.parse(set['weight'].toString()) * double.parse(set['reps'].toString()));
          }

        }
      }
    }
    setState(() {
      stats = {'days' : days, 'volume' : totalVolume.values.toList(), 'time' : totalTime, 'sets' : sets, 'exercises' : exercises};
      exerciseData = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Stats'),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                statBox('Sessions done', stats['days'].length.toString(), 3),
                statBox('Sets done', NumberFormat('#,###.##').format(stats['sets']).toString(), 3),            
                statBox('Exercises done', NumberFormat('#,###.##').format(stats['exercises']).toString(), 3),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                statBox('Avg sessions', '/TODO', 3),
                statBox('Sets/Session', (stats['sets']/stats['days'].length).toStringAsFixed(1), 3),            
                statBox('exercises/session', (stats['exercises']/stats['days'].length).toStringAsFixed(1), 3),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                statBox('Total volume', '${NumberFormat('#,###.##').format(double.parse(stats['volume'].fold(0, (p, c) => p + c).toStringAsFixed(2)))}Kg', 2),
                statBox('Average volume ', "${NumberFormat('#,###.##').format(double.parse((stats['volume'].fold(0, (p, c) => p + c)/nonZeroLen(stats['volume'])).toStringAsFixed(1)))}Kg", 2),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                statBox('Total time', "${NumberFormat('#,###.##').format(stats['time'].fold(0, (p, c) => p + c))} mins", 2),
                statBox('Average time', "${(stats['time'].fold(0, (p, c) => p + c)/stats['time'].length).toStringAsFixed(1)} mins", 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget statBox(String message, String stat, int rowItems){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 360/rowItems,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: const GradientBoxBorder(
            gradient: LinearGradient(colors: [Color.fromARGB(255, 157, 206, 255), Color.fromARGB(186, 60, 87, 224)]),
            width: 1,
          )
        ),
        child: Column(
          children: [
            Text(message),
            Text(stat)
          ],
        ),
      ),
    );
  }
}

Future<Map> gatherData() async {
  Map exerciseData = await readData();
  return exerciseData;
}

int nonZeroLen(List list){
  int len = 0;
  for (var i in list){
    if (i != 0){
      len++;
    }
  }
  return len;
}