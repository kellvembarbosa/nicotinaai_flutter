import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/providers/onboarding_provider.dart';
import 'package:nicotinaai_flutter/features/onboarding/screens/onboarding_container.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicotinaai_flutter/services/notification_service.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);
  
  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}
  
class _IntroductionScreenState extends State<IntroductionScreen> {
  // Estado para o indicador de carregamento
  bool _isRequestingNotification = false;
  
  /// Método para solicitar notificações FCM de forma não bloqueante
  void _requestFCMNotification(BuildContext context) {
    // Não solicitar se já estiver em andamento
    if (_isRequestingNotification) return;
    
    // Atualizar estado para mostrar o indicador de carregamento
    setState(() {
      _isRequestingNotification = true;
    });
    
    // Executar em segundo plano
    Future.microtask(() async {
      try {
        // Obter o token FCM
        final fcmToken = await NotificationService().getToken();
        
        if (fcmToken != null && mounted) {
          debugPrint('FCM Token: $fcmToken');
          
          // Salvar o token no banco de dados se o usuário estiver logado
          // Executa em segundo plano sem bloquear
          NotificationService().saveTokenToDatabase(fcmToken);
          
          // Inscrever o usuário em tópicos relevantes (também em segundo plano)
          NotificationService().subscribeToTopic('all_users');
          NotificationService().subscribeToTopic('onboarding_users');
          
          // Mostrar toast ou diálogo apenas se ainda estiver montado
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notificações ativadas com sucesso! Você receberá dicas e lembretes para ajudar na sua jornada.',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          
          // Não enviar notificação de teste para não sobrecarregar o usuário
          // Em vez disso, apenas registramos que o token foi obtido com sucesso
          debugPrint('Token FCM obtido com sucesso, notificações estão ativas');
        }
      } catch (e) {
        debugPrint('Erro ao obter token FCM: $e');
        if (mounted) {
          // Mostrar um erro caso ocorra algum problema
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Não foi possível ativar as notificações: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        // Resetar o estado de carregamento se ainda estiver montado
        if (mounted) {
          setState(() {
            _isRequestingNotification = false;
          });
        }
      }
    });
  }
  
  /// Envia uma notificação de teste para o dispositivo
  Future<void> _sendTestNotification(String token) async {
    // Esta função é apenas para fins de demonstração
    // Normalmente, você enviaria a notificação de um servidor backend
    debugPrint('Enviando notificação de teste para token: $token');
    
    // Aqui você implementaria a chamada para seu servidor para enviar a notificação
    // Como estamos no cliente, apenas simulamos que a notificação foi enviada
    
    // Em um cenário real, você faria uma solicitação HTTP para seu servidor:
    // final response = await http.post(
    //   Uri.parse('https://seuservidor.com/api/send-notification'),
    //   body: json.encode({
    //     'token': token,
    //     'title': 'Bem-vindo ao NicotinaAI',
    //     'body': 'Obrigado por se juntar à nossa comunidade. Estamos aqui para ajudar em sua jornada!'
    //   }),
    //   headers: {'Content-Type': 'application/json'},
    // );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final localizations = AppLocalizations.of(context);

    return OnboardingContainer(
      title: localizations.welcomeToNicotinaAI,
      subtitle: localizations.personalAssistant,
      showBackButton: false,
      nextButtonText: localizations.start,
      contentType: OnboardingContentType.regular,
      content: Column(
        children: [
          const SizedBox(height: 24),
          
          // Imagem ilustrativa
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF2962FF).withOpacity(0.1), // Azul primário com opacidade
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Image(
                image: AssetImage('assets/images/smoke-one.png'),
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Texto explicativo
          Text(
            localizations.breatheFreedom,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2962FF), // Azul primário
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            localizations.personalizeExperience,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Ajustar para deixar espaço para o botão no bottom
          const SizedBox(height: 40),
        ],
      ),
      onNext: () {
        // Iniciar solicitação de notificações em segundo plano
        _requestFCMNotification(context);
        
        // Avançar para a próxima tela imediatamente
        provider.nextStep();
      },
      // Indicador de carregamento no botão
      isLoading: _isRequestingNotification,
    );
  }
}