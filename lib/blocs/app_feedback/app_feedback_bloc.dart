import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_state.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';

class AppFeedbackBloc extends Bloc<AppFeedbackEvent, AppFeedbackState> {
  final AppFeedbackService _feedbackService;

  // State variables
  bool _isSatisfied = false;
  AppRating? _rating;
  
  AppFeedbackBloc({required AppFeedbackService feedbackService})
      : _feedbackService = feedbackService,
        super(AppFeedbackInitial()) {
    on<CheckFeedbackStatus>(_onCheckFeedbackStatus);
    on<SubmitSatisfaction>(_onSubmitSatisfaction);
    on<SubmitRating>(_onSubmitRating);
    on<SubmitFeedbackText>(_onSubmitFeedbackText);
    on<MarkAppReviewed>(_onMarkAppReviewed);
    on<DismissFeedbackPrompt>(_onDismissFeedbackPrompt);
  }

  Future<void> _onCheckFeedbackStatus(
    CheckFeedbackStatus event,
    Emitter<AppFeedbackState> emit,
  ) async {
    try {
      final shouldShow = await _feedbackService.shouldShowFeedbackPrompt(
        daysUsingApp: event.daysUsingApp,
        screensVisited: event.screensVisited,
      );
      
      if (shouldShow) {
        emit(FeedbackPromptReady());
      }
    } catch (e) {
      // If there's an error checking status, don't show feedback prompt
      print('Error checking feedback status: $e');
    }
  }

  Future<void> _onSubmitSatisfaction(
    SubmitSatisfaction event,
    Emitter<AppFeedbackState> emit,
  ) async {
    _isSatisfied = event.isSatisfied;
    
    // If user is not satisfied, we'll collect text feedback
    if (!_isSatisfied) {
      emit(SatisfactionSubmitted(_isSatisfied));
      return;
    }
    
    // If user is satisfied, we'll ask for a rating
    emit(SatisfactionSubmitted(_isSatisfied));
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<AppFeedbackState> emit,
  ) async {
    try {
      _rating = event.rating;
      
      // High ratings (4-5) should prompt for app store review
      final isHighRating = event.rating == AppRating.four || event.rating == AppRating.five;
      
      final success = await _feedbackService.submitSatisfactionFeedback(
        isSatisfied: _isSatisfied,
        rating: event.rating,
        hasReviewedApp: false,
      );
      
      if (success) {
        if (isHighRating) {
          // For high ratings, we'll prompt for app store review
          emit(RatingSubmitted(event.rating));
        } else {
          // For lower ratings, we're done
          emit(FeedbackCompleted());
        }
      } else {
        emit(const FeedbackError('Failed to submit rating'));
      }
    } catch (e) {
      emit(FeedbackError('Error: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitFeedbackText(
    SubmitFeedbackText event,
    Emitter<AppFeedbackState> emit,
  ) async {
    try {
      final success = await _feedbackService.submitSatisfactionFeedback(
        isSatisfied: _isSatisfied,
        feedbackText: event.feedbackText,
        feedbackCategory: event.feedbackCategory,
      );
      
      if (success) {
        emit(FeedbackCompleted());
      } else {
        emit(const FeedbackError('Failed to submit feedback'));
      }
    } catch (e) {
      emit(FeedbackError('Error: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAppReviewed(
    MarkAppReviewed event,
    Emitter<AppFeedbackState> emit,
  ) async {
    try {
      await _feedbackService.markAppReviewed();
      emit(FeedbackCompleted());
    } catch (e) {
      // Even if there's an error, we'll consider this completed
      emit(FeedbackCompleted());
    }
  }

  void _onDismissFeedbackPrompt(
    DismissFeedbackPrompt event,
    Emitter<AppFeedbackState> emit,
  ) {
    emit(FeedbackDismissed());
  }
}