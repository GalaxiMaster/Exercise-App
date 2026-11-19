import 'package:exercise_app/Pages/Exercise_screen/exercise_screen.dart';
import 'package:exercise_app/Pages/Social_Pages/compare_page.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

const _myBarColor = Color(0xFF0A84FF);
const _friendBarColor = Color(0xFF2C2C2E);
const _upColor = Color(0xFF30D158);
const _downColor = Color(0xFFFF453A);

class ExerciseComparisonPage extends ConsumerWidget {
  final String friendId;
  final Exercise? exercise;
  final UserFriendVals<ExerciseStats> stats;
  const ExerciseComparisonPage({
    super.key,
    required this.friendId,
    required this.stats, 
    required this.exercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendProfile = ref.watch(userProfileProvider(friendId)).value;
    final myProfile = ref.watch(myProfileProvider).value;

    final me = stats.userVal;
    final friend = stats.friendVal;

    return Scaffold(
      appBar: myAppBar(context, 'Exercise Comparison'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            versusSection(40, myProfile, friendProfile),
            const SizedBox(height: 16),
            if (exercise != null)
            ExerciseSection(exercise: exercise!,),
            const Text(
              'Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (me.best1RMWeight != null && me.best1RMWeight != 0.0) ...[
              ComparisonMetric(
                title: 'One Rep Max',
                myValue: me.best1RM ?? 0,
                friendValue: friend.best1RM ?? 0,
                myPhotoUrl: myProfile?.photoUrl,
                friendPhotoUrl: friendProfile?.photoUrl,
                friendInitial: _initial(friendProfile?.displayName),
              ),
              const SizedBox(height: 20),
            ],
            ComparisonMetric(
              title: 'Heaviest Weight',
              myValue: me.bestWeight,
              friendValue: friend.bestWeight,
              myPhotoUrl: myProfile?.photoUrl,
              friendPhotoUrl: friendProfile?.photoUrl,
              friendInitial: _initial(friendProfile?.displayName),
            ),
            const SizedBox(height: 20),
            ComparisonMetric(
              title: 'Best Set (Volume)',
              myValue: me.bestSetVolume,
              friendValue: friend.bestSetVolume,
              myPhotoUrl: myProfile?.photoUrl,
              friendPhotoUrl: friendProfile?.photoUrl,
              friendInitial: _initial(friendProfile?.displayName),
            ),
          ],
        ),
      ),
    );
  }

  static String _initial(String? name) =>
      (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?';
}

/// One metric block: title + % difference, then two proportional bars.
class ComparisonMetric extends StatelessWidget {
  final String title;
  final double myValue;
  final double friendValue;
  final String? myPhotoUrl;
  final String? friendPhotoUrl;
  final String friendInitial;
  final String unit;

  const ComparisonMetric({
    super.key,
    required this.title,
    required this.myValue,
    required this.friendValue,
    required this.friendInitial,
    this.myPhotoUrl,
    this.friendPhotoUrl,
    this.unit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [myValue, friendValue].reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            _DiffBadge(myValue: myValue, friendValue: friendValue),
          ],
        ),
        const SizedBox(height: 8),
        _BarRow(
          value: myValue,
          maxValue: maxValue,
          unit: unit,
          barColor: _friendBarColor,
          avatar: _Avatar(photoUrl: myPhotoUrl, fallbackLetter: 'Me'),
        ),
        const SizedBox(height: 6),
        _BarRow(
          value: friendValue,
          maxValue: maxValue,
          unit: unit,
          barColor: _myBarColor,
          avatar: _Avatar(photoUrl: friendPhotoUrl, fallbackLetter: friendInitial),
        ),
      ],
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final double myValue;
  final double friendValue;
  const _DiffBadge({required this.myValue, required this.friendValue});

  @override
  Widget build(BuildContext context) {
    if (friendValue == 0) return const SizedBox.shrink();
    final pct = ((myValue - friendValue) / friendValue * 100).round();
    if (pct == 0) return const SizedBox.shrink();

    final isUp = pct > 0;
    final color = isUp ? _upColor : _downColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '${pct.abs()}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final double value;
  final double maxValue;
  final String unit;
  final Color barColor;
  final Widget avatar;

  const _BarRow({
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.barColor,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$unit';

    return Row(
      children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fraction = (value / maxValue).abs().clamp(0.0, 1.0);
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // Filled bar (animates when values change)
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: 12,
                        width: constraints.maxWidth * fraction - 50,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          label,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String fallbackLetter;
  const _Avatar({this.photoUrl, required this.fallbackLetter});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 10,
      backgroundColor: Colors.blueGrey.shade400,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: hasPhoto
          ? null
          : Text(
              fallbackLetter.length > 1 ? fallbackLetter[0] : fallbackLetter,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
    );
  }
}

class ExerciseSection extends StatelessWidget {
  final Exercise exercise;
  const ExerciseSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Exercise',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExerciseScreen(exercises: [exercise.id]))
          ),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    "assets/Exercises/${exercise.id}.png",
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
                      Text(exercise.name),
                      Text(exercise.primary.keys.toList().join(', '))
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
