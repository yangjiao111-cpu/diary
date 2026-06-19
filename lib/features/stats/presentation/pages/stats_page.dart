import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paper_card.dart';
import '../../../diary/application/diary_providers.dart';
import '../../../diary/domain/mood.dart';
import '../../application/mood_stats.dart';

/// 心情统计页：心情分布饼图 + 近半年每月趋势柱状图。
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.insights_outlined,
              message: '还没有日记\n记录后这里会显示心情统计',
            );
          }
          final dist = moodDistribution(entries);
          final monthly = monthlyMoodStats(entries, now: DateTime.now());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DistributionCard(distribution: dist),
              const SizedBox(height: 16),
              _TrendCard(monthly: monthly),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.error_outline,
          message: '加载失败',
        ),
      ),
    );
  }
}

// ---- 饼图（纯 Flutter CustomPainter） ----

class _PiePainter extends CustomPainter {
  const _PiePainter({required this.slices});

  final List<_PieSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var startAngle = -math.pi / 2;
    for (final s in slices) {
      final sweep = 2 * math.pi * s.ratio;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        true,
        Paint()..color = s.color,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => slices != old.slices;
}

class _PieSlice {
  const _PieSlice({required this.color, required this.ratio});
  final Color color;
  final double ratio; // 0~1
}

// ---- 柱状图（纯 Flutter 自定义绘制） ----

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.bars, required this.maxY});

  final List<_BarData> bars;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty || maxY <= 0) return;
    final barSpace = 6.0;
    final barWidth = (size.width - barSpace * (bars.length + 1)) / bars.length;
    var x = barSpace;
    for (final b in bars) {
      final h = (b.value / maxY) * (size.height - 4);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, size.height - h, barWidth, h),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = b.color,
      );
      x += barWidth + barSpace;
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => bars != old.bars || maxY != old.maxY;
}

class _BarData {
  const _BarData({required this.value, required this.color});
  final int value;
  final Color color;
}

// ---- 心情分布卡片 ----

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.distribution});

  final Map<Mood, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = distribution.entries.toList();
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('心情分布', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '还没有标记心情的日记',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _PiePainter(
                        slices: [
                          for (final e in items)
                            _PieSlice(
                              color: e.key.color,
                              ratio: e.value /
                                  items.fold<int>(0, (s, v) => s + v.value),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final e in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: e.key.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${e.key.label} ${e.value}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---- 趋势卡片 ----

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.monthly});

  final List<MonthlyMoodStat> monthly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount =
        monthly.fold<int>(0, (m, s) => s.count > m ? s.count : m);
    final effectiveMax = maxCount == 0 ? 1.0 : (maxCount + 1).toDouble();
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('近半年趋势', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _BarPainter(
                      maxY: effectiveMax,
                      bars: [
                        for (final s in monthly)
                          _BarData(
                            value: s.count,
                            color: s.dominantMood?.color ??
                                theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final s in monthly)
                      Text(
                        '${s.month.month}月',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
