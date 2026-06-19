import 'package:diary/core/database/app_database.dart';
import 'package:diary/features/diary/domain/mood.dart';
import 'package:diary/features/stats/application/mood_stats.dart';
import 'package:flutter_test/flutter_test.dart';

DiaryEntry _entry({required String mood, required DateTime at}) {
  return DiaryEntry(
    id: 0,
    content: '内容',
    mood: mood,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  test('moodDistribution 统计各心情篇数', () {
    final entries = [
      _entry(mood: 'happy', at: DateTime(2026, 6, 1)),
      _entry(mood: 'happy', at: DateTime(2026, 6, 2)),
      _entry(mood: 'sad', at: DateTime(2026, 6, 3)),
    ];
    final dist = moodDistribution(entries);
    expect(dist[Mood.happy], 2);
    expect(dist[Mood.sad], 1);
    expect(dist[Mood.calm], isNull);
  });

  test('monthlyMoodStats 按月分桶并计算加权平均心情指数', () {
    final now = DateTime(2026, 6, 15);
    final entries = [
      _entry(mood: 'happy', at: DateTime(2026, 6, 1)),   // +10
      _entry(mood: 'happy', at: DateTime(2026, 6, 20)),  // +10
      _entry(mood: 'sad', at: DateTime(2026, 6, 25)),    // -5
      _entry(mood: 'calm', at: DateTime(2026, 5, 10)),   // +5
    ];
    final stats = monthlyMoodStats(entries, now: now, months: 6);
    expect(stats.length, 6);

    final june = stats.last; // 本月（6 月）
    expect(june.month.month, 6);
    expect(june.count, 3);
    expect(june.dominantMood, Mood.happy);
    // (10 + 10 + (-5)) / 3 = 5.0
    expect(june.score, 5.0);

    final may = stats[stats.length - 2]; // 5 月
    expect(may.month.month, 5);
    expect(may.count, 1);
    expect(may.dominantMood, Mood.calm);
    expect(may.score, 5.0); // (+5) / 1 = 5.0
  });

  test('monthlyMoodStats 无标记心情的月份 score 为 null', () {
    final now = DateTime(2026, 6, 15);
    final entries = <DiaryEntry>[];
    final stats = monthlyMoodStats(entries, now: now, months: 3);
    for (final s in stats) {
      expect(s.score, isNull);
      expect(s.count, 0);
    }
  });
}
