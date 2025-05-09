import 'package:flutter/material.dart';

/// Defines time periods for achievements filtering
enum TimePeriod {
  day,
  week,
  month,
  allTime;
  
  /// Get the display name for this time period
  String displayName(BuildContext context) {
    switch (this) {
      case TimePeriod.day:
        return 'Today';
      case TimePeriod.week:
        return 'This Week';
      case TimePeriod.month:
        return 'This Month';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }
  
  /// Get an icon for this time period
  IconData get icon {
    switch (this) {
      case TimePeriod.day:
        return Icons.today;
      case TimePeriod.week:
        return Icons.view_week;
      case TimePeriod.month:
        return Icons.calendar_month;
      case TimePeriod.allTime:
        return Icons.all_inclusive;
    }
  }
  
  /// Check if a DateTime falls within this time period
  bool contains(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (this) {
      case TimePeriod.day:
        // Check if the date is today
        return dateTime.isAfter(today) || 
               (dateTime.year == today.year && 
                dateTime.month == today.month && 
                dateTime.day == today.day);
                
      case TimePeriod.week:
        // Find start of week (Sunday)
        final startOfWeek = today.subtract(Duration(days: today.weekday));
        return dateTime.isAfter(startOfWeek);
        
      case TimePeriod.month:
        // First day of the current month
        final startOfMonth = DateTime(now.year, now.month, 1);
        return dateTime.isAfter(startOfMonth) || 
               (dateTime.year == startOfMonth.year && 
                dateTime.month == startOfMonth.month && 
                dateTime.day == startOfMonth.day);
                
      case TimePeriod.allTime:
        // All time includes all dates
        return true;
    }
  }
}