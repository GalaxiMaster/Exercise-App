import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DataCharts extends StatefulWidget{
  final List exerciseData;
  const DataCharts({super.key, required this.exerciseData});
  // ignore: library_private_types_in_public_api
  @override
  // ignore: library_private_types_in_public_api
  _DataChartsState createState() => _DataChartsState();
}

class _DataChartsState extends State<DataCharts> {
  @override
  Widget build(BuildContext context) {
    Map scaledData = widget.exerciseData[0];
    Map unscaledData = widget.exerciseData[1];
    double radius = 125;

    List<PieChartSectionData> sections = scaledData.entries.map((entry) {
      return PieChartSectionData(
        color: getColor(entry.key),
        value: entry.value,
        title: entry.value > 5 ? '${entry.key}\n${entry.value}%' : '',
        radius: radius,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 270,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 10,
                sectionsSpace: 2,
                startDegreeOffset: -87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1, color: Colors.grey, height: 1,),          
          Flexible(
            child: ListView.builder(
              itemCount: scaledData.keys.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 12.5,
                          height: 12.5,
                          decoration: BoxDecoration(
                            color: getColor(scaledData.keys.toList().reversed.toList()[index]),
                            border: Border.all(color: Colors.black)
                          ),
                        ),
                      ),
                      Text(
                        '${scaledData.keys.toList().reversed.toList()[index]} : ${unscaledData.values.toList().reversed.toList()[index].toStringAsFixed(1)} sets : ${scaledData.values.toList().reversed.toList()[index]}%',
                        style: const TextStyle(
                          fontSize: 20
                        ),
                      )
                    ]
                  ),
                );
              }
            ),
          )
        ]
      ),
    );
  }
  
  
  
  Color getColor(String key) {
    var colors = {
      'Pectorals': Colors.red,
      'Triceps': Colors.orange,
      'Biceps': Colors.pink,
      'Deltoids': Colors.blue,
      'Front Delts': Colors.lightBlue,
      'Side Delts': Colors.cyan,
      'Rear Delts': Colors.teal,
      'Forearms': Colors.purple,
      'Lats': Colors.indigo,
      'Rhomboids': Colors.green,
      'Lower Back': Colors.brown,
      'Glutes': Colors.deepOrange,
      'Quads': Colors.yellow,
      'Hamstrings': Colors.amber,
      'Calves': Colors.lightGreen,
      'Abs': Colors.lightBlueAccent,
      'Obliques': Colors.blueGrey,
    };

    return colors[key] ?? Colors.grey;
  }
}