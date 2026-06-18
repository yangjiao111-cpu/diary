// 冒烟测试：应用能正常启动并停在「日记」首页。
//
// 冒烟测试只验证 UI 启动与首屏渲染，不依赖真实 drift（CRUD 由
// diary_repository_test 覆盖）。这里把 diaryListProvider override 成空列表
// 替身，既避免测试环境调用 path_provider，也规避 drift stream 在 dispose
// 时残留 Timer 的测试摩擦。

import 'package:diary/app.dart';
import 'package:diary/core/database/app_database.dart';
import 'package:diary/features/diary/application/diary_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('启动后显示日记首页与底部导航', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diaryListProvider
              .overrideWith((ref) => Stream.value(const <DiaryEntry>[])),
        ],
        child: const DiaryApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 首屏为「我的日记」列表页（AppBar 标题，全局唯一）。
    expect(find.text('我的日记'), findsOneWidget);
    // 底部导航外壳存在。
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
