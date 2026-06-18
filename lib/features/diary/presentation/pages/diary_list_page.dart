import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../application/diary_providers.dart';
import '../widgets/diary_entry_card.dart';

/// 日记列表页：接入 [diaryListProvider]，有数据时展示卡片列表，空时空状态。
class DiaryListPage extends ConsumerWidget {
  const DiaryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的日记')),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_stories_outlined,
              message: '还没有日记\n记录今天的心情吧',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final entry = entries[i];
              return DiaryEntryCard(
                entry: entry,
                onTap: () => context.push('/entry/${entry.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.error_outline,
          message: '加载失败',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entry/new'),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
