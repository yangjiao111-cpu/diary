import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/reminder_scheduler.dart';
import 'features/settings/application/settings_providers.dart';
import 'features/settings/presentation/widgets/lock_screen.dart';

/// 应用根组件：暖米色纸感主题 + go_router 路由 + 中文本地化 + 隐私锁。
///
/// 主题模式由 [themeModeProvider] 提供（持久化在设置表），可在设置页切换。
class DiaryApp extends ConsumerWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    // 让每日提醒调度器常驻存活：watch 一次即随 app 生命周期启停。
    ref.watch(reminderSchedulerProvider);
    return MaterialApp.router(
      title: '日记',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en'),
      ],
      routerConfig: appRouter,
      builder: (context, child) => _LockGate(child: child),
    );
  }
}

/// 隐私锁门卫：若设置了 PIN 且本次未解锁，用锁屏覆盖整个应用。
class _LockGate extends ConsumerWidget {
  const _LockGate({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pin = ref.watch(pinProvider).value;
    final unlocked = ref.watch(unlockedProvider);
    if (pin != null && pin.isNotEmpty && !unlocked) {
      return LockScreen(expectedPin: pin);
    }
    return child ?? const SizedBox.shrink();
  }
}
