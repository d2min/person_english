int calculateStudyStreak(Set<String> studyDays, {DateTime? now}) {
  if (studyDays.isEmpty) return 0;
  final today = _dateKey(now ?? DateTime.now());
  final sortedDays = studyDays.toList()..sort((a, b) => b.compareTo(a));
  final latest = _parseDate(sortedDays.first);
  final currentDate = _parseDate(today);
  if (currentDate.difference(latest).inDays > 1) return 0;

  var streak = 1;
  var previous = latest;
  for (final dayKey in sortedDays.skip(1)) {
    final day = _parseDate(dayKey);
    if (previous.difference(day).inDays > 2) break;
    streak++;
    previous = day;
  }
  return streak;
}

String studyDateKey(DateTime date) => _dateKey(date);

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime _parseDate(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}
