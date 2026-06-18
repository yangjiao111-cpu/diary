import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';

/// 日历页（M0 占位）。M3 接入 table_calendar 月视图与按日浏览。
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日历')),
      body: const EmptyState(
        icon: Icons.calendar_month_outlined,
        message: '日历视图即将上线',
      ),
    );
  }
}
