import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_models.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_providers.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart'; // graphColors, getDisplayName
import 'package:exercise_app/widgets.dart'; // DecimalMultiplierField
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns the chosen scale, or null if cancelled.
Future<ScaleSetting?> showChartSettingsDialog(
  BuildContext context, {
  required ExerciseKey exercises,
  required ScaleSetting scale,
}) {
  return showDialog<ScaleSetting>(
    context: context,
    builder: (context) => ChartSettingsDialog(exercises: exercises, scale: scale),
  );
}

class ChartSettingsDialog extends ConsumerStatefulWidget {
  const ChartSettingsDialog({
    super.key,
    required this.exercises,
    required this.scale,
  });

  final ExerciseKey exercises;
  final ScaleSetting scale;

  @override
  ConsumerState<ChartSettingsDialog> createState() => _ChartSettingsDialogState();
}

class _ChartSettingsDialogState extends ConsumerState<ChartSettingsDialog> {
  late ScaleSetting _scale = widget.scale;


  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String exercise, String initial) =>
      _controllers.putIfAbsent(exercise, () => TextEditingController(text: initial));

  void _save(Object? savedMultipliers) {
    if (_controllers.isNotEmpty) {
      final merged = <String, String>{
        if (savedMultipliers is Map)
          for (final e in savedMultipliers.entries) e.key.toString(): e.value.toString(),
        for (final e in _controllers.entries) e.key: e.value.text,
      };
      ref.read(settingsProvider.notifier).updateValue('Multipliers', merged);
    }
    Navigator.pop(context, _scale);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value;
    final stats = ref.watch(exerciseStatsProvider(widget.exercises));
    final exercises = ref.watch(exercisesProvider);
    final saved = settings?['Multipliers'];
    final ids = stats.value?.exerciseIds ?? const <String>[];

    return AlertDialog(
      title: const Text('Select Scale Setting'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SegmentedButton<ScaleSetting>(
                segments: const [
                  ButtonSegment(
                    value: ScaleSetting.equalIntervals,
                    label: Text('Equal Intervals'),
                    icon: Icon(Icons.equalizer),
                  ),
                  ButtonSegment(
                    value: ScaleSetting.scaled,
                    label: Text('Time scaled'),
                    icon: Icon(Icons.scale),
                  ),
                ],
                selected: {_scale},
                onSelectionChanged: (s) => setState(() => _scale = s.first),
              ),
            ),
            if (settings == null || !stats.hasValue)
              const CircularProgressIndicator()
            else
              SizedBox(
                height: ids.length * 50.0,
                width: 300,
                child: ListView.builder(
                  itemCount: ids.length,
                  itemBuilder: (context, index) {
                    final exercise = ids[index];
                    final current = saved is Map ? saved[exercise]?.toString() : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              getDisplayName(exercises, exercise),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DecimalMultiplierField(
                            controller: _controllerFor(exercise, current ?? '1.0'),
                            borderColor: graphColors[index % graphColors.length],
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _save(saved),
          child: const Text('Save'),
        ),
      ],
    );
  }
}