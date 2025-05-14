import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_bloc.dart';
import 'package:nicotinaai_flutter/blocs/app_feedback/app_feedback_event.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
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
              // Avança para a tela de conclusão (CompletionScreen)
              context.read<OnboardingBloc>().add(NextOnboardingStep());
            },
            child: Text(l10n.skip),
          ),
        ],
      ),
      // Desativar drag para esconder o teclado facilmente ao tocar fora
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: OnboardingFeedbackScreen(
          onComplete: () {
            // Avança para a tela de conclusão (CompletionScreen)
            context.read<OnboardingBloc>().add(NextOnboardingStep());
          },
        ),
      ),
    );
  }
}