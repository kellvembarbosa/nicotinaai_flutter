import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:nicotinaai_flutter/services/analytics/analytics_service.dart';

/// Exemplo de como configurar e usar o PostHog no aplicativo
class PostHogExample extends StatelessWidget {
  const PostHogExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostHog Implementation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usando o BLoC
            ElevatedButton(
              onPressed: () {
                // API KEY do PostHog
                const apiKey = 'phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c';
                
                // Adicionar o PostHog ao aplicativo via BLoC
                context.read<AnalyticsBloc>().add(
                  AddAnalyticsProviderEvent(
                    'PostHog',
                    providerConfig: {
                      'apiKey': apiKey,
                      'host': 'https://us.i.posthog.com', // Host correto
                    },
                  ),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PostHog adicionado via BLoC!')),
                );
              },
              child: const Text('Adicionar PostHog via BLoC'),
            ),
            
            const SizedBox(height: 16),
            
            // Usando o serviço diretamente
            ElevatedButton(
              onPressed: () {
                // API KEY do PostHog
                const apiKey = 'phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c';
                
                // Adicionar o PostHog ao aplicativo diretamente via serviço
                AnalyticsService().addAdapter(
                  'PostHog',
                  config: {
                    'apiKey': apiKey,
                    'host': 'https://us.i.posthog.com', // Host correto
                  },
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PostHog adicionado via Serviço!')),
                );
              },
              child: const Text('Adicionar PostHog via Serviço'),
            ),
            
            const SizedBox(height: 32),
            
            // Enviar eventos via BLoC
            ElevatedButton(
              onPressed: () {
                context.read<AnalyticsBloc>().add(
                  const TrackCustomEvent(
                    'button_clicked',
                    parameters: {
                      'button_name': 'test_button',
                      'screen': 'posthog_example',
                    },
                  ),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evento enviado via BLoC!')),
                );
              },
              child: const Text('Enviar Evento via BLoC'),
            ),
            
            const SizedBox(height: 16),
            
            // Enviar eventos diretamente
            ElevatedButton(
              onPressed: () {
                AnalyticsService().trackEvent(
                  'button_clicked_direct',
                  parameters: {
                    'button_name': 'test_button_direct',
                    'screen': 'posthog_example',
                  },
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evento enviado via Serviço!')),
                );
              },
              child: const Text('Enviar Evento via Serviço'),
            ),
            
            const SizedBox(height: 32),
            
            // Configurar usuário
            ElevatedButton(
              onPressed: () {
                context.read<AnalyticsBloc>().add(
                  const SetUserPropertiesEvent(
                    userId: 'example_user_123',
                    email: 'user@example.com',
                    daysSmokeFree: 30,
                    additionalProperties: {
                      'subscription_type': 'premium',
                      'app_version': '1.1.0',
                    },
                  ),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Propriedades do usuário definidas!')),
                );
              },
              child: const Text('Definir Propriedades do Usuário'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exemplo de como configurar o PostHog no main.dart
void configurePostHogInMainExample() {
  // Este método seria chamado no main() do aplicativo
  
  // API KEY do PostHog
  const apiKey = 'phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c';
  
  // Inicializar o serviço de analytics
  try {
    // Primeiro inicializa o serviço (que adicionará Facebook por padrão)
    final analyticsService = AnalyticsService();
    analyticsService.initialize();
    
    // Depois adiciona o PostHog
    analyticsService.addAdapter(
      'PostHog',
      config: {
        'apiKey': apiKey,
        'host': 'https://us.i.posthog.com', // Host correto
      },
    );
    
    // Registrar evento de abertura do app
    analyticsService.logAppOpen();
    
    debugPrint('✅ Analytics service with PostHog initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Analytics initialization error: $e');
    // Continue without analytics if it fails
  }
}