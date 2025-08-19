class MoodEntry {
  final String id;
  final DateTime date;
  final int mood;
  final String? note;
  MoodEntry({required this.id, required this.date, required this.mood, this.note});
  factory MoodEntry.fromJson(Map<String,dynamic> j) => MoodEntry(id: j['id'], date: DateTime.parse(j['date']), mood: j['mood'], note: j['note']);
  Map<String,dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'mood': mood, 'note': note};
}
