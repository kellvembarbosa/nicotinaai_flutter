import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_bloc.dart';
import 'package:nicotinaai_flutter/blocs/onboarding/onboarding_event.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_bloc.dart';
import 'package:nicotinaai_flutter/blocs/analytics/analytics_event.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({Key? key}) : super(key: key);
  
  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}
  
class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  // Estado para controlar o carregamento e permissão
  bool _isRequestingPermission = false;
  bool _permissionGranted = false;
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return OnboardingContainer(
      title: localizations.stayInformed,
      subtitle: localizations.receiveTimelyCues,
      contentType: OnboardingContentType.scrollable, // Alterado de regular para scrollable para garantir rolagem
      screenName: 'notification_permission',
      // Usamos SingleChildScrollView para envolver a Column e evitar overflow
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Imagem ilustrativa de notificação - reduzindo a altura para economizar espaço
            Container(
              width: double.infinity,
              height: 180, // Reduzido de 200 para 180
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_active,
                size: 80, // Reduzido de 100 para 80
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 20), // Reduzido de 32 para 20
            
            // Título destacado
            Text(
              localizations.importantReminders,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16), // Reduzido de 24 para 16
            
            // Texto explicativo
            Text(
              localizations.notificationsHelp,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24), // Reduzido de 32 para 24
            
            // Botão principal para solicitar permissão
            if (!_permissionGranted)
              ElevatedButton.icon(
                onPressed: _isRequestingPermission ? null : () => _requestNotificationPermission(context),
                icon: const Icon(Icons.notifications_active),
                label: Text(_isRequestingPermission 
                  ? localizations.requesting 
                  : localizations.allowNotifications),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.notificationsEnabled,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Texto opcional para pular
            TextButton(
              onPressed: () {
                // Track skipping notifications
                context.read<AnalyticsBloc>().add(
                  const TrackCustomEvent(
                    'onboarding_notifications_skipped',
                  ),
                );
                // Avançar para a próxima tela
                context.read<OnboardingBloc>().add(NextOnboardingStep());
              },
              child: Text(localizations.skipForNow),
            ),
            
            // Espaço final reduzido
            const SizedBox(height: 20), // Reduzido de 40 para 20
          ],
        ),
      ),
      // Não precisamos de um botão "Próximo" padrão, pois temos os botões customizados
      showBackButton: true,
      canProceed: true,
      isLoading: _isRequestingPermission,
      onNext: () {
        // Se a permissão já foi concedida, avançar automaticamente
        if (_permissionGranted) {
          context.read<AnalyticsBloc>().add(
            const TrackCustomEvent(
              'onboarding_notifications_allowed',
            ),
          );
          context.read<OnboardingBloc>().add(NextOnboardingStep());
        } else {
          // Se não, solicitar a permissão primeiro
          _requestNotificationPermission(context);
        }
      },
      nextButtonText: localizations.continueButton,
    );
  }
  
  /// Solicita permissão para notificações
  Future<void> _requestNotificationPermission(BuildContext context) async {
    // Preparar parâmetros de evento para analytics
    final Map<String, dynamic> eventParams = {
      'device_platform': Theme.of(context).platform.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Track request attempt with parameters
    context.read<AnalyticsBloc>().add(
      TrackCustomEvent(
        'onboarding_notifications_requested',
        parameters: eventParams,
      ),
    );
    
    // Atualizar estado para mostrar carregamento
    setState(() {
      _isRequestingPermission = true;
    });
    
    try {
      // Solicitar permissão para notificações
      final settings = await NotificationService().requestPermission();
      debugPrint('Permission status: ${settings.authorizationStatus}');
      _permissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      // Tentar obter e salvar token FCM apenas se a permissão foi concedida
      if (_permissionGranted) {
        try {
          final fcmToken = await NotificationService().getToken();
          if (fcmToken != null) {
            debugPrint('FCM Token obtido: $fcmToken');
            
            // Salvar token no banco de dados (em segundo plano)
            NotificationService().saveTokenToDatabase(fcmToken);
            
            // Inscrever em tópicos relevantes
            await NotificationService().subscribeToTopic('all_users');
            await NotificationService().subscribeToTopic('onboarding_users');
          } else {
            debugPrint('FCM Token não obtido: null');
          }
        } catch (tokenError) {
          // Erro ao obter token FCM, mas permissão foi concedida
          debugPrint('Erro ao obter/salvar token FCM: $tokenError');
          // Não falhar completamente, já que a permissão ainda foi concedida
        }
      }
      
      // Atualizar estado para mostrar sucesso mesmo se o token falhar
      // O importante é que a permissão foi concedida
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
        
        if (_permissionGranted) {
          setState(() {
            _permissionGranted = true;
          });
          
          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(AppLocalizations.of(context).notificationsEnabled),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Track success com parâmetros
          context.read<AnalyticsBloc>().add(
            TrackCustomEvent(
              'onboarding_notifications_allowed',
              parameters: {
                ...eventParams,
                'status': settings.authorizationStatus.toString(),
              },
            ),
          );
          
          // Aguardar um momento para mostrar o feedback visual antes de avançar
          await Future.delayed(const Duration(milliseconds: 1500));
          
          // Avançar para a próxima tela
          if (mounted) {
            context.read<OnboardingBloc>().add(NextOnboardingStep());
          }
        } else {
          // Permissão não foi concedida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).notificationPermissionFailed),
              backgroundColor: Colors.orange, // Laranja para indicar que não é um erro técnico
            ),
          );
          
          // Track declined
          context.read<AnalyticsBloc>().add(
            TrackCustomEvent(
              'onboarding_notifications_declined',
              parameters: {
                ...eventParams,
                'status': settings.authorizationStatus.toString(),
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao solicitar permissão de notificação: $e');
      
      // Track failure com informações de erro
      context.read<AnalyticsBloc>().add(
        TrackCustomEvent(
          'onboarding_notifications_failed',
          parameters: {
            ...eventParams,
            'error': e.toString(),
            'error_type': e.runtimeType.toString(),
          },
        ),
      );
      
      // Resetar estado e mostrar erro
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).notificationPermissionFailed}. ${e is FirebaseException ? 'Firebase error: ${e.code}' : ''}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}