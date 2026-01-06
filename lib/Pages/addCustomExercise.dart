import 'dart:async';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCustomExercise extends ConsumerStatefulWidget {
  const AddCustomExercise({super.key});

  @override
  ConsumerState<AddCustomExercise> createState() => _AddCustomExerciseState();
}

class _AddCustomExerciseState extends ConsumerState<AddCustomExercise> with TickerProviderStateMixin{
  final TextEditingController _exerciseNameController = TextEditingController();

  late final List<String> _muscleGroupsAvailable;
  final Map<String, int?> _selectedMuscleGroups = {};
  final Map<String, TextEditingController> _percentageControllers = {};
  int percentageRemaining = 100;
  String selectedExerciseType = '';

  Timer? _holdTimer;
  static const int _step = 5;
  static const Duration _holdInterval = Duration(milliseconds: 120);

  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _muscleGroupsAvailable = muscleGroups.values.expand((e) => e).toList();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 125),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _exerciseNameController.dispose();
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isFormValid {
    if (_exerciseNameController.text.trim().isEmpty) return false;
    if (_selectedMuscleGroups.isEmpty) return false;
    if (selectedExerciseType.isEmpty) return false;
    if (_selectedMuscleGroups.values.any((v) => v == null || v <= 0)) {
      return false;
    }

    final double total = _selectedMuscleGroups.values.fold(0, (sum, v) => sum + v!);

    return total == 100;
  }

  void _updateValue(String key, int delta) {
    final controller = _percentageControllers[key]!;
    final current = int.tryParse(controller.text) ?? 0;
    final newValue = (current + delta).clamp(0, 100);

    if (percentageRemaining > 0 || delta < 0){
      setState(() {
        controller.text = newValue.toString();
        _selectedMuscleGroups[key] = newValue;
      });
      percentageRemaining -= delta;
    }
  }

  void _startHold(String key, int delta) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(_holdInterval, (_) {
      _updateValue(key, delta);
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _handleSubmit() {
    Map<String, Map<String, num>> toPrimarySecondary(
      Map<String, num> muscles, {
      num topCutoff = 10, // muscles within this value of the top are primary
    }) {
      if (muscles.isEmpty) return {'Primary': {}, 'Secondary': {}};

      final sorted = muscles.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final result = {
        'Primary': <String, num>{},
        'Secondary': <String, num>{},
      };

      final topValue = sorted.first.value;

      for (final entry in sorted) {
        if (topValue - entry.value <= topCutoff) {
          result['Primary']![entry.key] = entry.value;
        } else {
          result['Secondary']![entry.key] = entry.value;
        }
      }

      return result;
    }



    final String exerciseName = _exerciseNameController.text.trim();
    final Map<String, int> muscleGroups = _selectedMuscleGroups.map((k, v) => MapEntry(k, v!));

    writeKey(
      exerciseName, 
      {
        ...toPrimarySecondary(muscleGroups), 
        'type': selectedExerciseType,
        'tags': ['custom']
      },
      path: 'customExercises'
    );
    ref.invalidate(customExercisesProvider);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Custom Exercise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _buildExerciseNameField(),
            _buildExerciseTypeSelection(),
            _buildMuscleGroupHeader(),
            _buildSelectedMuscleGroups(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isFormValid ? _handleSubmit : null,
            child: const Text('Submit Exercise'),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercise Name',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _exerciseNameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: 'Enter exercise name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
  Widget _buildExerciseTypeSelection() {
    List exerciseTypes = ['Weighted', 'Banded', 'Bodyweight'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exercise type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 55,
          child: Row(
            children: List.generate(exerciseTypes.length, (index) {
              final isSelected = selectedExerciseType == exerciseTypes[index];
              return Expanded(
                child: AnimatedBuilder(
                  animation: _borderController,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: isSelected
                          ? AnimatedBorderPainter(_borderController.value)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: GestureDetector(
                          onTap: () {
                            if (!isSelected) {
                              _borderController.forward(from: 0);
                            } else {
                              if (selectedExerciseType == exerciseTypes[index]) return;
                              _borderController.reverse();
                            }
                            setState(() => selectedExerciseType = exerciseTypes[index]);
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 1.05 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [BoxShadow(blurRadius: 10, color: Colors.black12)]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  exerciseTypes[index],
                                  style: TextStyle(
                                    color:Colors.white,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleGroupHeader() {
    return Row(
      children: [
        const Text(
          'Muscle Groups',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () async {
            final String? selected = await showModalBottomSheet<String>(
              context: context,
              builder: (_) => SelectorPopupList(
                options: _muscleGroupsAvailable,
              ),
            );

            if (selected != null && !_selectedMuscleGroups.containsKey(selected)) {
              setState(() {
                _selectedMuscleGroups[selected] = percentageRemaining;
                _percentageControllers[selected] = TextEditingController(text: percentageRemaining.toString());
                percentageRemaining = 0;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectedMuscleGroups() {
    if (_selectedMuscleGroups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No muscle groups selected.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: _selectedMuscleGroups.keys.map((key) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    key,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                GestureDetector(
                  onTap: () => _updateValue(key, -_step),
                  onLongPressStart: (_) => _startHold(key, -_step),
                  onLongPressEnd: (_) => _stopHold(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                ),

                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _percentageControllers[key],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: '%',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      setState(() {
                        _selectedMuscleGroups[key] = parsed;
                      });
                    },
                  ),
                ),

                GestureDetector(
                  onTap: () => _updateValue(key, _step),
                  onLongPressStart: (_) => _startHold(key, _step),
                  onLongPressEnd: (_) => _stopHold(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: const Icon(Icons.arrow_forward_ios),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _percentageControllers[key]?.dispose();
                      _percentageControllers.remove(key);
                      _selectedMuscleGroups.remove(key);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AnimatedBorderPainter extends CustomPainter {
  final double progress;

  AnimatedBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRRect(RRect.fromRectAndRadius(
      rect, const Radius.circular(12)));

    final metric = path.computeMetrics().first;
    final animatedPath =
        metric.extractPath(0, metric.length * progress);

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
