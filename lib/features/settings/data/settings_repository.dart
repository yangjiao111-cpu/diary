import '../../../core/database/app_database.dart';

/// 设置仓储：基于 drift 键值表读写设置项。
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  /// 读取某个键的值；不存在返回 null。
  Future<String?> read(String key) async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// 监听某个键的值变化。
  Stream<String?> watch(String key) {
    return (_db.select(_db.settings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  /// 写入（存在则覆盖）。
  Future<void> write(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  /// 删除某个键。
  Future<void> delete(String key) async {
    await (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
  }
}
