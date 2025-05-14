import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

enum AppRating {
  one('1'),
  two('2'),
  three('3'),
  four('4'),
  five('5');

  final String value;
  const AppRating(this.value);

  static AppRating fromString(String value) {
    return AppRating.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppRating.five,
    );
  }
}

class AppFeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Verifies if the user has already provided feedback
  Future<bool> hasProvidedFeedback() async {
    try {
      final response = await _supabase
          .from('user_feedback')
          .select()
          .limit(1)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      // If there's an error, we'll assume no feedback yet
      return false;
    }
  }

  /// Submit user satisfaction feedback
  /// Returns true if the feedback was successfully submitted
  Future<bool> submitSatisfactionFeedback({
    required bool isSatisfied,
    AppRating? rating,
    String? feedbackText,
    String? feedbackCategory,
    bool? hasReviewedApp,
  }) async {
    try {
      // Call the edge function to handle the feedback
      final response = await _supabase.functions.invoke(
        'app-feedback',
        body: {
          'is_satisfied': isSatisfied,
          if (rating != null) 'rating': rating.value,
          if (feedbackText != null) 'feedback_text': feedbackText,
          if (feedbackCategory != null) 'feedback_category': feedbackCategory,
          if (hasReviewedApp != null) 'has_reviewed_app': hasReviewedApp,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Unknown error';
        throw Exception('Failed to submit feedback: $error');
      }

      return true;
    } catch (e) {
      // Log the error and return false
      print('Error submitting feedback: $e');
      return false;
    }
  }

  /// Mark that the user has reviewed the app in the store
  Future<bool> markAppReviewed() async {
    try {
      await _supabase
          .from('user_feedback')
          .update({'has_reviewed_app': true})
          .eq('user_id', _supabase.auth.currentUser!.id);
      
      return true;
    } catch (e) {
      print('Error marking app as reviewed: $e');
      return false;
    }
  }

  /// Determine if feedback should be shown based on app usage
  /// This is a helper method for UI components to decide when to prompt for feedback
  Future<bool> shouldShowFeedbackPrompt({
    required int daysUsingApp,
    required int screensVisited,
  }) async {
    // Don't show if user already gave feedback
    if (await hasProvidedFeedback()) {
      return false;
    }
    
    // Show on 3rd day of usage and after visiting at least 5 screens
    if (daysUsingApp >= 3 && screensVisited >= 5) {
      return true;
    }
    
    // Show after 7 days if not shown earlier
    if (daysUsingApp >= 7) {
      return true;
    }
    
    return false;
  }
}