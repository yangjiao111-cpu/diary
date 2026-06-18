import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/diary_repository.dart';

/// 全局数据库单例；随 ProviderScope 释放时关闭连接。
///
/// 测试可用 `appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory()))`
/// 注入内存库。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 日记仓储。
final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository(ref.watch(appDatabaseProvider));
});

/// 全部日记的响应式列表（按创建时间倒序）。
final diaryListProvider = StreamProvider<List<DiaryEntry>>((ref) {
  return ref.watch(diaryRepositoryProvider).watchEntries();
});

/// 按 id 订阅单条日记；不存在时为 null。
final diaryEntryProvider = StreamProvider.family<DiaryEntry?, int>((ref, id) {
  return ref.watch(diaryRepositoryProvider).watchEntry(id);
});
