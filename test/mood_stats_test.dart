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

  test('monthlyMoodStats 按月分桶并取主导心情', () {
    final now = DateTime(2026, 6, 15);
    final entries = [
      _entry(mood: 'happy', at: DateTime(2026, 6, 1)),
      _entry(mood: 'happy', at: DateTime(2026, 6, 20)),
      _entry(mood: 'sad', at: DateTime(2026, 6, 25)),
      _entry(mood: 'calm', at: DateTime(2026, 5, 10)),
    ];
    final stats = monthlyMoodStats(entries, now: now, months: 6);
    expect(stats.length, 6);

    final june = stats.last; // 本月（6 月）
    expect(june.month.month, 6);
    expect(june.count, 3);
    expect(june.dominantMood, Mood.happy); // happy 2 > sad 1

    final may = stats[stats.length - 2]; // 5 月
    expect(may.month.month, 5);
    expect(may.count, 1);
    expect(may.dominantMood, Mood.calm);
  });
}
