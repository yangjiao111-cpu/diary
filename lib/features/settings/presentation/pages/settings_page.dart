import 'package:flutter/material.dart';

/// 设置页（M0 占位）。M5/M6 接入主题、每日提醒、隐私锁等真实开关。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('主题外观'),
            subtitle: Text('暖米色纸感'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('每日提醒'),
            subtitle: Text('未开启'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('隐私锁'),
            subtitle: Text('未开启'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
