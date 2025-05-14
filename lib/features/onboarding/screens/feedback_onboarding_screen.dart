import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/widgets/onboarding_feedback_screen.dart';

class FeedbackOnboardingScreen extends StatelessWidget {
  const FeedbackOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedbackTitle),
        actions: [
          TextButton(
            onPressed: () {
              context.go(AppRoutes.main.path);
            },
            child: Text(l10n.skip),
          ),
        ],
      ),
      body: OnboardingFeedbackScreen(
        onComplete: () {
          context.go(AppRoutes.main.path);
        },
      ),
    );
  }
}