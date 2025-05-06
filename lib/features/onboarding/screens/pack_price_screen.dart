import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';

class PackPriceScreen extends StatelessWidget {
  const PackPriceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Quanto custa um maço de cigarros?",
      subtitle: "Isso nos ajuda a calcular sua economia financeira",
      content: const Center(
        child: Text("Implementação pendente"),
      ),
      onNext: () {
        provider.nextStep();
      },
    );
  }
}