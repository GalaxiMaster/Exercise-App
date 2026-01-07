import 'package:exercise_app/Pages/StatScreens/stacked_area_chart.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'radar_chart.dart';

class DataCharts extends ConsumerStatefulWidget{
  Map scaledData;
  Map unscaledData;
  DataCharts({super.key, required this.scaledData, required this.unscaledData});
  @override
  // ignore: library_private_types_in_public_api
  _DataChartsState createState() => _DataChartsState();
}

class _DataChartsState extends ConsumerState<DataCharts> {
  String units = 'Sets';    
  double radius = 125;
  String muscleSelected = 'All Muscles';
  String timeSelected= 'All Time';
  int range = -1;
  @override
  Widget build(BuildContext context) {

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              selectorBox(
                muscleSelected, 
                'muscles', 
                (entry) {
                  setState(() {
                    muscleSelected = entry.key;
                  });
                }, 
                context
              ),
              selectorBox(
                timeSelected, 
                'time', 
                (entry) {
                  setState(() {
                    timeSelected = entry.key;
                    range = entry.value;
                  });
                }, 
              context
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 270,
            child: TimePieChart(),
            // child: PieChart(
            //   PieChartData(
            //     sections: sections,
            //     centerSpaceRadius: 10,
            //     sectionsSpace: 2,
            //     startDegreeOffset: -87,
            //   ),
            // ),
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
                return Column(
                  children: [
                    Padding(
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
                            '${widget.scaledData.keys.toList().reversed.toList()[index]} : ',
                            style: const TextStyle(
                              fontSize: 20
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${widget.unscaledData.values.toList().reversed.toList()[index].toStringAsFixed(1)} $units : ${widget.scaledData.values.toList().reversed.toList()[index]}%',
                            style: const TextStyle(
                              fontSize: 20
                            ),
                          )
                        ]
                      ),
                    ),
                    Divider(
                      thickness: .25,
                      height: 0.2,
                      color: Colors.grey.withValues(alpha: .5),
                    )
                  ],
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
        List data = await getPercentageData(text, -1, ref);
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
            color: selected ? Colors.blue : HexColor.fromHexColor('151515'),
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
  
  
}