import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';

/// 搜索页（M0 占位）。M3 接入全文搜索（FTS5 trigram + LIKE 兜底）。
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '搜索日记内容…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: EmptyState(
                icon: Icons.search_outlined,
                message: '输入关键词搜索你的日记',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
