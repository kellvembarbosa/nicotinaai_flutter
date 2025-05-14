import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_state.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Dialog to collect app feedback from users during normal app usage
class AppFeedbackDialog extends StatelessWidget {
  final VoidCallback? onClosed;

  const AppFeedbackDialog({Key? key, this.onClosed}) : super(key: key);

  final InAppReview _inAppReview = InAppReview.instance;
  
  Future<void> _requestReview() async {
    // Check if the store is available
    final isAvailable = await _inAppReview.isAvailable();
    
    if (isAvailable) {
      try {
        // Request the review
        await _inAppReview.requestReview();
      } catch (e) {
        // Fallback to opening the store page if requesting review fails
        await _openStorePage();
      }
    } else {
      // If in-app review is not available, open the store listing
      await _openStorePage();
    }
  }
  
  Future<void> _openStorePage() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '6744342233', // App Store ID
      );
    } catch (e) {
      print('Error opening store page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppFeedbackBloc, AppFeedbackState>(
      listener: (context, state) {
        if (state is FeedbackCompleted || state is FeedbackDismissed) {
          // Close the dialog when feedback is completed or dismissed
          Navigator.of(context).pop();
          // Call the onClosed callback if provided
          onClosed?.call();
        }
      },
      builder: (context, state) {
        // Get localizations
        final l10n = AppLocalizations.of(context)!;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildContent(context, state, l10n),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AppFeedbackState state, AppLocalizations l10n) {
    if (state is SatisfactionSubmitted) {
      return state.isSatisfied
          ? _buildRatingScreen(context, l10n)
          : _buildFeedbackFormScreen(context, l10n);
    } else if (state is RatingSubmitted) {
      return _buildReviewRequestScreen(context, l10n);
    } else if (state is FeedbackError) {
      return _buildErrorScreen(context, state.message, l10n);
    } else {
      // Default (initial) screen
      return _buildSatisfactionScreen(context, l10n);
    }
  }

  Widget _buildSatisfactionScreen(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.thumb_up_alt_outlined,
            size: 60,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.howIsYourExperience,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.enjoyingApp,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    context.read<AppFeedbackBloc>().add(
                          const SubmitSatisfaction(isSatisfied: false),
                        );
                  },
                  child: Text(l10n.notReally),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    context.read<AppFeedbackBloc>().add(
                          const SubmitSatisfaction(isSatisfied: true),
                        );
                  },
                  child: Text(l10n.yesImEnjoying),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
            },
            child: Text(l10n.skip),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingScreen(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_outline,
            size: 60,
            color: Colors.amber,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.rateApp,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.yourOpinionMatters,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 4, 5].map((rating) {
              return _buildRatingStar(
                context,
                rating, 
                onTap: () {
                  context.read<AppFeedbackBloc>().add(
                        SubmitRating(
                          rating: AppRating.values[rating - 1],
                        ),
                      );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
            },
            child: Text(l10n.later),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStar(BuildContext context, int rating, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 36,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            rating.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackFormScreen(BuildContext context, AppLocalizations l10n) {
    final TextEditingController feedbackController = TextEditingController();
    
    return StatefulBuilder(
      builder: (context, setState) {
        String selectedCategory = 'Interface';
        
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Icon(
                  Icons.feedback_outlined,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  l10n.tellUsIssues,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n.helpUsImprove,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.feedbackCategory,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Interface',
                  'Features',
                  'Performance',
                  'Accuracy of statistics',
                  'Notifications',
                  'Other',
                ].map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.yourFeedback,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.describeProblem,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
                      },
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (feedbackController.text.trim().isNotEmpty) {
                          context.read<AppFeedbackBloc>().add(
                                SubmitFeedbackText(
                                  feedbackText: feedbackController.text.trim(),
                                  feedbackCategory: selectedCategory,
                                ),
                              );
                        }
                      },
                      child: Text(l10n.sendFeedback),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewRequestScreen(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 60,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.thankYouForFeedback,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.rateAppStore,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              // Request in-app review and mark as reviewed
              await _requestReview();
              context.read<AppFeedbackBloc>().add(MarkAppReviewed());
            },
            child: Text(l10n.rateNow),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.read<AppFeedbackBloc>().add(MarkAppReviewed());
            },
            child: Text(l10n.alreadyRated),
          ),
          TextButton(
            onPressed: () {
              context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
            },
            child: Text(l10n.later),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.feedbackError,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.couldNotSaveFeedback}: $message',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
            },
            child: Text(l10n.understand),
          ),
        ],
      ),
    );
  }
}