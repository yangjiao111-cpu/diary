import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化中文日期格式数据，供日历显示中文月份/星期。
  await initializeDateFormatting('zh_CN', null);
  runApp(const ProviderScope(child: DiaryApp()));
}
