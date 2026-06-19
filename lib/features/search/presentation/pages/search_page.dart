import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../diary/application/diary_providers.dart';
import '../../../diary/presentation/widgets/diary_entry_card.dart';

/// 搜索页：按关键词子串匹配日记的内容/标题。
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '搜索日记内容…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return const EmptyState(
        icon: Icons.search_outlined,
        message: '输入关键词搜索你的日记',
      );
    }
    final resultsAsync = ref.watch(searchResultsProvider(_query));
    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return const EmptyState(
            icon: Icons.sentiment_dissatisfied_outlined,
            message: '没找到相关日记',
          );
        }
        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final entry = results[i];
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
        message: '搜索失败',
      ),
    );
  }
}
