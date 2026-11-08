import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparePage extends ConsumerStatefulWidget {
  final String friendId;
  const ComparePage({super.key, required this.friendId});
  @override
  ComparePageState createState() => ComparePageState();
}

class ComparePageState extends ConsumerState<ComparePage> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(compareChartFilterProvider);
    final mine = ref.watch(radarModelProvider(
      RadarParams(userId: '', filters: filters)
    ));
    final theirs = ref.watch(radarModelProvider(
      RadarParams(userId: widget.friendId, filters: filters)
    ));

    final friendProfile = ref.watch(userProfileProvider(widget.friendId)).value;
    final myProfile = ref.watch(myProfileProvider).value;

    // final comparisonData = ref.watch(comparisonProvider(widget.friendId));
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: Column(
        children: [
           selectorBox(
            ref.watch(compareChartFilterProvider).timeFilter.label, 
            TimeFilter.values,
            (entry) => ref.read(compareChartFilterProvider.notifier).setTime(entry), 
            context
          ),
          versusSection(40, myProfile, friendProfile),
          Center(
            child: switch ((theirs, mine)) { // a very interesting way to do it
              (AsyncData(value: final a), AsyncData(value: final b)) =>
                  radarChartWidget([a.first, b.first]),
              (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
                  Text(error.toString()),
              _ => const CircularProgressIndicator(),
            }
          ),
        ],
      ), // Placeholder data
    );
  }

  Row versusSection(double radius, Map<String, dynamic>? myProfile, Map<String, dynamic>? friendProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 30,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: radius - 2,
                backgroundImage: myProfile?['photoUrl'] != null ? NetworkImage(myProfile!['photoUrl']) : null,
              ),
            ),
            Text(myProfile?['displayName'] ?? myProfile?['username'])
          ],
        ),
        Container(
          height: radius,
          width: radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withAlpha(225),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha(200),
                blurRadius: 15
              )
            ]
          ),
          child: Center(child: Text('Vs')),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundImage: friendProfile?['photoUrl'] != null ? NetworkImage(friendProfile!['photoUrl']) : null, 
                radius: radius,
              ),
            ),
            Text(friendProfile?['displayName'] ?? friendProfile?['username'])
          ],
        )
      ],
    );
  }
}


final compareChartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});