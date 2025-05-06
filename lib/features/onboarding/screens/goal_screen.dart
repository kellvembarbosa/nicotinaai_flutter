import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Qual é o seu objetivo?",
      subtitle: "Selecione o que você deseja alcançar",
      content: const Center(
        child: Text("Implementação pendente"),
      ),
      onNext: () {
        provider.nextStep();
      },
    );
  }
}