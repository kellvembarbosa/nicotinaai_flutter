import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

class NumberSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  
  const NumberSelector({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value <= min 
              ? null 
              : () => onChanged(value - step),
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: isDark 
                ? Colors.grey[800] 
                : Colors.grey[200],
            foregroundColor: isDark 
                ? Colors.white 
                : Colors.grey[800],
            disabledBackgroundColor: isDark 
                ? Colors.grey[900] 
                : Colors.grey[100],
            disabledForegroundColor: isDark 
                ? Colors.grey[700] 
                : Colors.grey[400],
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            value.toString(),
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: context.contentColor,
            ),
          ),
        ),
        IconButton(
          onPressed: value >= max 
              ? null 
              : () => onChanged(value + step),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: isDark 
                ? Colors.grey[800] 
                : Colors.grey[200],
            foregroundColor: isDark 
                ? Colors.white 
                : Colors.grey[800],
            disabledBackgroundColor: isDark 
                ? Colors.grey[900] 
                : Colors.grey[100],
            disabledForegroundColor: isDark 
                ? Colors.grey[700] 
                : Colors.grey[400],
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}