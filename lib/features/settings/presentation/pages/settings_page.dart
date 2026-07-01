import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings_providers.dart';

/// 设置页：主题外观、每日提醒、隐私锁、关于。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '亮色';
      case ThemeMode.dark:
        return '暗色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  Future<void> _pickTheme(
      BuildContext context, WidgetRef ref, ThemeMode current) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('主题外观'),
              ),
              for (final mode in ThemeMode.values)
                ListTile(
                  title: Text(_themeLabel(mode)),
                  trailing:
                      current == mode ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, mode),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setMode(selected);
    }
  }

  Future<void> _onTapPrivacyLock(
      BuildContext context, WidgetRef ref, String? currentPin) async {
    final hasPin = currentPin != null && currentPin.isNotEmpty;
    if (!hasPin) {
      await _setPin(context, ref);
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('修改 PIN'),
              onTap: () => Navigator.pop(context, 'change'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_open_outlined),
              title: const Text('关闭隐私锁'),
              onTap: () => Navigator.pop(context, 'close'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == 'change') {
      if (context.mounted) await _setPin(context, ref);
    } else if (action == 'close') {
      await ref.read(pinProvider.notifier).clearPin();
    }
  }

  Future<void> _openReminderSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Consumer(
            builder: (context, ref, _) {
              final enabled =
                  ref.watch(reminderEnabledProvider).value ?? false;
              final time = ref.watch(reminderTimeProvider).value ??
                  const TimeOfDay(hour: 21, minute: 0);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('每日提醒'),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('开启每日提醒'),
                    subtitle: const Text('App 运行时到点弹出提醒'),
                    value: enabled,
                    onChanged: (v) => ref
                        .read(reminderEnabledProvider.notifier)
                        .setEnabled(v),
                  ),
                  ListTile(
                    enabled: enabled,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('提醒时间'),
                    subtitle: Text(time.format(context)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: enabled
                        ? () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (picked != null) {
                              await ref
                                  .read(reminderTimeProvider.notifier)
                                  .setTime(picked);
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) {
        String? err;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('设置 PIN'),
              content: TextField(
                controller: controller,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '至少 4 位数字',
                  errorText: err,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    if (controller.text.length < 4) {
                      setLocalState(() => err = 'PIN 至少 4 位');
                    } else {
                      Navigator.pop(context, controller.text);
                    }
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
    if (pin != null) {
      await ref.read(pinProvider.notifier).setPin(pin);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final pin = ref.watch(pinProvider).value;
    final hasPin = pin != null && pin.isNotEmpty;
    final reminderEnabled = ref.watch(reminderEnabledProvider).value ?? false;
    final reminderTime = ref.watch(reminderTimeProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('主题外观'),
            subtitle: Text(_themeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTheme(context, ref, themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('每日提醒'),
            subtitle: Text(
              reminderEnabled && reminderTime != null
                  ? '每天 ${reminderTime.format(context)}'
                  : '未开启',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openReminderSheet(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('隐私锁'),
            subtitle: Text(hasPin ? '已开启' : '未开启'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _onTapPrivacyLock(context, ref, pin),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '日记',
              applicationVersion: '1.0.0',
              applicationLegalese: '一款本地优先的手账类日记 App',
            ),
          ),
        ],
      ),
    );
  }
}
