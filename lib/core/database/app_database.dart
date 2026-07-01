import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// 日记条目表。
///
/// - `content` 必填正文；`title`、`mood` 可空（mood 存对应 Mood 的 id 字符串）。
/// - 两个时间列默认写入当前时刻。
/// - M3 的全文搜索将基于 content/title 另建 FTS5 虚拟表 + 触发器，无需改动本表。
@DataClassName('DiaryEntry')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get title => text().nullable()();
  TextColumn get mood => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 设置键值表：主题模式、PIN、提醒等以 key-value 形式存储。
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 应用数据库（drift）。
///
/// 作为跨 feature 的基础设施放在 `core/`，M3 的日历/搜索复用同一个库。
/// 可选的 [executor] 便于测试传入内存库 `NativeDatabase.memory()`。
///
/// drift ≥ 2.32 起原生平台无需额外 native 配置，`driftDatabase` 会按平台
/// 选择实现，桌面/移动端把库文件存到应用文档目录下的 `diary.sqlite`。
@DriftDatabase(tables: [Entries, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'diary'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(settings);
          }
        },
      );
}
