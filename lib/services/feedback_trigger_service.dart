import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_state.dart';
import 'package:nicotinaai_flutter/widgets/app_feedback_dialog.dart';

/// Service to handle when to show feedback prompts to users
class FeedbackTriggerService {
  // Singleton instance
  static final FeedbackTriggerService _instance = FeedbackTriggerService._internal();
  factory FeedbackTriggerService() => _instance;
  FeedbackTriggerService._internal();

  // Keys for SharedPreferences
  static const String _keyFirstOpenDate = 'feedback_first_open_date';
  static const String _keyScreensVisited = 'feedback_screens_visited';
  static const String _keyLastPromptDate = 'feedback_last_prompt_date';

  /// Initialize the service tracking
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Record first open date if not already set
    if (!prefs.containsKey(_keyFirstOpenDate)) {
      await prefs.setInt(_keyFirstOpenDate, DateTime.now().millisecondsSinceEpoch);
    }
    
    // Initialize screens visited counter if not set
    if (!prefs.containsKey(_keyScreensVisited)) {
      await prefs.setInt(_keyScreensVisited, 0);
    }
  }

  /// Track a screen visit
  Future<void> trackScreenVisit() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int screenCount = prefs.getInt(_keyScreensVisited) ?? 0;
      await prefs.setInt(_keyScreensVisited, screenCount + 1);
      
      if (kDebugMode) {
        print('🔍 [FeedbackTriggerService] Tracked screen visit: ${screenCount + 1}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FeedbackTriggerService] Error tracking screen visit: $e');
      }
    }
  }

  /// Get the number of days the user has been using the app
  Future<int> getDaysUsingApp() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int firstOpenMs = prefs.getInt(_keyFirstOpenDate) ?? DateTime.now().millisecondsSinceEpoch;
      
      final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpenMs);
      final now = DateTime.now();
      final difference = now.difference(firstOpenDate);
      
      return difference.inDays;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FeedbackTriggerService] Error getting days using app: $e');
      }
      return 0;
    }
  }

  /// Get the number of screens visited
  Future<int> getScreensVisited() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyScreensVisited) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FeedbackTriggerService] Error getting screens visited: $e');
      }
      return 0;
    }
  }

  /// Check if feedback should be shown based on last prompt date
  Future<bool> canShowFeedbackPrompt() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? lastPromptMs = prefs.getInt(_keyLastPromptDate);
      
      // If never prompted before, can show
      if (lastPromptMs == null) {
        return true;
      }
      
      // Don't show more than once per week
      final lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
      final now = DateTime.now();
      final difference = now.difference(lastPromptDate);
      
      return difference.inDays >= 7;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FeedbackTriggerService] Error checking if can show feedback: $e');
      }
      return false;
    }
  }

  /// Record that feedback prompt was shown
  Future<void> recordFeedbackPromptShown() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastPromptDate, DateTime.now().millisecondsSinceEpoch);
      
      if (kDebugMode) {
        print('✅ [FeedbackTriggerService] Recorded feedback prompt shown');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [FeedbackTriggerService] Error recording feedback prompt shown: $e');
      }
    }
  }

  /// Check if feedback should be shown based on app usage
  Future<bool> shouldShowFeedback() async {
    if (!(await canShowFeedbackPrompt())) {
      return false;
    }
    
    int daysUsingApp = await getDaysUsingApp();
    int screensVisited = await getScreensVisited();
    
    // Check the main criteria
    bool meetsCriteria = (daysUsingApp >= 3 && screensVisited >= 5) || 
                         (daysUsingApp >= 7);
    
    if (meetsCriteria) {
      if (kDebugMode) {
        print('📊 [FeedbackTriggerService] Feedback criteria met:');
        print('   - Days using app: $daysUsingApp');
        print('   - Screens visited: $screensVisited');
      }
    }
    
    return meetsCriteria;
  }

  /// Check if feedback should be shown and trigger it if needed
  Future<void> checkAndTriggerFeedback(BuildContext context) async {
    if (await shouldShowFeedback()) {
      // Get the AppFeedbackBloc
      final appFeedbackBloc = BlocProvider.of<AppFeedbackBloc>(context);
      
      // Check if we should show feedback via the bloc
      appFeedbackBloc.add(CheckFeedbackStatus(
        daysUsingApp: await getDaysUsingApp(),
        screensVisited: await getScreensVisited(),
      ));
      
      // Listen for changes in the bloc state
      appFeedbackBloc.stream.listen((state) {
        if (state is FeedbackPromptReady) {
          // Only show the dialog if the context is still active
          if (context.mounted) {
            // Show the feedback dialog
            showDialog(
              context: context,
              builder: (dialogContext) => AppFeedbackDialog(
                onClosed: () {
                  // Record that feedback was shown
                  recordFeedbackPromptShown();
                },
              ),
            );
          }
        }
      });
    }
  }
}