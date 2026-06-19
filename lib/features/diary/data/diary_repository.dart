import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// 日记仓储：封装 drift 的增删改查。
///
/// 列表/详情用 `watch*` 返回响应式流，写操作后 drift 会自动把新结果推给
/// 这些流，因此上层无需手动管理列表状态。
class DiaryRepository {
  DiaryRepository(this._db);

  final AppDatabase _db;

  /// 全部日记，按创建时间倒序。
  Stream<List<DiaryEntry>> watchEntries() {
    return (_db.select(_db.entries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// 单条日记的响应式流；不存在（或被删除）时发出 null。
  Stream<DiaryEntry?> watchEntry(int id) {
    return (_db.select(_db.entries)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// 取一次单条日记（用于编辑页加载初值）。
  Future<DiaryEntry?> getEntry(int id) {
    return (_db.select(_db.entries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 新建一条日记，返回自增 id。
  Future<int> create({
    required String content,
    String? title,
    String? mood,
  }) {
    return _db.into(_db.entries).insert(
          EntriesCompanion.insert(
            content: content,
            title: Value(title),
            mood: Value(mood),
          ),
        );
  }

  /// 更新指定日记，并刷新 updatedAt。
  Future<void> update({
    required int id,
    required String content,
    String? title,
    String? mood,
  }) {
    return (_db.update(_db.entries)..where((t) => t.id.equals(id))).write(
      EntriesCompanion(
        content: Value(content),
        title: Value(title),
        mood: Value(mood),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 删除指定日记。
  Future<void> delete(int id) {
    return (_db.delete(_db.entries)..where((t) => t.id.equals(id))).go();
  }

  /// 按关键词搜索（content/title 子串匹配），按创建时间倒序。
  Stream<List<DiaryEntry>> searchEntries(String keyword) {
    final like = '%$keyword%';
    return (_db.select(_db.entries)
          ..where((t) => t.content.like(like) | t.title.like(like))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
