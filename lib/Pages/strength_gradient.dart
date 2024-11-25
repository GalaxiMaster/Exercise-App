import 'package:exercise_app/Pages/radar_chart.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StrengthGradiant extends StatefulWidget {
  const StrengthGradiant({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StrengthGradiantState createState() => _StrengthGradiantState();
}

class _StrengthGradiantState extends State<StrengthGradiant> {
  String timeSelected = 'All Time';
  int range = -1;
  String muscleSelected = 'All Muscles';
  @override
  initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: myAppBar(context, 'Strength Gradient'),
      body: FutureBuilder(
      future: getGradient(range, muscleSelected),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data ${snapshot.error}'));
        } else if (snapshot.hasData) {
          double gradient = double.parse((snapshot.data ?? 0).toStringAsFixed(2));
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _selectorBox(muscleSelected, 'muscles'),
                  _selectorBox(timeSelected, 'time'),
                ],
              ),
              Text('Gradient: ${gradient}x'),
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 1,
                      minY: -.2,
                      maxY: (gradient+0.2).clamp(0, 1),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('0');
                                case 1:
                                  return const Text('1');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                          )
                        )
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 2,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 0),
                            FlSpot(1, gradient),
                          ],
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blueAccent.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
      ),
    );
  }

  Padding _selectorBox(String text, String type) {
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async{
          var entry = await showModalBottomSheet(
            context: context,
            builder: (context) {
              if (type == 'time'){
                return TimeSelectorPopup(options: Options().timeOptions);
              }else{
                return TimeSelectorPopup(options: Options().muscleOptions); 
              }
            },
          );
          if (entry != null){
            if (type == 'time'){
              setState(() {
                timeSelected = entry.key;
                range = entry.value;
              });
            }else{
              setState(() {
                muscleSelected = entry.key;
              });
            }
          }
        },
        child: Container(
          width:  MediaQuery.of(context).size.width / 2-16,
          decoration: BoxDecoration(
            color: ThemeColors.accent,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 20
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
Future<double> getGradient(int range, String muscleGroup) async{
  Map data = await readData();
  Map exercisesMap = {};
  
  for (String day in data.keys){
    Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
    int diff = difference.inDays;
    if (diff <= range || range == -1){
      for (String exercise in data[day]['sets'].keys){
        for (String muscle in (muscleGroups[muscleGroup] ?? ['muscle'])){
          if ((exerciseMuscles[exercise]?['Primary'].containsKey(muscle) ?? false) || (exerciseMuscles[exercise]?['Secondary'].containsKey(muscle) ?? false) || muscleGroup == 'All Muscles'){
            // for (Map set in data[day]['sets'][exercise]){
            List sets = data[day]['sets'][exercise];
            Map set = sets[sets.length-1];
            if (!exercisesMap.containsKey(exercise)){
              exercisesMap[exercise] = [];
            }
            Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0]));
            exercisesMap[exercise].add([difference.inDays, set]);
          // }
          }
        }
      }
    }
  }
  List ms = [];
  for (String exercise in exercisesMap.keys){
    if (exercisesMap[exercise].length > 1){
      List<num> x = [];
      List<num> y = [];
      for (var pair in exercisesMap[exercise]!) {
        x.add(pair[0]); // x value is the first element
        // y.add(toNum(pair[1]['weight'])); // y value is in the 'weight' field of the second element
      }
      y = List.generate(x.length, (index) => index + 1);

      int n = x.length;
      if (n != 0){
        //         // Sum calculations
        // num sumX = x.reduce((a, b) => a + b);
        // num sumY = y.reduce((a, b) => a + b);
        // double sumXY = 0;
        // double sumXSquare = 0;

        // for (int i = 0; i < n; i++) {
        //   sumXY += x[i] * y[i];
        //   sumXSquare += x[i] * x[i];
        // }

        // // Calculating slope (m) and intercept (b)
        // var sackball = (n * sumXY - sumX * sumY);
        // var ballsack = (n * sumXSquare - sumX * sumX);
        // if (ballsack != 0){
        //   double m = sackball / ballsack;
        // // double b = (sumY - m * sumX) / n;
        //   ms.add(m);
        // }
        FlSpot a = FlSpot(x[0].toDouble(), y[0].toDouble());
        FlSpot b = FlSpot(x[x.length-1].toDouble(), y[y.length-1].toDouble());
        double m = (a.y-b.y)/(0-x.length);
        ms.add(m);

      }
    }
    
  }
  double mAverage = 0;
  if (ms.isNotEmpty){
    mAverage = ms.reduce((a, b) => a + b)/ms.length;
  }

  debugPrint('hi');
  return mAverage;
}

num toNum(weight) {
  return int.tryParse(weight.toString()) ?? double.parse(weight.toString());
}