import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_bloc.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_event.dart';
import 'package:nicotinaai_flutter/blocs/achievement/achievement_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';

import '../models/time_period.dart';

class TimePeriodSelector extends StatelessWidget {
  const TimePeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        final selectedPeriod = state.selectedTimePeriod;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
            boxShadow: context.isDarkMode 
                ? null 
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _buildLabel(context),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TimePeriod.values.map((period) => 
                      _buildPeriodOption(context, period, period == selectedPeriod)
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLabel(BuildContext context) {
    return Text(
      'Show:',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: context.subtitleColor,
      ),
    );
  }
  
  Widget _buildPeriodOption(BuildContext context, TimePeriod period, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              period.icon,
              size: 16,
              color: isSelected ? Colors.white : context.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              period.displayName(context),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : context.contentColor,
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedColor: context.primaryColor,
        backgroundColor: context.isDarkMode 
            ? Colors.grey.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected 
                ? context.primaryColor 
                : Colors.transparent,
            width: 1,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            context.read<AchievementBloc>().add(ChangeTimePeriod(period));
          }
        },
      ),
    );
  }
}