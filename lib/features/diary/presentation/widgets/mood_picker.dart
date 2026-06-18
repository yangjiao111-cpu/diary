import 'package:flutter/material.dart';

import '../../domain/mood.dart';

/// 心情选择器：一排可单选 / 取消的心情 chip。
///
/// 受控组件：当前选中由 [value] 决定，点击经 [onChanged] 回传；
/// 再次点击已选中项回传 null（取消选择）。
class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Mood? value;
  final ValueChanged<Mood?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mood in Mood.values)
          ChoiceChip(
            label: Text(mood.label),
            avatar: Icon(
              mood.icon,
              size: 18,
              color: value == mood ? mood.color : null,
            ),
            selected: value == mood,
            selectedColor: mood.color.withValues(alpha: 0.25),
            onSelected: (selected) => onChanged(selected ? mood : null),
          ),
      ],
    );
  }
}
