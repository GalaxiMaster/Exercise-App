import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/encryption_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ConfirmWorkout extends ConsumerStatefulWidget {
  final Map data;
  final bool editing;
  const ConfirmWorkout({
    super.key,
    required this.data,
    required this.editing,
  });
  @override
  ConfirmWorkoutState createState() => ConfirmWorkoutState();
}

class ConfirmWorkoutState extends ConsumerState<ConfirmWorkout> {
  Map quickStats = {};
  Map stats = {};
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  final TextEditingController _workoutNotesController = TextEditingController();


  Map getStats() {
    Map stats = {"Volume": 0, "Sets": 0, "Exercises": 0, "WorkoutTime": ''};

    for (var exercise in widget.data['sets'].keys) {
      stats['Exercises'] += 1;
      for (var set in widget.data['sets'][exercise]) {
        stats['Sets'] += 1;
        stats['Volume'] += (double.parse(set['weight'].toString()).abs() *
                double.parse(set['reps'].toString()))
            .abs();
      }
    }
    Duration difference = endTime.difference(startTime);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    stats['WorkoutTime'] = "${hours}h ${minutes}m";
    return stats;
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      stats = widget.data['stats'] ?? {};
      startTime = DateTime.parse(stats['startTime']);
      endTime = DateTime.tryParse(stats['endTime'] ?? '') ?? endTime;
      _workoutNotesController.text = stats['notes']?['Workout'] ?? '';
    });
  }

  @override
  void dispose() {
    _workoutNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    quickStats = getStats();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Great Work!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Stats Grid
               Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                {'label': 'Volume', 'value': '${quickStats['Volume'].toStringAsFixed(1)}kg', 'icon': Icons.fitness_center, 'color': Colors.blue},
                {'label': 'Sets', 'value': '${quickStats['Sets']}', 'icon': Icons.repeat, 'color': Colors.green},
                {'label': 'Exercises', 'value': '${quickStats['Exercises']}', 'icon': Icons.format_list_numbered, 'color': Colors.orange},
                {'label': 'Duration', 'value': quickStats['WorkoutTime'], 'icon': Icons.timer, 'color': Colors.purple},
              ].map((item) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 42) / 2, // Account for padding and spacing
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['label'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8 ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['value'] as String,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Time Section
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DateTimePickerDialog(
                        initialFromTime: TimeOfDay(hour: startTime.hour, minute: startTime.minute),
                        initialFromDate: startTime,
                        initialToTime: TimeOfDay(hour: endTime.hour, minute: endTime.minute),
                        initialToDate: endTime,
                      );
                    },
                  );
                  if (result != null) {
                    setState(() {
                      startTime = combineDateAndTime(result['fromDate'], result['fromTime']);
                      endTime = combineDateAndTime(result['toDate'], result['toTime']);
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout Time',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_outlined, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4), size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exercise Breakdown
            // TODO: Make this expandable to show full details
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Exercises', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.data['sets'].keys.map((exercise) {
                      final exerciseSets = widget.data['sets'][exercise] as List;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(exercise, style: theme.textTheme.bodySmall)),
                            Text(
                              '${exerciseSets.length} sets',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes Section
            Text('Notes', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _workoutNotesController,
              decoration: InputDecoration(
                hintText: 'How did it go?',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
                isDense: true,
              ),
              minLines: 1,
              maxLines: 2,
              onChanged: (value) {
                stats['notes']['Workout'] = value;
              },
            ),
            const SizedBox(height: 20),
            // maybe
            // TODO: Add workout rating (1-5 stars)
            // TODO: Add feeling/energy level selector

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  saveExercises(widget.data, startTime, endTime).then((res){
                    if (res != null && context.mounted) {
                      Navigator.pop(context, res);
                      Navigator.pop(context, res);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Save Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Discard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<dynamic, dynamic>?> saveExercises(Map exerciseList, DateTime startTime, DateTime endTime) async {
    String day = DateFormat('yyyy-MM-dd').format(startTime);
    String startTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(startTime);
    String endTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(endTime);

    Map allData = await ref.read(workoutDataProvider.future);
    int num = 1;
    for (int i = 0; i < allData.keys.length; i++) {
      if (allData.keys.toList()[i]?.split(' ')[0] == day) {
        num++;
      }
    }
    Map<String, dynamic> combinedStats = {
      ...stats, // Spread existing values into a NEW map
      'startTime': startTimeStr,
      'endTime': endTimeStr,
    };
    Map<String, dynamic> data = {
      'stats': combinedStats,
      'sets': exerciseList['sets']
    };
    if (!widget.editing) {
      ref.read(recordsProvider.notifier).writeNewRecords(data['sets']);
      ref.read(workoutDataProvider.notifier).updateValue('$day $num', data);
      syncData(); // TODO make simpler
      ref.read(currentWorkoutProvider.notifier).writeState(<String, dynamic>{});
    }
    return data;
  }
}

class DateTimePickerDialog extends StatefulWidget {
  final DateTime? initialFromDate;
  final TimeOfDay? initialFromTime;
  final DateTime? initialToDate;
  final TimeOfDay? initialToTime;

  const DateTimePickerDialog({
    super.key,
    this.initialFromDate,
    this.initialFromTime,
    this.initialToDate,
    this.initialToTime,
  });

  @override
  DateTimePickerDialogState createState() => DateTimePickerDialogState();
}

class DateTimePickerDialogState extends State<DateTimePickerDialog> {
  DateTime? fromDate;
  TimeOfDay? fromTime;
  DateTime? toDate;
  TimeOfDay? toTime;

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialFromDate ?? DateTime.now();
    fromTime = widget.initialFromTime ?? TimeOfDay.now();
    toDate = widget.initialToDate ?? DateTime.now();
    toTime = widget.initialToTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Workout Time', style: TextStyle(fontSize: 18)),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeSection(
            context: context,
            theme: theme,
            label: 'Start',
            date: fromDate,
            time: fromTime,
            onDateSelected: (date) => setState(() => fromDate = date),
            onTimeSelected: (time) => setState(() => fromTime = time),
          ),
          const SizedBox(height: 16),
          _buildTimeSection(
            context: context,
            theme: theme,
            label: 'End',
            date: toDate,
            time: toTime,
            onDateSelected: (date) => setState(() => toDate = date),
            onTimeSelected: (time) => setState(() => toTime = time),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop({
              'fromDate': fromDate,
              'fromTime': fromTime,
              'toDate': toDate,
              'toTime': toTime,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTimeSection({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required Function(DateTime) onDateSelected,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    onDateSelected(selectedDate);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                label: Text(
                  date != null ? DateFormat('MMM d').format(date) : 'Date',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.access_time, size: 16),
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    onTimeSelected(selectedTime);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                label: Text(
                  time != null ? time.format(context) : 'Time',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}