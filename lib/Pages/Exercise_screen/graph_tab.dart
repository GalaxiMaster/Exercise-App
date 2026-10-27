import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_models.dart';
import 'package:exercise_app/Pages/Exercise_Screen/exercise_screen_providers.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart' hide chartFilterProvider;
import 'package:exercise_app/Pages/day_screen.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class ExerciseGraphTab extends ConsumerStatefulWidget {
  const ExerciseGraphTab({
    super.key,
    required this.exercises,
    required this.scale,
  });

  final List<String> exercises;
  final ScaleSetting scale;

  @override
  ConsumerState<ExerciseGraphTab> createState() => _ExerciseGraphTabState();
}

class _ExerciseGraphTabState extends ConsumerState<ExerciseGraphTab> {
  /// The point the user last touched
  final ValueNotifier<ChartSelection?> _selection = ValueNotifier(null);

  late final ExerciseKey _key = ExerciseKey(widget.exercises);

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chart = ref.watch(
      exerciseChartProvider(ChartRequest(_key, widget.scale)),
    );

    return chart.when(
      data: (data) => _GraphContent(chart: data, selection: _selection),
      error: (error, stack) => Center(child: Text('Error fetching data: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _GraphContent extends StatelessWidget {
  const _GraphContent({required this.chart, required this.selection});

  final ExerciseChart chart;
  final ValueNotifier<ChartSelection?> selection;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartHeading(chart: chart, selection: selection),
            _ExerciseLineChart(chart: chart, selection: selection),
            if (!chart.bodyweight) const _MetricSelector(),
            const SizedBox(height: 5),
            _ExerciseTiles(chart: chart),
          ],
        ),
      ),
    );
  }
}

class _ChartHeading extends ConsumerWidget {
  const _ChartHeading({required this.chart, required this.selection});

  final ExerciseChart chart;
  final ValueNotifier<ChartSelection?> selection;

  void _openDay(BuildContext context, WidgetRef ref, String date) {
    final keys = dayKeysForDate(
      ref.read(workoutDataProvider).value?.keys ?? const [],
      date,
    );
    if (keys.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => keys.length > 1
            ? DayScreen(date: DateTime.parse(date), dayKeys: keys)
            : IndividualDayScreen(dayKey: keys.first),
      ),
    );
  }

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final entry = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectorPopupMap(options: Options().timeOptions),
    );
    if (!context.mounted || entry == null) return;
    ref.read(chartFilterProvider.notifier).setRange(entry.value, entry.key);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final rangeLabel = ref.watch(chartFilterProvider.select((f) => f.timeLabel));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ValueListenableBuilder<ChartSelection?>(
            valueListenable: selection,
            builder: (context, selected, _) {
              // Falls back to the latest point if nothing is touched, or the touched point is gone
              final point = (selected == null
                      ? null
                      : chart.pointAt(selected.exercise, selected.dayKey)) ??
                  chart.latest;
              final color = point == null
                  ? primary
                  : graphColors[point.colorIndex % graphColors.length];
              final date = point?.stat.dateLabel;
              final parsedDate = date == null ? null : DateTime.tryParse(date);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 12.5,
                      height: 12.5,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                  ),
                  Text(
                    '${(point?.y ?? 0).toStringAsFixed(2)} ${chart.unit}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (date != null)
                    InkWell(
                      onTap: () => _openDay(context, ref, date),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          parsedDate == null
                              ? date
                              : DateFormat('MMM dd yyyy').format(parsedDate),
                          style: TextStyle(color: primary),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          InkWell(
            onTap: () => _pickRange(context, ref),
            child: Row(
              children: [
                Text(rangeLabel, style: TextStyle(color: primary)),
                Icon(Icons.keyboard_arrow_down, color: primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLineChart extends StatelessWidget {
  const _ExerciseLineChart({required this.chart, required this.selection});

  final ExerciseChart chart;
  final ValueNotifier<ChartSelection?> selection;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // One bar per exercise, followed by its best-fit line when it has one.
    // [sources] lines up with [bars]: the exercise a bar belongs to, or null for a best-fit line.
    final bars = <LineChartBarData>[];
    final sources = <ExerciseLine?>[];
    for (final line in chart.lines) {
      final color = graphColors[line.colorIndex % graphColors.length];
      bars.add(LineChartBarData(
        spots: [for (final p in line.points) p.spot],
        color: color,
        barWidth: 3,
        belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.2)),
      ));
      sources.add(line);

      if (line.bestFit.isNotEmpty) {
        bars.add(LineChartBarData(
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          spots: line.bestFit,
          color: color.withRed(255), // a reddish version of the line colour
          barWidth: 2,
          dashArray: [5, 5],
          belowBarData: BarAreaData(show: false),
        ));
        sources.add(null);
      }
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {},
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: bars,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                final touched = response?.lineBarSpots;
                if (touched == null || touched.isEmpty) return;

                final spot = touched.first;
                if (spot.barIndex >= sources.length) return;
                final line = sources[spot.barIndex];
                if (line == null || spot.spotIndex >= line.points.length) return;

                selection.value = (
                  exercise: line.exercise,
                  dayKey: line.points[spot.spotIndex].stat.dayKey,
                );
              },
              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                return [
                  for (final _ in spotIndexes)
                    TouchedSpotIndicatorData(
                      FlLine(color: colors.primary, strokeWidth: 2),
                      const FlDotData(show: true),
                    ),
                ];
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  interval: chart.xInterval,
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    return SideTitleWidget(
                      axisSide: AxisSide.bottom,
                      child: Text(
                        chart.dateLabel(value),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) => Text(value.toInt().toString()),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: colors.onSurface),
            ),
            gridData: const FlGridData(show: true),
          ),
        ),
      ),
    );
  }
}

/// Weight / Volume / Reps / 1rm.
class _MetricSelector extends ConsumerWidget {
  const _MetricSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(chartFilterProvider.select((f) => f.chartTarget));

    return Row(
      children: [
        for (final metric in ChartMetric.values)
          _MetricChip(
            label: metric.label,
            selected: selected == metric.key,
            onTap: () => ref.read(chartFilterProvider.notifier).setTarget(metric.key),
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : HexColor.fromHex('151515'),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// A swipeable card per exercise
class _ExerciseTiles extends StatefulWidget {
  const _ExerciseTiles({required this.chart});

  final ExerciseChart chart;

  @override
  State<_ExerciseTiles> createState() => _ExerciseTilesState();
}

class _ExerciseTilesState extends State<_ExerciseTiles> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.chart.lines;
    if (lines.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _controller,
        itemCount: lines.length,
        itemBuilder: (context, index) =>
            _ExerciseTile(line: lines[index], stats: widget.chart.stats),
      ),
    );
  }
}

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({required this.line, required this.stats});

  final ExerciseLine line;
  final ExerciseStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);
    final weight = stats.heaviestWeight[line.exercise];
    final volume = stats.heaviestVolume[line.exercise];
    final color = graphColors[line.colorIndex % graphColors.length];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getDisplayName(exercises, line.exercise),
                style: const TextStyle(fontSize: 20),
              ),
              const Divider(thickness: .2),
              if (weight != null && volume != null) ...[
                if (line.type == ExerciseType.bodyweight)
                  Text('Highest reps: ${formatNumber(volume.reps)}')
                else ...[
                  Text('Most weight : ${formatNumber(weight.weight)}kg x ${formatNumber(weight.reps)}'),
                  Text('Most volume : ${formatNumber(volume.weight)}kg x ${formatNumber(volume.reps)}'),
                ],
                Text('Increase: ${formatNumber(line.percentChange)}%'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}