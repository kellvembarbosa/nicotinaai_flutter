import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

class OptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onPress;
  final String label;
  final String? description;
  final Widget? child;
  final String? analyticsEventName;
  final Map<String, dynamic>? analyticsProperties;
  
  const OptionCard({
    Key? key,
    required this.selected,
    required this.onPress,
    required this.label,
    this.description,
    this.child,
    this.analyticsEventName,
    this.analyticsProperties,
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
      borderRadius: BorderRadius.circular(8), // Reduzido para 8
      child: InkWell(
        onTap: () {
          // Trackear o evento se fornecido
          if (analyticsEventName != null) {
            AnalyticsService().trackEvent(
              analyticsEventName!,
              parameters: analyticsProperties ?? {'option': label},
            );
          }
          onPress();
        },
        borderRadius: BorderRadius.circular(8), // Reduzido para 8
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Ultra compacto
          decoration: BoxDecoration(
            color: selected 
                ? context.primaryColor.withOpacity(0.1) 
                : context.cardColor,
            borderRadius: BorderRadius.circular(8), // Reduzido para 8
            border: Border.all(
              color: selected ? context.primaryColor : context.borderColor,
              width: 1.0, // Reduzido para 1.0
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
      borderRadius: BorderRadius.circular(8), // Reduzido para 8
      child: InkWell(
        onTap: () {
          // Trackear o evento se fornecido
          if (analyticsEventName != null) {
            AnalyticsService().trackEvent(
              analyticsEventName!,
              parameters: analyticsProperties ?? {'option': label},
            );
          }
          onPress();
        },
        borderRadius: BorderRadius.circular(8), // Reduzido para 8
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8), // Reduzido para 8
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Ultra compacto
              decoration: BoxDecoration(
                color: selected 
                    ? context.primaryColor.withOpacity(0.15) 
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8), // Reduzido para 8
                border: Border.all(
                  color: selected 
                      ? context.primaryColor.withOpacity(0.8) 
                      : Colors.white.withOpacity(0.2),
                  width: 1.0, // Reduzido para 1.0
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
              width: 18, // Reduzido para 18
              height: 18, // Reduzido para 18
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected 
                      ? context.primaryColor 
                      : context.isDarkMode
                          ? Colors.grey[400]! 
                          : Colors.grey[400]!,
                  width: 1.0, // Reduzido para 1.0
                ),
                color: selected ? context.primaryColor : Colors.transparent,
                boxShadow: selected && context.isDarkMode
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withOpacity(0.3),
                          blurRadius: 4, // Reduzido para 4
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 12, // Reduzido para 12
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8), // Reduzido para 8
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
                            fontSize: 14, // Reduzido para 14
                          )
                        : context.textTheme.titleMedium!.copyWith(
                            color: Colors.grey[900],
                            fontWeight: FontWeight.w500,
                            fontSize: 14, // Reduzido para 14
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2), // Reduzido para 2
                    Text(
                      description!,
                      style: context.subtitleStyle?.copyWith(
                        fontSize: 12, // Reduzido para 12
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (child != null) ...[
          const SizedBox(height: 8), // Reduzido para 8
          child!,
        ],
      ],
    );
  }
}