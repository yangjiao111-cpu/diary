import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 心情枚举：用于日记的心情标记。
///
/// `id` 为持久化存库的稳定字符串（勿随意改动，以免影响历史数据）。
enum Mood {
  happy('happy', '开心', Icons.sentiment_very_satisfied, AppColors.moodHappy),
  calm('calm', '平静', Icons.sentiment_satisfied, AppColors.moodCalm),
  sad('sad', '难过', Icons.sentiment_dissatisfied, AppColors.moodSad),
  angry('angry', '烦躁', Icons.sentiment_very_dissatisfied, AppColors.moodAngry),
  tired('tired', '疲惫', Icons.bedtime_outlined, AppColors.moodTired);

  const Mood(this.id, this.label, this.icon, this.color);

  final String id;
  final String label;
  final IconData icon;
  final Color color;

  /// 从存库的 id 还原心情；未知/空返回 null。
  static Mood? fromId(String? id) {
    if (id == null) return null;
    for (final m in Mood.values) {
      if (m.id == id) return m;
    }
    return null;
  }
}
