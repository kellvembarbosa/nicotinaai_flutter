import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_state.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

/// Exemplo de como utilizar o sistema de analytics com BLoC
class AnalyticsExamplePage extends StatelessWidget {
  const AnalyticsExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc()..add(const InitializeAnalyticsEvent()),
      child: const AnalyticsExampleView(),
    );
  }
}

class AnalyticsExampleView extends StatelessWidget {
  const AnalyticsExampleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Example'),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status do sistema
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status do Sistema',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      StatusRow(
                        label: 'Inicializado:',
                        value: state.isInitialized ? 'Sim' : 'Não',
                        isActive: state.isInitialized,
                      ),
                      StatusRow(
                        label: 'Analytics Ativado:',
                        value: state.isAnalyticsEnabled ? 'Sim' : 'Não',
                        isActive: state.isAnalyticsEnabled,
                      ),
                      StatusRow(
                        label: 'Provedores Ativos:',
                        value: state.activeProviders.isEmpty
                            ? 'Nenhum'
                            : state.activeProviders.join(', '),
                        isActive: state.activeProviders.isNotEmpty,
                      ),
                      if (state.error != null)
                        StatusRow(
                          label: 'Erro:',
                          value: state.error!,
                          isActive: false,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Eventos básicos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eventos Básicos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionButton(
                            label: 'Log App Open',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogAppOpenEvent(),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Log Login',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogLoginEvent(method: 'email'),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Log Sign Up',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogSignUpEvent(method: 'email'),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Log Feature Use',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogFeatureUsageEvent(
                                        featureName: 'analytics_example'),
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Eventos específicos do app
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eventos do App',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionButton(
                            label: 'Milestone: 7 dias',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogSmokingFreeMilestoneEvent(7),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Craving Resistido',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogCravingResistedEvent(
                                        triggerType: 'stress'),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Recuperação: Pulmões',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogHealthRecoveryAchievedEvent(
                                        'improved_lung_function'),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Dinheiro Economizado',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogMoneySavedMilestoneEvent(
                                        100.0, 'BRL'),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Onboarding Completo',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const LogCompletedOnboardingEvent(),
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Evento personalizado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evento Personalizado',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AnalyticsBloc>().add(
                                TrackCustomEvent(
                                  'custom_event',
                                  parameters: {
                                    'timestamp': DateTime.now().toIso8601String(),
                                    'user_level': 5,
                                    'is_premium': false,
                                  },
                                ),
                              );
                        },
                        child: const Text('Enviar Evento Personalizado'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Administração de provedores
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gerenciar Provedores',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionButton(
                            label: 'Adicionar PostHog',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    AddAnalyticsProviderEvent(
                                      'PostHog',
                                      providerConfig: {
                                        'apiKey': 'phc_YOUR_API_KEY',
                                        'host': 'https://app.posthog.com',
                                      },
                                    ),
                                  );
                            },
                          ),
                          ActionButton(
                            label: 'Remover Facebook',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    const RemoveAnalyticsProviderEvent('Facebook'),
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Configurações de usuário
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Propriedades do Usuário',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AnalyticsBloc>().add(
                                const SetUserPropertiesEvent(
                                  userId: 'user123',
                                  email: 'user@example.com',
                                  daysSmokeFree: 30,
                                  cigarettesPerDay: 20,
                                  pricePerPack: 10.0,
                                  currency: 'BRL',
                                  additionalProperties: {
                                    'app_version': '1.0.0',
                                    'is_premium': true,
                                  },
                                ),
                              );
                        },
                        child: const Text('Definir Propriedades do Usuário'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AnalyticsBloc>().add(
                                const ClearUserDataEvent(),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Limpar Dados do Usuário'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;

  const StatusRow({
    Key? key,
    required this.label,
    required this.value,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

/// Como usar o AnalyticsService diretamente sem o BLoC
class DirectAnalyticsUsageExample {
  static void example() {
    final analyticsService = AnalyticsService();
    
    // Inicializar o serviço
    analyticsService.initialize();
    
    // Adicionar um provedor PostHog
    analyticsService.addAdapter('PostHog', config: {
      'apiKey': 'phc_YOUR_API_KEY',
      'host': 'https://app.posthog.com',
    });
    
    // Registrar eventos
    analyticsService.trackEvent('button_click', parameters: {'button_id': 'login'});
    analyticsService.logLogin(method: 'email');
    analyticsService.logSmokingFreeMilestone(7);
    
    // Definir propriedades do usuário
    analyticsService.setUserProperties(
      userId: 'user123',
      email: 'user@example.com',
      daysSmokeFree: 30,
    );
    
    // Limpar dados do usuário
    analyticsService.clearUserData();
  }
}