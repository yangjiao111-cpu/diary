import 'package:go_router/go_router.dart';

import '../../features/diary/presentation/pages/diary_entry_detail_page.dart';
import '../../features/diary/presentation/pages/diary_entry_edit_page.dart';
import '../../features/home/home_shell.dart';

/// 全局路由表。
///
/// 顶层 `/` 进入底部导航外壳；日记的新建/详情/编辑作为顶层路由 push，
/// 盖在外壳之上、不进底部导航。注意 `/entry/new` 必须排在 `/entry/:id`
/// 之前，否则 "new" 会被当作 id 参数匹配。
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: '/entry/new',
      builder: (context, state) => const DiaryEntryEditPage(),
    ),
    GoRoute(
      path: '/entry/:id',
      builder: (context, state) =>
          DiaryEntryDetailPage(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/entry/:id/edit',
      builder: (context, state) =>
          DiaryEntryEditPage(entryId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
