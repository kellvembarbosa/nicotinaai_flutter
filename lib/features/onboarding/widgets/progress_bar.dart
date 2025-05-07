import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  
  const ProgressBar({
    Key? key, 
    required this.current, 
    required this.total,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final progress = (current / total) * 100;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Passo $current de $total',
              style: context.captionStyle?.copyWith(fontSize: 12),
            ),
            Text(
              '${progress.round()}%',
              style: context.captionStyle?.copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.isDarkMode 
                ? Colors.grey[800] 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: progress / 100,
            child: Container(
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: context.isDarkMode 
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}