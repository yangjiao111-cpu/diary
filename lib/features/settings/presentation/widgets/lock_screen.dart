import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings_providers.dart';

/// 隐私锁锁屏：输入 PIN 解锁。验证正确后调用 [unlockedProvider] 放行。
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, required this.expectedPin});

  final String expectedPin;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == widget.expectedPin) {
      ref.read(unlockedProvider.notifier).unlock();
    } else {
      setState(() {
        _error = 'PIN 不正确';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text('输入 PIN 解锁', style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '••••',
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('解锁'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
