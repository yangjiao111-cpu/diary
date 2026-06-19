import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paper_card.dart';
import '../../../diary/application/diary_providers.dart';
import '../../../diary/domain/mood.dart';
import '../../application/mood_stats.dart';

/// 心情统计页：心情分布饼图 + 近一周心情指数折线图。
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
          final dist = ref.watch(moodDistributionProvider);
          final weekly = ref.watch(weeklyMoodStatsProvider);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DistributionCard(distribution: dist),
              const SizedBox(height: 16),
              _TrendCard(weekly: weekly),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.error_outlined,
          message: '加载失败',
        ),
      ),
    );
  }
}

// ---- 心情分布卡片 ----

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.distribution});

  final Map<Mood, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = distribution.entries.toList();
    final total = items.fold<int>(0, (s, v) => s + v.value);
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
          else
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _PiePainter(
                          slices: [
                            for (final e in items)
                              _PieSlice(
                                color: e.key.color,
                                ratio: e.value / total,
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
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
                                  width: 10, height: 10,
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  const _PiePainter({required this.slices});
  final List<_PieSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final oval = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;
    for (final s in slices) {
      canvas.drawArc(oval, startAngle, 2 * math.pi * s.ratio, true,
          Paint()..color = s.color);
      startAngle += 2 * math.pi * s.ratio;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => true;
}

class _PieSlice {
  const _PieSlice({required this.color, required this.ratio});
  final Color color;
  final double ratio;
}

// ---- 折线图（近一周心情指数） ----

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.weekly});
  final List<DayMoodStat> weekly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double yMin = -10, yMax = 10;
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('心情指数', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '近 7 天趋势',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LayoutBuilder(builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              const padTop = 10.0, padBottom = 30.0, padLeft = 10.0, padRight = 10.0;
              final chartW = w - padLeft - padRight;
              final chartH = h - padTop - padBottom;
              final hasScore = <int>[];
              for (var i = 0; i < weekly.length; i++) {
                hasScore.add(i); // score 现在是 double 永不为 null，7 天全画
              }
              final points = <Offset>[];
              for (final idx in hasScore) {
                final x = padLeft + (idx + 0.5) * (chartW / weekly.length);
                final y = padTop +
                    chartH -
                    ((weekly[idx].score - yMin) / (yMax - yMin) * chartH);
                points.add(Offset(x, y));
              }
              return CustomPaint(
                size: Size(w, h),
                painter: _LinePainter(
                  points: points,
                  weekly: weekly,
                  hasScore: hasScore,
                  yMin: yMin,
                  yMax: yMax,
                  chartH: chartH,
                  chartTop: padTop,
                  chartLeft: padLeft,
                  chartW: chartW,
                  accent: theme.colorScheme.primary,
                  inkSoft: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({
    required this.points,
    required this.weekly,
    required this.hasScore,
    required this.yMin,
    required this.yMax,
    required this.chartH,
    required this.chartTop,
    required this.chartLeft,
    required this.chartW,
    required this.accent,
    required this.inkSoft,
  });

  final List<Offset> points;
  final List<DayMoodStat> weekly;
  final List<int> hasScore;
  final double yMin, yMax;
  final double chartH, chartTop, chartLeft, chartW;
  final Color accent, inkSoft;

  static const _weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = inkSoft.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dotFill = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    // 水平网格线（间隔 5 分）
    for (var v = -10; v <= 10; v += 5) {
      final y = chartTop + chartH - ((v - yMin) / (yMax - yMin) * chartH);
      canvas.drawLine(Offset(chartLeft, y), Offset(chartLeft + chartW, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: '${v > 0 ? "+" : ""}$v',
          style: TextStyle(color: inkSoft, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // 零线
    final zeroY = chartTop + chartH - ((0 - yMin) / (yMax - yMin) * chartH);
    canvas.drawLine(
      Offset(chartLeft, zeroY),
      Offset(chartLeft + chartW, zeroY),
      Paint()
        ..color = inkSoft.withValues(alpha: 0.3)
        ..strokeWidth = 1.2,
    );

    // X 轴星期标签
    final labelStyle = TextStyle(color: inkSoft, fontSize: 10);
    for (var i = 0; i < weekly.length; i++) {
      final x = chartLeft + (i + 0.5) * (chartW / weekly.length);
      final tp = TextPainter(
        text: TextSpan(
          text: _weekdayLabels[(weekly[i].date.weekday - 1) % 7],
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartTop + chartH + 6));
    }

    // 折线
    if (points.length >= 2) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // 数据点
    for (final p in points) {
      canvas.drawCircle(p, 5, dotFill);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}
