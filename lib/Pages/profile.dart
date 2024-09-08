import 'package:exercise_app/Pages/Calender.dart';
import 'package:exercise_app/Pages/exercise_list.dart';
import 'package:exercise_app/Pages/muscle_data.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Pages/stats.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> messages = ['Calender', 'Exercises', 'Muscles', 'Stats'];
    return Scaffold(
      appBar: appBar(context),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
        return Column(
        children: [
          DataBarChart(data: snapshot.data!),

          SizedBox(
            width: double.infinity,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2, // Adjust to fit your needs
              ),
              shrinkWrap: true,
              padding: EdgeInsets.zero, // Remove padding around the GridView
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              itemCount: 4,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    Widget destination;
                    if (index == 0) {
                      destination = const CalenderScreen();
                    } else if (index == 1) {
                      destination = const ExerciseList();
                    } else if (index == 2){
                      destination = const MuscleData();
                    } else {
                      destination = const Stats();
                    }
          
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => destination)
                    );
                  },
                  child: Center(
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(8.0),
                      margin: EdgeInsets.zero, // Remove margin
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent, // Border color
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Keeps the column compact
                        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                        children: [
                          Text(
                            messages[index],
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
      } else {
            return const Center(child: Text('No data available'));
          }
        }
      )
    );
  }
}

class DataBarChart extends StatelessWidget {
  final Map data;
  const DataBarChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 7, // TODO goal
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Remove top numbers
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Remove right numbers
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 50,
                  reservedSize: 50,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${value.toInt()} days',
                          style: const TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Jun 17', style: TextStyle(color: Colors.black, fontSize: 12));
                      case 1:
                        return const Text('Jul 1', style: TextStyle(color: Colors.black, fontSize: 12));
                      case 2:
                        return const Text('Jul 15', style: TextStyle(color: Colors.black, fontSize: 12));
                      case 3:
                        return const Text('Jul 29', style: TextStyle(color: Colors.black, fontSize: 12));
                      case 4:
                        return const Text('Aug 12', style: TextStyle(color: Colors.black, fontSize: 12));
                      case 5:
                        return const Text('Aug 26', style: TextStyle(color: Colors.black, fontSize: 12));
                      default:
                        return const Text('', style: TextStyle(color: Colors.black, fontSize: 12));
                    }
                  },
                  reservedSize: 38,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            gridData: const FlGridData(
              show: false, // Remove grid lines in the center
            ),
            barGroups: data.entries.map((entry) {
              return BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(toY: double.parse(entry.value.toString()), color: Colors.blue, width: 20, borderRadius: BorderRadius.zero,)
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Profile',
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
            filepath: 'Assets/settings.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: const Color.fromRGBO(163, 163, 163, .7),
            color: const Color.fromARGB(255, 245, 241, 241),
            iconHeight: 20,
            iconWidth: 20,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => 
                  const Settings()
                )
              );
            },
            ),
        )
      ],
    );
  }

Future<Map> getData() async{
  Map data = await readData();
  int week = weekNumber(DateTime.now());
  Map weeks = {};
  for (var day in data.keys) {
    int weekNum = weekNumber(DateTime.parse(day.split(' ')[0]));
    if (week - weekNum <= 7){
      if (weeks[weekNum] != null){
        weeks[weekNum] += 1;
      } else{
        weeks[weekNum] = 1;
      }
    }
  }
  return weeks;
}

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
  }