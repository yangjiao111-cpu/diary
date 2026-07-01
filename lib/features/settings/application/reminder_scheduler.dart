import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import 'settings_providers.dart';

/// 全局 ScaffoldMessenger key：让应用内提醒可以在任意页面弹出 SnackBar，
/// 不依赖某个具体页面的 context。挂到 [MaterialApp.router] 的 scaffoldMessengerKey。
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// 应用内每日提醒调度器。
///
/// 监听提醒开关与时间：开启时用 [Timer] 定时到设定时刻，弹出 SnackBar 提醒，
/// 并附「去写」按钮跳到新建页；随后自动排期到次日同一时刻。纯 Dart 定时、无
/// 系统通知——仅在 app 运行期间生效，符合本地优先桌面日记的定位。
///
/// state 为 void：本调度器只产生副作用（弹 SnackBar），不对外暴露值，因此触发
/// 提醒时不会引起任何 widget 重建。根组件仅需 watch 一次即可让它常驻存活。
class ReminderScheduler extends Notifier<void> {
  Timer? _timer;

  @override
  void build() {
    // provider 销毁（app 退出）时兜底清理定时器。
    ref.onDispose(() => _timer?.cancel());

    final enabled = ref.watch(reminderEnabledProvider).value ?? false;
    final time = ref.watch(reminderTimeProvider).value;

    // 依赖变化会重跑 build（Notifier 实例复用），先取消上一轮定时器再重排。
    _timer?.cancel();
    if (!enabled || time == null) return;
    _scheduleNext(time);
  }

  /// 计算「下一个」该时刻并设定定时器：今天该时刻若已过则顺延到明天。
  void _scheduleNext(TimeOfDay time) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    _timer = Timer(next.difference(now), _fire);
  }

  /// 到点触发：弹提醒 SnackBar，并重新排期到次日同一时刻。
  void _fire() {
    scaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('该记录今天的心情啦'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: '去写',
            onPressed: () => appRouter.push('/entry/new'),
          ),
        ),
      );
    final time = ref.read(reminderTimeProvider).value;
    if (time != null) _scheduleNext(time);
  }
}

final reminderSchedulerProvider =
    NotifierProvider<ReminderScheduler, void>(ReminderScheduler.new);
