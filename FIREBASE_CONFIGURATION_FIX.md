# Firebase Configuration Fix

## Problemas Identificados

Identificamos um erro nos logs do aplicativo relacionado à solicitação de permissões de notificação:

```
flutter: 📊 [PostHogTracking] Logged event: onboarding_notifications_requested with parameters: null
flutter: Permission status: AuthorizationStatus.authorized
flutter: Erro ao solicitar permissão de notificação: [firebase_messaging/unknown] cannot parse response
flutter: ⏩ EVENT: AnalyticsBloc - TrackCustomEvent | 2025-05-14T12:38:57.864010
flutter:     TrackCustomEvent(onboarding_notifications_failed, {error: [firebase_messaging/unknown] cannot parse response})
```

Este erro ocorre porque o Firebase Messaging não está conseguindo processar as respostas corretamente devido à configuração incorreta.

## Causa Raiz

A causa raiz do problema está no arquivo `lib/config/firebase_options.dart` que contém valores de placeholder ao invés de chaves de API reais para o Firebase:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'placeholder-api-key',
  appId: '1:000000000000:android:0000000000000000000000',
  messagingSenderId: '000000000000',
  projectId: 'nicotinaai-app',
  storageBucket: 'nicotinaai-app.appspot.com',
);
```

## Solução Completa

Para resolver completamente este problema, siga os passos abaixo:

1. Certifique-se de que o projeto está configurado no Firebase Console (firebase.google.com)

2. Execute o comando FlutterFire CLI para configurar automaticamente seu projeto:

```bash
# Instalar FlutterFire CLI se ainda não estiver instalado
dart pub global activate flutterfire_cli

# Configurar o projeto
flutterfire configure
```

3. Selecione o projeto Firebase correto durante a configuração e siga as instruções na tela.

4. Isso irá gerar um arquivo `firebase_options.dart` atualizado com as configurações corretas para todas as plataformas.

## Melhorias de Código Implementadas

Enquanto isso, fizemos as seguintes melhorias no código para tornar o app mais resistente a falhas de configuração do Firebase:

1. **Em NotificationPermissionScreen:**
   - Adicionado parâmetros aos eventos de analytics para evitar valores nulos
   - Melhorada a manipulação de erros para distinguir entre diferentes casos
   - Adicionado feedback de erro mais específico para os usuários
   - Separação lógica do sucesso na solicitação de permissão do sucesso na obtenção do token

2. **Em NotificationService:**
   - Adicionada manipulação robusta de erros no método requestPermission()
   - Melhorado o método getToken() para lidar com erros sem falhar
   - Melhorados os métodos subscribeToTopic() e unsubscribeFromTopic() para serem resistentes a erros
   - Adicionados logs mais detalhados em todo o fluxo de notificações

Com estas melhorias, o aplicativo continuará funcionando mesmo com configurações incompletas do Firebase, e fornecerá feedback claro sobre erros quando ocorrerem.

## Testes

Após implementar a solução completa, teste o seguinte:

1. Solicitar permissões de notificação durante o onboarding
2. Verificar se o token FCM é obtido e salvo corretamente
3. Enviar uma notificação de teste usando o Firebase Console
4. Verificar se as notificações são recebidas em primeiro e segundo plano

## Observações

- As notificações são essenciais para o engajamento do usuário, portanto, esta correção é de alta prioridade
- Recomendamos implementar a solução completa antes do próximo lançamento do aplicativo