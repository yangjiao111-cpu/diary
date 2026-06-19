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
    final now = DateTime(2026, 6, 19);
    final entries = [
      // 6/13 开心(+10)
      _entry(mood: 'happy', at: DateTime(2026, 6, 13)),
      // 6/15 开心(+10) + 平静(+5) → (10+5)/2=7.5
      _entry(mood: 'happy', at: DateTime(2026, 6, 15)),
      _entry(mood: 'calm', at: DateTime(2026, 6, 15)),
      // 6/16 难过(-5) + 烦躁(-10) → (-5-10)/2=-7.5
      _entry(mood: 'sad', at: DateTime(2026, 6, 16)),
      _entry(mood: 'angry', at: DateTime(2026, 6, 16)),
      // 6/18 疲惫(+1)
      _entry(mood: 'tired', at: DateTime(2026, 6, 18)),
    ];
    final stats = weeklyMoodStats(entries, now: now, days: 7);
    expect(stats.length, 7);

    // 6/13 开心
    expect(stats[0].date, DateTime(2026, 6, 13));
    expect(stats[0].score, 10.0);
    // 6/14 无日记 → 0
    expect(stats[1].date, DateTime(2026, 6, 14));
    expect(stats[1].score, 0);
    // 6/15 开心+平静 → 7.5
    expect(stats[2].date, DateTime(2026, 6, 15));
    expect(stats[2].score, 7.5);
    // 6/16 难过+烦躁 → -7.5
    expect(stats[3].date, DateTime(2026, 6, 16));
    expect(stats[3].score, -7.5);
    // 6/17 无日记 → 0
    expect(stats[4].date, DateTime(2026, 6, 17));
    expect(stats[4].score, 0);
    // 6/18 疲惫 → 1
    expect(stats[5].date, DateTime(2026, 6, 18));
    expect(stats[5].score, 1.0);
    // 6/19 无日记 → 0
    expect(stats[6].date, DateTime(2026, 6, 19));
    expect(stats[6].score, 0);
  });
}
