import 'package:diary/core/database/app_database.dart';
import 'package:diary/features/diary/data/diary_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository repo;

  setUp(() {
    // 内存库：不碰文件系统/平台，每个用例独立。
    db = AppDatabase(NativeDatabase.memory());
    repo = DiaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('CRUD：新建 → 查询 → 更新 → 删除', () async {
    expect(await repo.watchEntries().first, isEmpty);

    // 新建
    final id = await repo.create(content: '第一篇', mood: 'happy');
    final created = await repo.watchEntries().first;
    expect(created, hasLength(1));
    expect(created.single.content, '第一篇');
    expect(created.single.mood, 'happy');

    // 取一次
    final fetched = await repo.getEntry(id);
    expect(fetched, isNotNull);
    expect(fetched!.title, isNull);

    // 更新
    await repo.update(id: id, content: '改过了', title: '标题', mood: 'calm');
    final updated = await repo.getEntry(id);
    expect(updated!.content, '改过了');
    expect(updated.title, '标题');
    expect(updated.mood, 'calm');

    // 删除
    await repo.delete(id);
    expect(await repo.watchEntries().first, isEmpty);
    expect(await repo.getEntry(id), isNull);
  });

  test('搜索：内容/标题子串匹配', () async {
    await repo.create(content: '今天很开心', mood: 'happy');
    await repo.create(content: '明天会更好', title: '展望');
    await repo.create(content: '随便写写');

    // 子串「天」命中前两条
    expect(await repo.searchEntries('天').first, hasLength(2));
    // 「开心」命中一条
    final happy = await repo.searchEntries('开心').first;
    expect(happy.single.content, '今天很开心');
    // 标题也参与匹配
    final byTitle = await repo.searchEntries('展望').first;
    expect(byTitle.single.title, '展望');
    // 无匹配返回空
    expect(await repo.searchEntries('不存在的词').first, isEmpty);
  });
}
