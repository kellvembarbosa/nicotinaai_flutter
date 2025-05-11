# Implementação do PostHog no NicotinaAI Flutter

Este documento contém instruções detalhadas para implementar o PostHog como parte do novo sistema de analytics no aplicativo NicotinaAI Flutter.

## O que foi implementado

1. **Nova Arquitetura de Analytics**
   - Sistema modular baseado em adaptadores
   - Integração com BLoC
   - Suporte para múltiplos provedores simultaneamente

2. **Adaptadores Implementados**
   - Facebook App Events (mantido do sistema anterior)
   - PostHog (novo)

3. **Arquivos Criados/Modificados**
   - `/lib/services/analytics/` - Serviço principal e adaptadores
   - `/lib/blocs/analytics/` - BLoC para integração na UI
   - `/lib/examples/` - Exemplos de uso
   - `/lib/test_analytics.dart` - Tela de teste
   - `/lib/main.dart.new` - Versão atualizada do main.dart

## Passos para concluir a implementação

### 1. Substituir o sistema atual pelo novo

```bash
# Certifique-se de que o pacote posthog_flutter está instalado
flutter pub add posthog_flutter

# Substituir o arquivo main.dart pelo novo
mv /Users/kellvembarbosa/nova-era/flutter/nicotinaai_flutter/lib/main.dart.new /Users/kellvembarbosa/nova-era/flutter/nicotinaai_flutter/lib/main.dart
```

### 2. Ajustar rotas para a tela de teste (opcional)

Adicionar a tela de teste ao router para debug:

```dart
// Em lib/core/routes/app_routes.dart
enum AppRoutes {
  // ...outras rotas
  testAnalytics,
}

extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      // ...outras rotas
      case AppRoutes.testAnalytics:
        return '/test-analytics';
    }
  }
}

// Em lib/core/routes/app_router.dart
GoRoute(
  path: AppRoutes.testAnalytics.path,
  builder: (context, state) => const TestAnalyticsScreen(),
),
```

### 3. Migrar chamadas de analytics existentes

Busque no código por chamadas ao sistema antigo (`AnalyticsService().logEvent()`) e substitua pelo novo formato.

#### Exemplo:

**Código antigo:**
```dart
AnalyticsService().logEvent('feature_used', parameters: {'feature': featureName});
```

**Código novo com BLoC:**
```dart
context.read<AnalyticsBloc>().add(
  LogFeatureUsageEvent(featureName),
);
```

**Código novo direto:**
```dart
AnalyticsService().logFeatureUsage(featureName);
```

### 4. Testar a implementação

1. Execute o aplicativo
2. Navegue para a tela de teste (`/test-analytics`)
3. Verifique se o PostHog está sendo inicializado corretamente
4. Envie eventos de teste e verifique se estão sendo registrados no dashboard do PostHog

## Detalhes de Configuração do PostHog

- **API Key**: `phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c`
- **Host**: `https://us.i.posthog.com`
- **Configurações adicionais habilitadas**:
  - `captureApplicationLifecycleEvents`: true
  - `recordScreenViews`: true

## Configurando via BLoC

```dart
context.read<AnalyticsBloc>().add(
  AddAnalyticsProviderEvent(
    'PostHog',
    providerConfig: {
      'apiKey': 'phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c',
      'host': 'https://us.i.posthog.com',
    },
  ),
);
```

## Configurando via Serviço

```dart
AnalyticsService().addAdapter(
  'PostHog',
  config: {
    'apiKey': 'phc_6p1aoXFElcMePRqaKvhQq7J55xisFMoc0tfQXezeq4c',
    'host': 'https://us.i.posthog.com',
  },
);
```

## Verificação no Dashboard

Para verificar se os eventos estão sendo enviados corretamente:

1. Acesse o dashboard do PostHog
2. Vá para a seção "Live Events"
3. Filtre por "Distinct ID" ou por tipo de evento
4. Verifique se os eventos enviados pelo aplicativo estão aparecendo

## Referências

- [Documentação do PostHog para Flutter](https://posthog.com/docs/libraries/flutter)
- [Exemplos de Implementação](/Users/kellvembarbosa/nova-era/flutter/nicotinaai_flutter/lib/examples/)
- [Guia Geral de Implementação do Analytics](/Users/kellvembarbosa/nova-era/flutter/nicotinaai_flutter/ANALYTICS_IMPLEMENTATION_GUIDE.md)