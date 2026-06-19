import '../../../core/database/app_database.dart';
import '../../diary/domain/mood.dart';

/// 心情分布：各心情对应的日记篇数（忽略未标记心情的条目）。
Map<Mood, int> moodDistribution(List<DiaryEntry> entries) {
  final counts = <Mood, int>{};
  for (final e in entries) {
    final mood = Mood.fromId(e.mood);
    if (mood == null) continue;
    counts[mood] = (counts[mood] ?? 0) + 1;
  }
  return counts;
}

/// 某月的心情统计：篇数 + 主导心情（当月出现最多的心情）。
class MonthlyMoodStat {
  const MonthlyMoodStat({
    required this.month,
    required this.count,
    required this.dominantMood,
  });

  /// 当月 1 号。
  final DateTime month;
  final int count;
  final Mood? dominantMood;
}

/// 最近 [months] 个月（含本月）的每月统计，按时间升序。
List<MonthlyMoodStat> monthlyMoodStats(
  List<DiaryEntry> entries, {
  required DateTime now,
  int months = 6,
}) {
  final firstMonth = DateTime(now.year, now.month - (months - 1));
  final buckets = <DateTime, List<DiaryEntry>>{};
  for (var i = 0; i < months; i++) {
    buckets[DateTime(firstMonth.year, firstMonth.month + i)] = [];
  }
  for (final e in entries) {
    final m = DateTime(e.createdAt.year, e.createdAt.month);
    buckets[m]?.add(e);
  }

  final result = <MonthlyMoodStat>[];
  for (var i = 0; i < months; i++) {
    final m = DateTime(firstMonth.year, firstMonth.month + i);
    final list = buckets[m]!;
    final dist = moodDistribution(list);
    Mood? dominant;
    var max = 0;
    for (final entry in dist.entries) {
      if (entry.value > max) {
        max = entry.value;
        dominant = entry.key;
      }
    }
    result.add(
      MonthlyMoodStat(month: m, count: list.length, dominantMood: dominant),
    );
  }
  return result;
}
