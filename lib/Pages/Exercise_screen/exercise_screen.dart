import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_models.dart';
import 'package:exercise_app/Pages/Exercise_screen/graph_tab.dart';
import 'package:exercise_app/Pages/Exercise_screen/history_tab.dart';
import 'package:exercise_app/Pages/Exercise_screen/info_tab.dart';
import 'package:exercise_app/Pages/Exercise_screen/chart_settings_dialog.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/utils.dart'; // getDisplayName
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TabItem {
  graph,
  history,
  info,
}

/// One or more exercises: a graph of progress, past workouts, and the muscles worked.
class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key, required this.exercises});

  final List<String> exercises;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  final PageController _pageController = PageController();
  TabItem _tab = TabItem.graph;
  ScaleSetting _scale = ScaleSetting.equalIntervals;

  /// True while a tap on the bottom bar animates to another tab, so the pages passed on the way don't each select themselves.
  bool _animating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index, {bool fromTap = false}) {
    if (_tab.index == index) return;

    setState(() => _tab = TabItem.values[index]);

    if (fromTap) {
      _animating = true;
      _pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          )
          .then((_) => _animating = false);
    }
  }

  Future<void> _openSettings() async {
    final result = await showChartSettingsDialog(
      context,
      exercises: ExerciseKey(widget.exercises),
      scale: _scale,
    );
    if (!mounted || result == null) return;
    setState(() => _scale = result);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exercises.length == 1
              ? getDisplayName(exercises, widget.exercises.first)
              : 'Exercises Data',
        ),
        actions: [
          if (_tab == TabItem.graph)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Chart settings',
              onPressed: _openSettings,
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (_animating) return;
          _selectTab(index);
        },
        children: [
          ExerciseGraphTab(exercises: widget.exercises, scale: _scale),
          ExerciseHistoryTab(exercises: widget.exercises),
          ExerciseInfoTab(exercises: widget.exercises),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab.index,
        onTap: (index) => _selectTab(index, fromTap: true),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Graph'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
    );
  }
}