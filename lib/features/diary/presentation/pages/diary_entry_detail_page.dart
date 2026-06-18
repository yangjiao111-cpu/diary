import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../application/diary_providers.dart';
import '../../domain/mood.dart';

/// 日记详情页：展示单条日记，支持进入编辑与删除。
class DiaryEntryDetailPage extends ConsumerWidget {
  const DiaryEntryDetailPage({super.key, required this.id});

  final int id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这篇日记？'),
        content: const Text('删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(diaryRepositoryProvider).delete(id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entryAsync = ref.watch(diaryEntryProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记'),
        actions: [
          IconButton(
            onPressed: () => context.push('/entry/$id/edit'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑',
          ),
          IconButton(
            onPressed: () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline),
            tooltip: '删除',
          ),
        ],
      ),
      body: entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const EmptyState(
              icon: Icons.auto_stories_outlined,
              message: '这篇日记已被删除',
            );
          }
          final mood = Mood.fromId(entry.mood);
          final title = entry.title?.trim();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (title != null && title.isNotEmpty) ...[
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Text(
                    _formatDateTime(entry.createdAt),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (mood != null) ...[
                    const SizedBox(width: 12),
                    Icon(mood.icon, size: 18, color: mood.color),
                    const SizedBox(width: 4),
                    Text(
                      mood.label,
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: mood.color),
                    ),
                  ],
                ],
              ),
              const Divider(height: 32),
              Text(entry.content, style: theme.textTheme.bodyLarge),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.error_outline,
          message: '加载失败',
        ),
      ),
    );
  }
}

/// 详情用的完整时间：yyyy-MM-dd HH:mm。
String _formatDateTime(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
