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

/// 某天的心情统计：篇数 + 主导心情 + 心情指数。
class DayMoodStat {
  const DayMoodStat({
    required this.date,
    required this.count,
    required this.dominantMood,
    required this.score,
  });

  /// 当日 00:00。
  final DateTime date;
  /// 当日日记总篇数。
  final int count;
  /// 当日出现最多的心情。
  final Mood? dominantMood;
  /// 心情指数：当日所有标了心情的日记的 [Mood.score] 加权平均（未标心情的忽略）。
  final double? score;
}

/// 最近 [days] 天（含今天）的每日统计，按时间升序。
List<DayMoodStat> weeklyMoodStats(
  List<DiaryEntry> entries, {
  required DateTime now,
  int days = 7,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final firstDay = today.subtract(Duration(days: days - 1));
  final buckets = <DateTime, List<DiaryEntry>>{};
  for (var i = 0; i < days; i++) {
    buckets[firstDay.add(Duration(days: i))] = [];
  }
  for (final e in entries) {
    final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    buckets[d]?.add(e);
  }

  final result = <DayMoodStat>[];
  for (var i = 0; i < days; i++) {
    final d = firstDay.add(Duration(days: i));
    final list = buckets[d]!;
    final dist = moodDistribution(list);
    Mood? dominant;
    var max = 0;
    for (final entry in dist.entries) {
      if (entry.value > max) {
        max = entry.value;
        dominant = entry.key;
      }
    }
    // 加权平均心情指数
    final scored =
        list.map((e) => Mood.fromId(e.mood)).where((m) => m != null);
    final score = scored.isEmpty
        ? null
        : scored.fold<int>(0, (s, m) => s + m!.score) / scored.length;
    result.add(DayMoodStat(
      date: d,
      count: list.length,
      dominantMood: dominant,
      score: score,
    ));
  }
  return result;
}
