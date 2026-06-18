import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 暖米色纸感手账主题（Material 3）。
///
/// 颜色集中在 [AppColors]。视觉原则：低投影、圆角、充足留白。
///
/// 版本适配提示（针对较新的 Flutter 稳定版编写）：
/// - 若编译报错，可将 `WidgetStateProperty` 改为 `MaterialStateProperty`，
///   `withValues(alpha: x)` 改为 `withOpacity(x)`。
class AppTheme {
  AppTheme._();

  /// 统一圆角半径
  static const double radius = 16;

  /// 字体族：打包 Noto Sans SC 等字体资源后改为 'NotoSansSC'
  static const String? fontFamily = null;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final Color background =
        isLight ? AppColors.lightBackground : AppColors.darkBackground;
    final Color surface =
        isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final Color ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final Color inkSoft =
        isLight ? AppColors.lightInkSoft : AppColors.darkInkSoft;
    final Color accent = isLight ? AppColors.lightAccent : AppColors.darkAccent;
    final Color accentSoft =
        isLight ? AppColors.lightAccentSoft : AppColors.darkAccentSoft;

    // 以强调色为种子生成 M3 配色，再覆盖纸感关键色。
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: inkSoft,
      primary: accent,
      onPrimary: isLight ? Colors.white : AppColors.darkBackground,
      primaryContainer: accentSoft,
      onPrimaryContainer: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      // 纸感 AppBar：与背景同色、无投影
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
      // 底部导航：米色底、强调色选中
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accentSoft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, color: ink, fontFamily: fontFamily),
        ),
      ),
      // 圆角填充按钮
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      // 输入框：柔和、无硬边框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: inkSoft.withValues(alpha: 0.15),
        thickness: 1,
      ),
    );
  }
}
