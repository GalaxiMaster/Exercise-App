import 'package:exercise_app/Pages/Social_Pages/exercise_detail_compare_page.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ComparePage extends ConsumerStatefulWidget {
  final String friendId;
  const ComparePage({super.key, required this.friendId});
  @override
  ComparePageState createState() => ComparePageState();
}

class ComparePageState extends ConsumerState<ComparePage> {
  String _query = '';
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

    final comparisonData = ref.watch(comparisonProvider(widget.friendId));

    final searchData = Map.from(comparisonData)..removeWhere((key, value) => !key.contains(_query)); // temporary
    
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(
               child: selectorBox(
                  ref.watch(compareChartFilterProvider).timeFilter.label, 
                  TimeFilter.values,
                  (entry) => ref.read(compareChartFilterProvider.notifier).setTime(entry), 
                  context,
                  width: MediaQuery.of(context).size.width
                ),
             ),
            versusSection(40, myProfile, friendProfile),
            SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Muscle Splits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )
              ),
            ),
            Center( // todo make the placeholder a radarChartWidget with empty values so nothing is moving around after entry
              child: switch ((theirs, mine)) { // a very interesting way to do it
                (AsyncData(value: final a), AsyncData(value: final b)) =>
                    radarChartWidget([a.first, b.first]),
                (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
                    Text(error.toString()),
                _ => const CircularProgressIndicator(),
              }
            ),
            SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Common Exercises',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 24),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.search, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v.toLowerCase()),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withAlpha(200)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4,),
            ListView.builder(
              shrinkWrap: true,
              itemCount: searchData.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final String exerciseKey = searchData.keys.toList().elementAt(index);
                final item = searchData[exerciseKey];
                final Exercise? exercise = ref.read(exercisesProvider)[exerciseKey];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExerciseComparisonPage(friendId: widget.friendId, stats: item!,))
                  ),
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Image.asset(
                            "assets/Exercises/${exercise?.id}.png",
                            height: 50,
                            width: 50,
                            cacheWidth: 100,
                            cacheHeight: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  "assets/profile.svg",
                                  height: 35,
                                  width: 35,
                                ),
                              );
                            },
                          )
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exercise?.name ?? exerciseKey),
                              Text(exercise?.primary.keys.toList().join(', ') ?? '')
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20,)
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ), // Placeholder data
    );
  }
}

// widgets
Row versusSection(double radius, ExerciseUser? myProfile, ExerciseUser? friendProfile) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 30,
    children: [
      if (myProfile != null) // todo add loading placeholders
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
              backgroundImage: myProfile.photoUrl != null ? NetworkImage(myProfile.photoUrl!) : null,
            ),
          ),
          Text(myProfile.displayName)
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
      if (friendProfile != null)
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundImage: friendProfile.photoUrl != null ? NetworkImage(friendProfile.photoUrl!) : null, 
              radius: radius,
            ),
          ),
          Text(friendProfile.displayName)
        ],
      )
    ],
  );
}

// providers
final compareChartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});

