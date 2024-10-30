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
  late bool isShowingMainData;
  @override
  initState(){
    super.initState();
    isShowingMainData = true;
    
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: myAppBar(context, 'Strength Gradient'),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _selectorBox('All Muscles'),
              _selectorBox('All Time')
            ],
          ),
          Container(
            height: 250,
            child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 10,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return Text('Mon');
                        case 1:
                          return Text('Tue');
                        case 2:
                          return Text('Wed');
                        case 3:
                          return Text('Thu');
                        case 4:
                          return Text('Fri');
                        case 5:
                          return Text('Sat');
                        case 6:
                          return Text('Sun');
                        default:
                          return Text('');
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}');
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false
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
                    FlSpot(0, 3),
                    // FlSpot(1, 5),
                    // FlSpot(2, 7),
                    // FlSpot(3, 8),
                    // FlSpot(4, 5),
                    // FlSpot(5, 6),
                    FlSpot(6, 9),
                  ],
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 4,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                ),
              ],
            ),
                    ),
          ),
        ],
      ),
    );
  }

  Padding _selectorBox(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width:  MediaQuery.of(context).size.width / 2-16,
        decoration: BoxDecoration(
          color: ThemeColors.accent,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.5),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  // LineChartBarData(
  //       color: Colors.orange,
  //       barWidth: 4,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(show: false),
  //       spots: const [
  //         FlSpot(1, 1),
  //         FlSpot(3, 4),
  //         FlSpot(5, 1.8),
  //         FlSpot(7, 5),
  //         FlSpot(10, 2),
  //         FlSpot(12, 2.2),
  //         FlSpot(13, 1.8),
  //       ],
  //     );
