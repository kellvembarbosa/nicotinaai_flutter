import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';

class ProductTypeScreen extends StatelessWidget {
  const ProductTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return OnboardingContainer(
      title: "Que tipo de produto você consome?",
      subtitle: "Selecione o que se aplica a você",
      content: const Center(
        child: Text("Implementação pendente"),
      ),
      onNext: () {
        provider.nextStep();
      },
    );
  }
}