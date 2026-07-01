import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../diary/application/diary_providers.dart';
import '../data/settings_repository.dart';

/// 设置项的存储键。
class SettingsKeys {
  SettingsKeys._();
  static const themeMode = 'theme_mode';
  static const pin = 'pin';
  static const reminderEnabled = 'reminder_enabled';
  static const reminderTime = 'reminder_time'; // HH:mm
}

/// 设置仓储 provider。
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

/// 主题模式：持久化到设置表，可切换。
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final raw =
        await ref.watch(settingsRepositoryProvider).read(SettingsKeys.themeMode);
    return _parse(raw);
  }

  Future<void> setMode(ThemeMode mode) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingsKeys.themeMode, mode.name);
    state = AsyncData(mode);
  }

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// 隐私锁 PIN（明文存储，足够"防随手翻看"；null 表示未设置）。
class PinNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() {
    return ref.watch(settingsRepositoryProvider).read(SettingsKeys.pin);
  }

  Future<void> setPin(String pin) async {
    await ref.read(settingsRepositoryProvider).write(SettingsKeys.pin, pin);
    state = AsyncData(pin);
  }

  Future<void> clearPin() async {
    await ref.read(settingsRepositoryProvider).delete(SettingsKeys.pin);
    state = const AsyncData(null);
  }
}

final pinProvider =
    AsyncNotifierProvider<PinNotifier, String?>(PinNotifier.new);

/// 每日提醒是否开启（持久化在设置表，默认关闭）。
class ReminderEnabledNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final raw = await ref
        .watch(settingsRepositoryProvider)
        .read(SettingsKeys.reminderEnabled);
    return raw == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingsKeys.reminderEnabled, enabled.toString());
    state = AsyncData(enabled);
  }
}

final reminderEnabledProvider =
    AsyncNotifierProvider<ReminderEnabledNotifier, bool>(
        ReminderEnabledNotifier.new);

/// 每日提醒时间（持久化为 HH:mm，默认 21:00）。
class ReminderTimeNotifier extends AsyncNotifier<TimeOfDay> {
  static const _default = TimeOfDay(hour: 21, minute: 0);

  @override
  Future<TimeOfDay> build() async {
    final raw = await ref
        .watch(settingsRepositoryProvider)
        .read(SettingsKeys.reminderTime);
    return _parse(raw);
  }

  Future<void> setTime(TimeOfDay time) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingsKeys.reminderTime, _format(time));
    state = AsyncData(time);
  }

  /// 从 "HH:mm" 还原；解析失败退回默认值。
  static TimeOfDay _parse(String? raw) {
    if (raw == null) return _default;
    final parts = raw.split(':');
    if (parts.length != 2) return _default;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return _default;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return _default;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// 格式化为零填充的 "HH:mm"。
  static String _format(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

final reminderTimeProvider =
    AsyncNotifierProvider<ReminderTimeNotifier, TimeOfDay>(
        ReminderTimeNotifier.new);

/// 本次运行是否已解锁（不持久化，重启 app 需重新解锁）。
class UnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void unlock() => state = true;
}

final unlockedProvider =
    NotifierProvider<UnlockedNotifier, bool>(UnlockedNotifier.new);
