import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../diary/application/diary_providers.dart';
import '../../../diary/presentation/widgets/diary_entry_card.dart';

/// 日历页：中文月视图，下方自定义「展开/收起」控件；有日记的天标一个点，
/// 选中某天查看当天日记，选中后日历自动收起；点标题可弹窗快速选年月。
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  static final DateTime _firstDay = DateTime.utc(2020, 1, 1);
  static final DateTime _lastDay = DateTime.utc(2035, 12, 31);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// 按「年月日」分组（忽略时分秒）。
  Map<DateTime, List<DiaryEntry>> _groupByDay(List<DiaryEntry> entries) {
    final map = <DateTime, List<DiaryEntry>>{};
    for (final e in entries) {
      final key = DateUtils.dateOnly(e.createdAt);
      (map[key] ??= []).add(e);
    }
    return map;
  }

  /// 日历下方展开/收起控件：收起态=向下箭头+「展开」，展开态=向上箭头+「收起」。
  Widget _buildFormatToggle(ThemeData theme) {
    final isMonth = _calendarFormat == CalendarFormat.month;
    return InkWell(
      onTap: () => setState(() {
        _calendarFormat =
            isMonth ? CalendarFormat.week : CalendarFormat.month;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMonth ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              isMonth ? '收起' : '展开',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  /// 点击标题：弹日期选择器（默认年份模式）快速跳到某年某月。
  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: _firstDay,
      lastDate: _lastDay,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _focusedDay = picked;
      _selectedDay = picked;
      _calendarFormat = CalendarFormat.week;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(diaryListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('日历')),
      body: entriesAsync.when(
        data: (entries) {
          final byDay = _groupByDay(entries);
          final selected = _selectedDay ?? _focusedDay;
          final dayEntries =
              byDay[DateUtils.dateOnly(selected)] ?? const <DiaryEntry>[];
          return Column(
            children: [
              TableCalendar<DiaryEntry>(
                locale: 'zh_CN',
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: '月',
                  CalendarFormat.week: '周',
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) =>
                    byDay[DateUtils.dateOnly(day)] ?? const <DiaryEntry>[],
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = selectedDay; // 用选中日更新焦点，标题跟到正确月份
                    _calendarFormat = CalendarFormat.week;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                onHeaderTapped: (_) => _pickMonth(),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markersMaxCount: 1,
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: theme.colorScheme.onSurface),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
              ),
              _buildFormatToggle(theme),
              const Divider(height: 1),
              Expanded(
                child: dayEntries.isEmpty
                    ? const EmptyState(
                        icon: Icons.event_note_outlined,
                        message: '这天还没有日记',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: dayEntries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final entry = dayEntries[i];
                          return DiaryEntryCard(
                            entry: entry,
                            onTap: () => context.push('/entry/${entry.id}'),
                          );
                        },
                      ),
              ),
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
