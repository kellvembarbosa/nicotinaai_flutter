import 'package:equatable/equatable.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';

// States
abstract class AppFeedbackState extends Equatable {
  const AppFeedbackState();

  @override
  List<Object?> get props => [];
}

class AppFeedbackInitial extends AppFeedbackState {}

class FeedbackPromptReady extends AppFeedbackState {}

class FeedbackLoading extends AppFeedbackState {}

class SatisfactionSubmitted extends AppFeedbackState {
  final bool isSatisfied;

  const SatisfactionSubmitted(this.isSatisfied);

  @override
  List<Object?> get props => [isSatisfied];
}

class RatingSubmitted extends AppFeedbackState {
  final AppRating rating;

  const RatingSubmitted(this.rating);

  @override
  List<Object?> get props => [rating];
}

class FeedbackCompleted extends AppFeedbackState {}

class FeedbackError extends AppFeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedbackDismissed extends AppFeedbackState {}