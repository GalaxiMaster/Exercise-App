import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DataCharts extends StatefulWidget{
  Map scaledData;
  Map unscaledData;
  DataCharts({super.key, required this.scaledData, required this.unscaledData});
  // ignore: library_private_types_in_public_api
  @override
  // ignore: library_private_types_in_public_api
  _DataChartsState createState() => _DataChartsState();
}

class _DataChartsState extends State<DataCharts> {
  String units = 'Sets';
  @override
  Widget build(BuildContext context) {

    double radius = 125;

    List<PieChartSectionData> sections = widget.scaledData.entries.map((entry) {
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
          Row(
            children: [
              SelectorBox('Sets', units == 'Sets'),
              SelectorBox('Volume', units == 'kg'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1, color: Colors.grey, height: 1,),          
          Flexible(
            child: ListView.builder(
              itemCount: widget.scaledData.keys.length,
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
                            color: getColor(widget.scaledData.keys.toList().reversed.toList()[index]),
                            border: Border.all(color: Colors.black)
                          ),
                        ),
                      ),
                      Text(
                        '${widget.scaledData.keys.toList().reversed.toList()[index]} : ${widget.unscaledData.values.toList().reversed.toList()[index].toStringAsFixed(1)} $units : ${widget.scaledData.values.toList().reversed.toList()[index]}%',
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
  
  // ignore: non_constant_identifier_names
  Widget SelectorBox(String text, bool selected){
    return GestureDetector(
      onTap: () async{
        List data = await getStuff(text);
        setState(() {
          switch(text){
            case 'Sets':units = 'Sets';
            case 'Volume': units = 'kg';
          }
          widget.scaledData = data[0];
          widget.unscaledData = data[1];
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(
              text
            ),
          ),
        ),
      ),
    );
  }
  
  Future<List> getStuff(String target) async {
    Map muscleData = {};
    Map data = await readData();
    for (var day in data.keys){
      for (var exercise in data[day]['sets'].keys){
        if (exerciseMuscles.containsKey(exercise)){
          for (var set in data[day]['sets'][exercise]){
            double selector = 0;
            switch(target){
              case 'Volume': selector = double.parse(set['weight'])*double.parse(set['reps']);
              case 'Sets' : selector = 1;
            }
            for (var muscle in exerciseMuscles[exercise]!['Primary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseMuscles[exercise]!['Primary']![muscle]!/100);
              } else{
                muscleData[muscle] = selector*(exerciseMuscles[exercise]!['Primary']![muscle]!/100);
              }
            }
            for (var muscle in exerciseMuscles[exercise]!['Secondary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
              } else{
                muscleData[muscle] = selector*(exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
              }
            }
          }
        } else{
          debugPrint('Unknown exercise: $exercise');
        }
      }
    }
    debugPrint(muscleData.toString());
    // Scale results to 100
    double total = muscleData.values.fold(0.0, (p, c) => p + c);
    debugPrint(total.toString());
    Map scaledMuscleData = {};
    for (String muscle in muscleData.keys){
      scaledMuscleData[muscle] = ((muscleData[muscle] / total * 100.0) * 100).roundToDouble() / 100;
    }
    List<MapEntry> entries = muscleData.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    muscleData = Map.fromEntries(entries);
    debugPrint(muscleData.toString());
    entries = scaledMuscleData.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    scaledMuscleData = Map.fromEntries(entries);
    debugPrint(scaledMuscleData.toString());
    return [scaledMuscleData, muscleData].toList();
  }
}