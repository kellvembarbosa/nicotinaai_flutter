import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Quando você deseja alcançar seu objetivo?",
      subtitle: "Estabeleça um prazo que pareça alcançável para você",
      content: const Center(
        child: Text("Implementação pendente"),
      ),
      onNext: () {
        provider.nextStep();
      },
    );
  }
}