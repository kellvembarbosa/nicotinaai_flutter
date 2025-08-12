# Documentação do Sistema de Paywall Flexível

## Visão Geral

Este documento descreve a implementação de um sistema de paywall modular e reutilizável para aplicações Flutter, compatível com Adapty e preparado para integração com RevenueCat. O sistema foi desenvolvido com foco em flexibilidade, permitindo diferentes tipos de apresentação e contextos de uso.

## Arquitetura

### Estrutura de Arquivos

```
lib/features/paywall/
├── presentation/
│   ├── pages/
│   │   ├── paywall_page.dart            # Página fullscreen
│   │   └── before_onboarding_paywall_page.dart
│   └── widgets/
│       ├── paywall_content.dart         # Widget principal reutilizável
│       ├── paywall_sheet.dart           # Bottom sheet
│       ├── paywall_dialog.dart          # Dialog modal
│       └── offer_paywall_content.dart   # Layout especial para ofertas
```

### Serviço Principal

```
lib/core/services/
├── paywall_service.dart                 # Serviço centralizado
├── adapty_service.dart                  # Integração com Adapty
└── subscription_sync_service.dart       # Sincronização de status
```

## PaywallService - Core do Sistema

### Características Principais

1. **Singleton Pattern**: Instância única gerenciada globalmente
2. **Dependency Injection**: Suporta injeção de diferentes providers (Adapty, RevenueCat)
3. **Múltiplos Formatos de Apresentação**: Page, Sheet, Dialog
4. **Callbacks Flexíveis**: OnPurchaseComplete, OnClosePaywall
5. **Gestão de Estado**: Controle de paywall ativo e pré-carregamento de ads
6. **Integração com AdMob**: Exibe intersticial após fechar paywall sem compra

### Métodos Principais

```dart
class PaywallService {
  /// Verifica se deve mostrar paywall (usuário free)
  Future<bool> shouldShowPaywall({
    String? placementId, 
    bool force = false
  });

  /// Mostra paywall com configurações específicas
  Future<void> showPaywall({
    required BuildContext context,
    required PaywallPresentationType presentationType,
    required String placementId,
    OnPurchaseComplete? onPurchaseComplete,
    OnClosePaywall? onClosePaywall,
    String? source,
    bool allowClose = true,
    bool force = false,
  });

  /// Verifica acesso a feature premium
  Future<bool> hasAccessToFeature(String featureName);

  /// Mostra paywall para feature específica
  Future<void> showPaywallForPremiumFeature({
    required BuildContext context,
    required String featureName,
    String? placementId,
    PaywallPresentationType presentationType,
    bool force = false,
  });
}
```

## Tipos de Apresentação

### 1. PaywallPresentationType.page
- **Uso**: Tela fullscreen, ideal para onboarding ou upgrade importante
- **Características**: 
  - Navegação completa
  - Mais espaço para conteúdo
  - Melhor para fluxos complexos

### 2. PaywallPresentationType.sheet
- **Uso**: Bottom sheet para interrupções contextuais
- **Características**:
  - Menos intrusivo
  - Mantém contexto da tela anterior
  - Ideal para ofertas rápidas

### 3. PaywallPresentationType.dialog
- **Uso**: Dialog modal para ofertas urgentes
- **Características**:
  - Foco total na oferta
  - Bloqueio de interação com fundo
  - Bom para ofertas temporárias

## Configuração de PlacementIds

### Placements Especiais

```dart
// Permitidos sem autenticação
const allowedWithoutAuth = [
  'onboarding',           // Durante onboarding inicial
  'onboarding_paywall',   // Após conclusão do onboarding  
  'paywall_offer',        // Ofertas especiais
];

// Sem intersticial após fechar
const noInterstitialPaywalls = [
  'onboarding',
  'onboarding_paywall',
];
```

## Hard Paywall com Timer

### Configuração via Remote Config

```json
{
  "hard_paywall": true,
  "hard_paywall_time": 15,
  "hard_paywall_delay_msg": true
}
```

### Comportamento
- **hard_paywall**: Ativa modo hard (sem botão fechar inicial)
- **hard_paywall_time**: Segundos até mostrar botão fechar
- **hard_paywall_delay_msg**: Mostra contador regressivo
- **Android Exception**: Sempre permite fechar no Android (política da Play Store)

## Extensões e Helpers

### 1. Extension Method para Context

```dart
extension PaywallExtensions on BuildContext {
  /// Abre paywall se usuário não for premium
  Future<void> openPaywallIfNotPremium({
    required VoidCallback onPremium,
    PaywallPresentationType type = PaywallPresentationType.sheet,
    String placementId = 'default',
    String? source,
  }) async {
    final paywallService = sl<PaywallService>();
    
    // Verifica se é premium
    final shouldShow = await paywallService.shouldShowPaywall(
      placementId: placementId,
    );
    
    if (!shouldShow) {
      // É premium, executa callback
      onPremium();
      return;
    }
    
    // Não é premium, mostra paywall
    if (mounted) {
      await paywallService.showPaywall(
        context: this,
        presentationType: type,
        placementId: placementId,
        source: source,
        onPurchaseComplete: (_) => onPremium(),
      );
    }
  }
}
```

### 2. Widget Wrapper para Features Premium

```dart
class PremiumFeatureWrapper extends HookWidget {
  final Widget child;
  final String featureName;
  final Widget? lockedWidget;
  
  const PremiumFeatureWrapper({
    required this.child,
    required this.featureName,
    this.lockedWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    final isPremium = useState(false);
    
    useEffect(() {
      PaywallService.instance
        .hasAccessToFeature(featureName)
        .then((value) => isPremium.value = value);
      return null;
    }, []);
    
    if (isPremium.value) {
      return child;
    }
    
    return lockedWidget ?? 
      GestureDetector(
        onTap: () => context.openPaywallIfNotPremium(
          onPremium: () => isPremium.value = true,
          source: 'feature_$featureName',
        ),
        child: _buildLockedOverlay(child),
      );
  }
}
```

## Uso Prático

### 1. Inicialização no App

```dart
void main() async {
  // ... outras inicializações
  
  // Injeta dependências no PaywallService
  PaywallService.instance.injectDependencies(
    adaptyService: sl<AdaptyService>(),
    authService: sl<AppwriteAuthService>(),
    subscriptionSyncService: sl<SubscriptionSyncService>(),
  );
  
  runApp(MyApp());
}
```

### 2. Uso em Feature Premium

```dart
// Em um botão de feature premium
ElevatedButton(
  onPressed: () {
    context.openPaywallIfNotPremium(
      onPremium: () {
        // Código da feature premium
        Navigator.push(context, 
          MaterialPageRoute(builder: (_) => PremiumFeature())
        );
      },
      source: 'premium_button_home',
      placementId: 'premium_feature',
    );
  },
  child: Text('Acessar Feature Premium'),
)
```

### 3. Após Onboarding

```dart
// No final do onboarding
void _completeOnboarding(BuildContext context) async {
  // Salva conclusão do onboarding
  await _saveOnboardingComplete();
  
  // Mostra paywall
  await PaywallService.instance.showPaywallAfterOnboarding(context);
  
  // Navega para home
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### 4. Widget com Proteção Premium

```dart
// Envolve widget que requer premium
PremiumFeatureWrapper(
  featureName: 'unlimited_questions',
  child: UnlimitedQuestionsWidget(),
  lockedWidget: Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Icon(Icons.lock, size: 48),
        Text('Feature Premium'),
        ElevatedButton(
          onPressed: null, // Handled by wrapper
          child: Text('Desbloquear'),
        ),
      ],
    ),
  ),
)
```

## Integração com RevenueCat

### Preparação para Migração

O sistema foi desenvolvido com abstração suficiente para permitir migração fácil:

1. **Interface Provider**: Criar interface comum para Adapty/RevenueCat
2. **Factory Pattern**: Instanciar provider baseado em configuração
3. **Adapter Pattern**: Mapear respostas específicas para formato comum

```dart
// Interface comum (exemplo)
abstract class SubscriptionProvider {
  Future<bool> hasActiveSubscription();
  Future<PurchaseResult> makePurchase(Product product);
  Future<Profile?> restorePurchases();
  Future<Paywall?> getPaywall({String? placementId});
}

// Implementações específicas
class AdaptyProvider implements SubscriptionProvider { ... }
class RevenueCatProvider implements SubscriptionProvider { ... }

// Factory
class ProviderFactory {
  static SubscriptionProvider create(ProviderType type) {
    switch (type) {
      case ProviderType.adapty:
        return AdaptyProvider();
      case ProviderType.revenueCat:
        return RevenueCatProvider();
    }
  }
}
```

## Fluxo de Compra

### Sequência de Eventos

1. **Verificação de Status**: `shouldShowPaywall()` verifica se usuário é free
2. **Exibição**: Paywall é mostrado no formato escolhido
3. **Seleção**: Usuário escolhe produto (mensal/anual)
4. **Processamento**: `AdaptyService.makePurchase()` processa compra
5. **Sincronização**: `SubscriptionSyncService` atualiza Appwrite
6. **Callback**: `onPurchaseComplete` é chamado
7. **Fechamento**: Paywall fecha com `purchaseMade: true`
8. **Atualização**: UI atualiza para mostrar conteúdo premium

## Tratamento de Erros

### Erros Comuns e Soluções

```dart
try {
  await paywallService.processPurchase(product);
} catch (e) {
  if (e is AdaptyError) {
    switch (e.code) {
      case AdaptyErrorCode.cancelled:
        // Usuário cancelou
        _showMessage('Compra cancelada');
        break;
      case AdaptyErrorCode.notAllowed:
        // Compras não permitidas
        _showMessage('Compras não habilitadas no dispositivo');
        break;
      case AdaptyErrorCode.pending:
        // Compra pendente
        _showMessage('Compra em processamento');
        break;
      default:
        _showMessage('Erro ao processar compra');
    }
  }
}
```

## Analytics e Tracking

### Eventos Importantes

```dart
// Visualização do paywall
await adaptyService.logShowPaywall(paywall);

// Clique em produto
await adaptyService.logPaywallProduct(product);

// Compra iniciada
await analytics.track('purchase_started', {
  'placement': placementId,
  'source': source,
  'product': product.vendorProductId,
});

// Compra concluída
await analytics.track('purchase_completed', {
  'placement': placementId,
  'source': source,
  'product': product.vendorProductId,
  'revenue': product.price,
});
```

## Configuração de Produtos

### Estrutura Recomendada

```dart
class ProductConfig {
  static const products = {
    'monthly': {
      'id': 'com.app.premium.monthly',
      'name': 'Premium Mensal',
      'trial': 3,  // dias de trial
    },
    'annual': {
      'id': 'com.app.premium.annual',
      'name': 'Premium Anual',
      'trial': 7,
      'discount': 50,  // percentual de desconto
    },
  };
}
```

## Testes

### Teste de Integração

```dart
testWidgets('Paywall mostra produtos corretamente', (tester) async {
  // Mock services
  final mockAdapty = MockAdaptyService();
  final mockAuth = MockAuthService();
  
  // Setup
  when(mockAdapty.getPaywall()).thenAnswer(
    (_) async => mockPaywall,
  );
  
  // Inject mocks
  PaywallService.instance.injectDependencies(
    adaptyService: mockAdapty,
    authService: mockAuth,
    subscriptionSyncService: mockSync,
  );
  
  // Test
  await tester.pumpWidget(
    MaterialApp(
      home: PaywallContent(placementId: 'test'),
    ),
  );
  
  await tester.pumpAndSettle();
  
  // Verify
  expect(find.text('Premium Mensal'), findsOneWidget);
  expect(find.text('Premium Anual'), findsOneWidget);
});
```

## Checklist de Implementação

- [ ] Configurar produtos na App Store/Play Store
- [ ] Configurar paywall no dashboard Adapty/RevenueCat
- [ ] Implementar PaywallService com dependências
- [ ] Adicionar extensions e helpers necessários
- [ ] Configurar placement IDs adequados
- [ ] Implementar callbacks de compra
- [ ] Adicionar analytics/tracking
- [ ] Testar fluxo completo de compra
- [ ] Configurar restauração de compras
- [ ] Implementar sincronização com backend
- [ ] Adicionar tratamento de erros
- [ ] Configurar hard paywall se necessário
- [ ] Testar em produção com usuários beta

## Considerações de Segurança

1. **Validação Server-Side**: Sempre validar compras no backend
2. **Cache de Status**: Cachear status premium localmente com TTL
3. **Sincronização**: Sincronizar periodicamente com backend
4. **Fallback**: Ter fallback para quando serviços estão offline
5. **Logs**: Registrar eventos importantes para auditoria

## Performance

1. **Pré-carregamento**: Carregar paywall antecipadamente
2. **Cache**: Cachear produtos e configurações
3. **Lazy Loading**: Carregar assets sob demanda
4. **Debounce**: Evitar múltiplas chamadas simultâneas
5. **Timeout**: Definir timeouts para operações de rede

## Conclusão

Este sistema de paywall oferece uma solução completa e flexível para monetização de apps Flutter, com suporte a múltiplos providers, formatos de apresentação variados e integração completa com sistemas de analytics e backend. A arquitetura modular permite fácil extensão e manutenção, enquanto os helpers e extensions facilitam o uso no dia a dia do desenvolvimento.