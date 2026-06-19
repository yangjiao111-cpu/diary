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

  test('weeklyMoodStats 按天分桶并计算加权平均心情指数', () {
    final now = DateTime(2026, 6, 15); // 周一
    // 今天 6/15 开心, 昨天 6/14 难过
    final entries = [
      _entry(mood: 'happy', at: DateTime(2026, 6, 15)),
      _entry(mood: 'sad', at: DateTime(2026, 6, 14)),
    ];
    final stats = weeklyMoodStats(entries, now: now, days: 7);
    expect(stats.length, 7);

    final today = stats.last; // 6月15日
    expect(today.date, DateTime(2026, 6, 15));
    expect(today.count, 1);
    expect(today.dominantMood, Mood.happy);
    expect(today.score, 10.0); // +10 / 1

    final yesterday = stats[stats.length - 2]; // 6月14日
    expect(yesterday.date, DateTime(2026, 6, 14));
    expect(yesterday.count, 1);
    expect(yesterday.dominantMood, Mood.sad);
    expect(yesterday.score, -5.0); // -5 / 1
  });

  test('weeklyMoodStats 无标记心情的日期 score 为 null', () {
    final now = DateTime(2026, 6, 15);
    final entries = <DiaryEntry>[];
    final stats = weeklyMoodStats(entries, now: now, days: 3);
    for (final s in stats) {
      expect(s.score, isNull);
      expect(s.count, 0);
    }
  });
}
