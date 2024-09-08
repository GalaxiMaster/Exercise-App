import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';

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
      if (!days.contains(day.split(' ')[0])){
        days.add(day.split(' ')[0]);
      }
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
    debugPrint("$stats****************************************");
    return Scaffold(
      appBar: appBar(context),
      body: Center(
        child: Column(
          children: [
            Text('${stats['days'].length} days gone'),
            Text('${stats['sets']} sets done'),
            Text('${stats['exercises']} exercise done'),
            Text('Total volume : ${stats['volume'].fold(0, (p, c) => p + c).toString()}'),
            Text('Average volume : ${(stats['volume'].fold(0, (p, c) => p + c)/nonZeroLen(stats['volume'])).toStringAsFixed(1)}'),
            Text('Total time : ${stats['time'].fold(0, (p, c) => p + c).toString()} mins'),
            Text('Average time : ${(stats['time'].fold(0, (p, c) => p + c)/stats['time'].length).toStringAsFixed(1)} mins'),
          ],
        ),
      ),
    );
  }
}
AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Stats',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
    );
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