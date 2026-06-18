import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/diary_providers.dart';
import '../../domain/mood.dart';
import '../widgets/mood_picker.dart';

/// 日记编辑页：新建（[entryId] 为 null）与编辑共用一套表单。
class DiaryEntryEditPage extends ConsumerStatefulWidget {
  const DiaryEntryEditPage({super.key, this.entryId});

  final int? entryId;

  bool get isEditing => entryId != null;

  @override
  ConsumerState<DiaryEntryEditPage> createState() => _DiaryEntryEditPageState();
}

class _DiaryEntryEditPageState extends ConsumerState<DiaryEntryEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Mood? _mood;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loading = true;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final entry =
        await ref.read(diaryRepositoryProvider).getEntry(widget.entryId!);
    if (!mounted) return;
    if (entry != null) {
      _titleController.text = entry.title ?? '';
      _contentController.text = entry.content;
      _mood = Mood.fromId(entry.mood);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('写点什么再保存吧')));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(diaryRepositoryProvider);
    final title = _titleController.text.trim();
    final titleOrNull = title.isEmpty ? null : title;
    if (widget.isEditing) {
      await repo.update(
        id: widget.entryId!,
        content: content,
        title: titleOrNull,
        mood: _mood?.id,
      );
    } else {
      await repo.create(
        content: content,
        title: titleOrNull,
        mood: _mood?.id,
      );
    }
    if (!mounted) return;
    context.pop();
  }

  Future<void> _delete() async {
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
    await ref.read(diaryRepositoryProvider).delete(widget.entryId!);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑日记' : '写日记'),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除',
            ),
          IconButton(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            tooltip: '保存',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: '标题（可选）'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: '今天发生了什么…'),
                  minLines: 6,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 20),
                Text('心情', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                MoodPicker(
                  value: _mood,
                  onChanged: (m) => setState(() => _mood = m),
                ),
              ],
            ),
    );
  }
}
