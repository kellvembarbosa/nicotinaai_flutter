import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

class MultiSelectOptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onPress;
  final String label;
  final String? description;
  final Widget? child;
  
  const MultiSelectOptionCard({
    Key? key,
    required this.selected,
    required this.onPress,
    required this.label,
    this.description,
    this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    // No modo escuro, usamos efeito de vidro fosco
    if (isDark) {
      return _buildGlassmorphicCard(context);
    }
    
    // No modo claro, versão normal
    return _buildStandardCard(context);
  }
  
  Widget _buildStandardCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected 
                ? context.primaryColor.withOpacity(0.1) 
                : context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? context.primaryColor : context.borderColor,
              width: 1.5,
            ),
          ),
          child: _buildCardContent(context),
        ),
      ),
    );
  }
  
  Widget _buildGlassmorphicCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected 
                    ? context.primaryColor.withOpacity(0.15) 
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected 
                      ? context.primaryColor.withOpacity(0.8) 
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: _buildCardContent(context),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected 
                      ? context.primaryColor 
                      : context.isDarkMode
                          ? Colors.grey[400]! 
                          : Colors.grey[400]!,
                  width: 1.5,
                ),
                color: selected ? context.primaryColor : Colors.transparent,
                boxShadow: selected && context.isDarkMode
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.isDarkMode
                        ? context.textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )
                        : context.textTheme.titleMedium!.copyWith(
                            color: Colors.grey[900],
                            fontWeight: FontWeight.w500,
                          ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: context.subtitleStyle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (child != null) ...[
          const SizedBox(height: 12),
          child!,
        ],
      ],
    );
  }
}