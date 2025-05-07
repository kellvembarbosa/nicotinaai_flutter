# Instruções para Localização em Espanhol

Este documento descreve os passos necessários para implementar a localização em espanhol no aplicativo NicotinaAI.

## Arquivos Necessários

Devem ser criados os seguintes arquivos:

1. **`assets/l10n/app_es.arb`** - Contém todas as strings de interface do aplicativo em espanhol
2. **`assets/l10n/notification_strings_es.arb`** - Contém strings específicas para notificações em espanhol

## Passos para Implementação

1. Criar o arquivo `app_es.arb` baseado no `app_en.arb` ou `app_pt.arb`
2. Traduzir todas as strings para espanhol com ajuda de tradutores profissionais
3. Criar o arquivo `notification_strings_es.arb` para mensagens de notificação
4. Atualizar o arquivo `l10n.yaml` para incluir espanhol como um dos idiomas suportados
5. Executar `flutter gen-l10n` para gerar os arquivos de localização em dart
6. Implementar a detecção de idioma espanhol em todos os locais relevantes da aplicação

## Exemplo de Strings em Espanhol para Notificações

```json
{
  "@@locale": "es",
  
  "dailyMotivation": "Motivación Diaria",
  "dailyMotivationDescription": "¡Tu motivación diaria personalizada está aquí. Ábrela para obtener tu recompensa de XP!",
  
  "motivationalMessage": "Mensaje Motivacional",
  "achievementUnlocked": "¡Logro Desbloqueado!",
  
  "claimReward": "Reclamar {xp} XP",
  "rewardClaimed": "Recompensa reclamada: {xp} XP",
  
  "noNotificationsYet": "¡Aún no hay notificaciones!",
  "emptyNotificationsDescription": "Continúa usando la aplicación para recibir mensajes motivacionales y logros.",
  "errorLoadingNotifications": "Error al cargar notificaciones",
  "refresh": "Actualizar"
}
```

## Testes

- Verificar se o idioma espanhol é detectado corretamente ao usar dispositivos com configuração em espanhol
- Verificar se todas as strings são exibidas corretamente nas telas do aplicativo
- Verificar se as notificações enviadas em espanhol são exibidas corretamente
- Testar o aplicativo com usuários nativos de espanhol para garantir qualidade das traduções

## Considerações Adicionais

- Considerar variações regionais do espanhol (Espanha vs América Latina)
- Atualizar o arquivo de maneira sincronizada sempre que novas strings forem adicionadas ao app
- Lembrar que alguns textos podem ser mais longos em espanhol do que em inglês ou português, o que pode afetar o layout

## Exemplos de Fluxo de Trabalho para Traduções

Para manter as traduções atualizadas, sempre que uma nova string for adicionada aos arquivos de localização em inglês ou português, ela deve ser imediatamente adicionada também ao arquivo em espanhol.

O script `merge_localization_strings.sh` deve ser modificado para incluir o suporte a arquivos em espanhol.