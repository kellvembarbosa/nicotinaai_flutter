import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';

// Events
abstract class AppFeedbackEvent extends Equatable {
  const AppFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class CheckFeedbackStatus extends AppFeedbackEvent {
  final int daysUsingApp;
  final int screensVisited;

  const CheckFeedbackStatus({
    required this.daysUsingApp,
    required this.screensVisited,
  });

  @override
  List<Object?> get props => [daysUsingApp, screensVisited];
}

class SubmitSatisfaction extends AppFeedbackEvent {
  final bool isSatisfied;

  const SubmitSatisfaction({required this.isSatisfied});

  @override
  List<Object?> get props => [isSatisfied];
}

class SubmitRating extends AppFeedbackEvent {
  final AppRating rating;

  const SubmitRating({required this.rating});

  @override
  List<Object?> get props => [rating];
}

class SubmitFeedbackText extends AppFeedbackEvent {
  final String feedbackText;
  final String feedbackCategory;

  const SubmitFeedbackText({
    required this.feedbackText,
    required this.feedbackCategory,
  });

  @override
  List<Object?> get props => [feedbackText, feedbackCategory];
}

class MarkAppReviewed extends AppFeedbackEvent {}

class DismissFeedbackPrompt extends AppFeedbackEvent {}