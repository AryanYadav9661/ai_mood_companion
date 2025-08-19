import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/mood_controller.dart';
import '../widgets/mood_picker.dart';
import '../widgets/confetti_widget.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = ref.watch(moodControllerProvider);
    final ctrl = ref.read(moodControllerProvider.notifier);
    final avg = ctrl.sevenDayAverage();
    final streak = ctrl.currentStreak();
    final last30 = ctrl.lastNDays(30);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('How are you feeling today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              MoodPicker(onChanged: (v) async { await ctrl.addOrUpdateMood(v); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood saved ✅'))); }),
              const SizedBox(height: 12),
              Wrap(spacing: 16, children: [
                Chip(label: Text('7-day avg: ${avg == 0 ? '—' : avg.toString()}')),
                Chip(label: Text('Current streak: $streak days')),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        if ([7,30,100].contains(streak)) StreakConfetti(streak: streak),
        Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mood Trend (Last 30 days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: 1, maxY: 5,
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= last30.length) return const SizedBox.shrink();
                        final d = last30[idx].date;
                        return Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10));
                      }))
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(isCurved: true, barWidth: 3, dotData: const FlDotData(show: false), spots: [
                        for (var i = 0; i < last30.length; i++) FlSpot(i.toDouble(), last30[i].mood.toDouble())
                      ]),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Recent moods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...moods.reversed.take(14).map((m)=>ListTile(leading: Text('😀🙂😐🙁😞'[m.mood-1]), title: Text('Mood: \${m.mood}/5'), subtitle: Text(m.date.toLocal().toString().split('.').first))),
        const SizedBox(height: 80),
      ],
    );
  }
}
