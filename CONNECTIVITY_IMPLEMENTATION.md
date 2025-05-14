# Implementação de Verificação de Conectividade

Este documento descreve a implementação do sistema de bloqueio do app quando não há conexão com a internet, já que o app é totalmente dependente de conexão para funcionar.

## Arquitetura Implementada

A solução foi implementada usando o padrão BLoC (Business Logic Component) para gerenciar o estado de conectividade do app, consistindo de:

1. **ConnectivityBloc**: Gerencia o estado de conectividade usando o pacote connectivity_plus
2. **ConnectivityOverlay**: Um widget que exibe uma tela de bloqueio quando não há conexão
3. **Integração no MaterialApp**: Para bloquear o app inteiro quando necessário

## Componentes

### 1. ConnectivityBloc (`lib/blocs/connectivity/connectivity_bloc.dart`)

O BLoC monitora mudanças na conectividade do dispositivo e emite estados apropriados:

- **ConnectivityInitial**: Estado inicial durante a inicialização
- **ConnectivityConnected**: Emitido quando há uma conexão ativa (Wi-Fi, móvel, etc.)
- **ConnectivityDisconnected**: Emitido quando não há conexão

### 2. ConnectivityOverlay (`lib/widgets/connectivity_overlay.dart`)

Um widget sobreposto que:
- Deixa a aplicação funcionar normalmente quando há conexão
- Exibe uma tela de bloqueio quando não há conexão, incluindo:
  - Ícone de Wi-Fi desconectado
  - Mensagem explicativa
  - Botão para tentar reconectar

### 3. Integração no MaterialApp (`lib/main.dart`)

O MaterialApp.router foi configurado com um builder que envolve todo o conteúdo do app com o ConnectivityOverlay, garantindo que o bloqueio seja aplicado em toda a aplicação.

## Fluxo de Funcionamento

1. **Inicialização**:
   - O ConnectivityBloc é inicializado junto com o app
   - Uma verificação inicial de conectividade é realizada
   - O BLoC começa a ouvir mudanças de conectividade

2. **Durante o uso normal**:
   - Se há conexão: O app funciona normalmente
   - Se a conexão cair: A tela de bloqueio é exibida imediatamente
   - Quando a conexão é restaurada: A tela de bloqueio é removida e o app volta a funcionar

3. **Reconexão manual**:
   - O botão "Tentar novamente" na tela de bloqueio permite que o usuário acione manualmente uma verificação de conectividade

## Tipos de Conexão Considerados

O sistema considera os seguintes tipos de conexão como válidos:
- Wi-Fi
- Dados móveis
- VPN
- Ethernet

Conexões via Bluetooth ou outros tipos não são consideradas válidas para uso do app.

## Próximos Passos Recomendados

Para melhorar a experiência do usuário, considerar futuramente:

1. Adicionar caches locais para dados essenciais
2. Implementar sincronização em background quando a conexão retornar
3. Adicionar mensagens específicas para diferentes tipos de falha de conectividade
4. Personalizar a tela de bloqueio conforme a identidade visual do app