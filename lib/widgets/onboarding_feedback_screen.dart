import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_state.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/app_feedback_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingFeedbackScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFeedbackScreen({
    super.key, 
    required this.onComplete,
  });

  @override
  State<OnboardingFeedbackScreen> createState() => _OnboardingFeedbackScreenState();
}

class _OnboardingFeedbackScreenState extends State<OnboardingFeedbackScreen> {
  // Used for in-app review
  final InAppReview _inAppReview = InAppReview.instance;
  bool _hasTriggeredReview = false;
  
  // Request in-app review
  Future<void> _requestInAppReview() async {
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
      // Fallback to direct store links if needed
      await _launchStoreUrl();
    }
  }
  
  Future<void> _launchStoreUrl() async {
    // Replace with your actual app store links
    final Uri appStoreUrl = Uri.parse('https://apps.apple.com/app/id6744342233');
    final Uri playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=app.nicotina.ai');
    
    // Choose the right URL based on platform
    final Uri url = Theme.of(context).platform == TargetPlatform.iOS
        ? appStoreUrl
        : playStoreUrl;

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppFeedbackBloc, AppFeedbackState>(
      listener: (context, state) {
        if (state is FeedbackCompleted || state is FeedbackDismissed) {
          widget.onComplete();
        }
      },
      builder: (context, state) {
        if (state is FeedbackLoading) {
          return _buildLoadingScreen(context);
        } else if (state is SatisfactionSubmitted) {
          return state.isSatisfied
              ? _buildRatingScreen(context)
              : _buildFeedbackFormScreen(context);
        } else if (state is RatingSubmitted) {
          return _buildReviewRequestScreen(context);
        } else if (state is FeedbackError) {
          return _buildErrorScreen(context, state.message);
        }
        
        // Default (initial) screen
        return _buildSatisfactionScreen(context);
      },
    );
  }
  
  Widget _buildLoadingScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              l10n.loading,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.howIsYourExperience,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.weAreConstantlyImproving,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        context.read<AppFeedbackBloc>().add(
                              const SubmitSatisfaction(isSatisfied: true),
                            );
                      },
                      child: Text(l10n.yesILikeIt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
                },
                child: Text(l10n.skip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_outline,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.howWouldYouRateApp,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.yourOpinionMatters,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
                },
                child: Text(l10n.later),
              ),
            ],
          ),
        ),
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
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            rating.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackFormScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final TextEditingController feedbackController = TextEditingController();
    final focusNode = FocusNode();
    
    return StatefulBuilder(
      builder: (context, setState) {
        String selectedCategory = 'Interface';
        
        return GestureDetector(
          // Fecha o teclado quando clicar fora do campo de texto
          onTap: () => focusNode.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.feedback_outlined,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        l10n.whatCouldBeBetter,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        l10n.helpUsImprove,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                        l10n.interface, 
                        l10n.features,
                        l10n.performance,
                        l10n.statisticsAccuracy,
                        l10n.notifications,
                        l10n.other,
                      ].map((category) {
                        return DropdownMenuItem<String>(
                          value: category.toString(),
                          child: Text(category.toString()),
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
                      focusNode: focusNode,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10n.describeWhatToImprove,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (feedbackController.text.trim().isNotEmpty) {
                                // Esconder o teclado antes de enviar
                                focusNode.unfocus();
                                context.read<AppFeedbackBloc>().add(
                                      SubmitFeedbackText(
                                        feedbackText: feedbackController.text.trim(),
                                        feedbackCategory: selectedCategory,
                                      ),
                                    );
                                
                                // Ao completar, o listener do Bloc vai chamar onComplete
                                // que vai chamar context.read<OnboardingBloc>().add(NextOnboardingStep());
                              }
                            },
                            child: Text(l10n.sendFeedback),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewRequestScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Automatically request in-app review when this screen is shown for ratings 4-5
    if (!_hasTriggeredReview) {
      _hasTriggeredReview = true;
      Future.microtask(() async {
        if (mounted) {
          await _requestInAppReview();
          
          // Mark as reviewed after showing the review prompt
          if (mounted) {
            context.read<AppFeedbackBloc>().add(MarkAppReviewed());
            
            // Aguardamos um breve momento e avançamos para a próxima tela
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<OnboardingBloc>().add(NextOnboardingStep());
              }
            });
          }
        }
      });
    }
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.gladYouLikeIt,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.wouldYouRateOnStore,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  // Em caso de falha da solicitação automática, permite acionamento manual
                  await _requestInAppReview();
                  context.read<AppFeedbackBloc>().add(MarkAppReviewed());
                  
                  // Avança para a próxima tela após completar
                  context.read<OnboardingBloc>().add(NextOnboardingStep());
                },
                child: Text(l10n.rateNow),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AppFeedbackBloc>().add(MarkAppReviewed());
                  
                  // Avança para a próxima tela
                  context.read<OnboardingBloc>().add(NextOnboardingStep());
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
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.somethingWentWrong,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.couldNotSaveFeedback}: $message',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  context.read<AppFeedbackBloc>().add(DismissFeedbackPrompt());
                  
                  // Avança para a próxima tela mesmo com erro
                  context.read<OnboardingBloc>().add(NextOnboardingStep());
                },
                child: Text(l10n.understood),
              ),
            ],
          ),
        ),
      ),
    );
  }
}