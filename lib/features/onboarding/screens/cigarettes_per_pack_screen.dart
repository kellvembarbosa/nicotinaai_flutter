import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';

class CigarettesPerPackScreen extends StatelessWidget {
  const CigarettesPerPackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Quantos cigarros vêm em um maço?",
      subtitle: "Selecione a quantidade padrão para seus maços de cigarros",
      content: const Center(
        child: Text("Implementação pendente"),
      ),
      onNext: () {
        provider.nextStep();
      },
    );
  }
}