import 'package:flutter/material.dart';

/// 暖米色纸感手账 —— 全局调色板
///
/// 所有颜色集中在此处定义，便于后续用 theme-factory 整体替换风格。
/// 风格基调：米白底 + 墨色字 + 单一柔和强调色（莫兰迪鼠尾草绿）。
class AppColors {
  AppColors._();

  // —— 浅色（暖米白纸感）——
  /// 页面背景：暖米白
  static const Color lightBackground = Color(0xFFFAF6EF);

  /// 卡片/纸面
  static const Color lightSurface = Color(0xFFFFFDF8);

  /// 次级纸面（选中底、分组背景）
  static const Color lightSurfaceAlt = Color(0xFFF1EADC);

  /// 正文墨色（深褐，而非纯黑，更柔和）
  static const Color lightInk = Color(0xFF3A3530);

  /// 辅助文字
  static const Color lightInkSoft = Color(0xFF8A8178);

  /// 强调色：莫兰迪鼠尾草绿
  static const Color lightAccent = Color(0xFF7E8E6E);

  /// 强调浅色（选中态背景）
  static const Color lightAccentSoft = Color(0xFFDDE3D2);

  // —— 深色（暖夜）——
  static const Color darkBackground = Color(0xFF1C1A17);
  static const Color darkSurface = Color(0xFF26231F);
  static const Color darkSurfaceAlt = Color(0xFF332F2A);
  static const Color darkInk = Color(0xFFECE6DC);
  static const Color darkInkSoft = Color(0xFFA89F93);
  static const Color darkAccent = Color(0xFFA3B38C);
  static const Color darkAccentSoft = Color(0xFF3A4232);

  // —— 心情色（柔和低饱和）——
  static const Color moodHappy = Color(0xFFE5B769); // 开心 · 暖黄
  static const Color moodCalm = Color(0xFF8FB4A6); // 平静 · 青绿
  static const Color moodSad = Color(0xFF8DA0BF); // 难过 · 灰蓝
  static const Color moodAngry = Color(0xFFC58A7A); // 烦躁 · 陶土
  static const Color moodTired = Color(0xFFB0A4C0); // 疲惫 · 藕紫
}
