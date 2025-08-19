import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../services/file_storage.dart';

final moodControllerProvider = StateNotifierProvider<MoodController, List<MoodEntry>>((ref) => MoodController());

class MoodController extends StateNotifier<List<MoodEntry>> {
  MoodController() : super([]) { _load(); }
  static const _file = 'mood_log.json';
  String _id() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString();
  Future<void> _load() async { final items = await FileStorage.readItems(_file); state = items.map((e) => MoodEntry.fromJson(e)).toList(); }
  Future<void> _persist() async { await FileStorage.writeItems(_file, state.map((e) => e.toJson()).toList()); }
  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> addOrUpdateMood(int mood, {String? note}) async {
    final today = _stripTime(DateTime.now());
    final idx = state.indexWhere((m) => _stripTime(m.date) == today);
    if (idx >= 0) {
      final updated = MoodEntry(id: state[idx].id, date: today, mood: mood, note: note ?? state[idx].note);
      state = [...state]..[idx] = updated;
    } else {
      state = [...state, MoodEntry(id: _id(), date: today, mood: mood, note: note)];
    }
    await _persist();
  }

  double sevenDayAverage() {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 6));
    final items = state.where((m) => _stripTime(m.date).isAfter(_stripTime(from).subtract(const Duration(seconds:1))));
    if (items.isEmpty) return 0;
    final avg = items.map((e)=>e.mood).reduce((a,b)=>a+b) / items.length;
    return double.parse(avg.toStringAsFixed(2));
  }

  int currentStreak() {
    if (state.isEmpty) return 0;
    final dates = state.map((e) => _stripTime(e.date)).toSet();
    int streak = 0;
    DateTime day = _stripTime(DateTime.now());
    while (dates.contains(day)) { streak += 1; day = day.subtract(const Duration(days:1)); }
    return streak;
  }

  List<MoodEntry> lastNDays(int n) {
    final cut = _stripTime(DateTime.now().subtract(Duration(days: n-1)));
    final list = state.where((m)=>_stripTime(m.date).isAfter(cut.subtract(const Duration(seconds:1)))).toList()..sort((a,b)=>a.date.compareTo(b.date));
    return list;
  }
}
