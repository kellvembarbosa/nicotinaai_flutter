import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_bloc.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_event.dart';
import 'package:nicotinaai_flutter/blocs/settings/settings_state.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/settings/repositories/settings_repository.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para exclusão de conta
class DeleteAccountScreen extends StatefulWidget {
  static const String routeName = '/settings/delete-account';

  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  /// Flag para confirmação
  bool _confirmDelete = false;
  
  // Variável para controlar se o diálogo já foi exibido
  bool _successDialogShown = false;
  
  // Variável para controlar o estado de carregamento local (imediato)
  bool _isLocalLoading = false;
  
  // Controlador de timer para verificação de segurança
  Timer? _safetyTimer;
  
  @override
  void dispose() {
    // Garantir que o timer seja cancelado quando o widget for descartado
    _safetyTimer?.cancel();
    super.dispose();
  }
  
  /// Valida a confirmação e exclui a conta
  void _deleteAccount() {
    if (!_confirmDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).confirmDeleteRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Mostrar diálogo de confirmação final
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppLocalizations.of(context).confirmDeleteAccountTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              AppLocalizations.of(context).confirmDeleteAccountMessage,
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: Text(
                  AppLocalizations.of(context).cancel,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  
                  // Ativar o estado de carregamento local imediatamente
                  setState(() {
                    _isLocalLoading = true;
                    _successDialogShown = false;
                  });
                  
                  // Pegar referências dos blocs antes de iniciar a operação assíncrona
                  final settingsBloc = context.read<SettingsBloc>();
                  final authBloc = context.read<AuthBloc>();
                  
                  // Pequeno atraso para garantir que o estado de carregamento seja exibido
                  // antes mesmo que o processamento comece
                  Future.microtask(() {
                    // Executar a exclusão da conta após confirmação adicional
                    settingsBloc.add(const DeleteAccount());
                  });
                  
                  // Adicionar um fallback de segurança para garantir que o diálogo seja exibido
                  // Esta é uma solução alternativa caso o BlocListener não seja acionado
                  _safetyTimer = Timer(const Duration(seconds: 5), () {
                    print('⏱️ [DeleteAccountScreen] Verificando se o diálogo de sucesso já foi exibido...');
                    
                    // Verificar se o widget ainda está montado
                    if (!mounted) {
                      print('⚠️ [DeleteAccountScreen] Widget não está mais montado, cancelando verificação');
                      return;
                    }
                    
                    // Verificar se o diálogo já foi exibido
                    if (_successDialogShown) {
                      print('✅ [DeleteAccountScreen] Diálogo já foi exibido, ignorando fallback');
                      return;
                    }
                    
                    // Obter o estado atual
                    final currentState = settingsBloc.state;
                    
                    // Se não estiver mais carregando e não tiver erro, assumimos que houve sucesso
                    if (!currentState.isDeleteAccountLoading && 
                        !currentState.hasError) {
                      
                      print('🔄 [DeleteAccountScreen] Iniciando fluxo de logout forçado por fallback');
                      
                      // Forçar o logout
                      authBloc.add(const AccountDeletedLogout());
                      
                      // Se for possível mostrar o diálogo de sucesso (widget ainda montado)
                      if (mounted) {
                        // Mostrar o diálogo de sucesso de forma segura
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _showSuccessDialog();
                          }
                        });
                      } else {
                        // Se o widget não estiver montado, redirecionar diretamente para a tela de login
                        try {
                          GoRouter.of(context).go(AppRoutes.login.path);
                        } catch (e) {
                          print('⚠️ [DeleteAccountScreen] Erro ao redirecionar para login: $e');
                        }
                      }
                    }
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text(
                  AppLocalizations.of(context).delete,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }
  
  
  /// Exibe o diálogo de sucesso após a exclusão da conta
  void _showSuccessDialog() {
    final localizations = AppLocalizations.of(context);
    
    // Verificar se o BuildContext ainda é válido
    if (!mounted) return;
    
    // Marcar que o diálogo foi exibido para evitar duplicidade
    _successDialogShown = true;
    
    print('🎯 [DeleteAccountScreen] Exibindo diálogo de sucesso de exclusão');
    
    // Garantir navegação para login após um pequeno atraso
    // mesmo se o usuário não interagir com o diálogo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        print('⏱️ [DeleteAccountScreen] Tempo limite para navegação após exclusão da conta');
        // Fechar qualquer diálogo aberto antes de navegar
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        // Garantir navegação para a tela de login
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login.path,
          (route) => false
        );
      }
    });
    
    // Mostrar um diálogo de sucesso e feedback sobre o tipo de exclusão
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    localizations.accountDeleted,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              localizations.accountDeletedMessage,
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Após fechar o diálogo, redirecionar para a tela de login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login.path,
                    (route) => false
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: Text(
                  localizations.ok,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BlocProvider(
      create: (context) => SettingsBloc(
        settingsRepository: SettingsRepository(),
      ),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          print('👂 [DeleteAccountScreen] Estado detectado: status=${state.status}, isDeleteAccountLoading=${state.isDeleteAccountLoading}, hasError=${state.hasError}');
          
          // Verifica se a conta foi excluída com sucesso
          if (!state.isDeleteAccountLoading && !state.hasError && state.status == SettingsStatus.success) {
            print('🟢 [DeleteAccountScreen] Condição de sucesso atendida!');
            
            // Verifica se o diálogo já foi exibido para evitar duplicidade
            if (!_successDialogShown) {
              // Dispara o evento AccountDeletedLogout no AuthBloc para forçar o logout
              // já que a conta foi excluída com sucesso no servidor
              context.read<AuthBloc>().add(const AccountDeletedLogout());
              
              print('🔥 [DeleteAccountScreen] Conta excluída com sucesso, evento AccountDeletedLogout disparado');
              
              // Mostrar o diálogo de sucesso usando o método dedicado
              // Usa addPostFrameCallback para garantir que a árvore de widgets esteja estável
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showSuccessDialog();
                }
              });
            } else {
              print('⚠️ [DeleteAccountScreen] Diálogo já exibido, ignorando notificação');
            }
          }
          
          // Mostra erro se houver
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Desativar o carregamento local quando o BLoC começa a processar
          if (state.isDeleteAccountLoading && _isLocalLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isLocalLoading = false;
                });
              }
            });
          }
          
          // Determinar se devemos mostrar carregamento (seja local ou do BLoC)
          final bool showLoading = _isLocalLoading || state.isDeleteAccountLoading;
          
          return Stack(
            children: [
              Scaffold(
                backgroundColor: context.backgroundColor,
                appBar: AppBar(
                  backgroundColor: context.backgroundColor,
                  title: Text(
                    localizations.deleteAccount,
                    style: context.titleStyle,
                  ),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final user = authState.user;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ícone de aviso
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  Text(
                                    localizations.deleteAccountWarningTitle,
                                    style: context.textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    localizations.deleteAccountWarning,
                                    style: context.textTheme.bodyMedium!.copyWith(
                                      color: context.contentColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Email do usuário (não editável)
                            Text(
                              localizations.email,
                              style: context.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.contentColor,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.borderColor),
                              ),
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              child: Text(
                                user?.email ?? localizations.notSpecified,
                                style: context.textTheme.bodyLarge!.copyWith(
                                  color: context.contentColor,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Checkbox para confirmação
                            CheckboxListTile(
                              value: _confirmDelete,
                              onChanged: (value) {
                                setState(() {
                                  _confirmDelete = value ?? false;
                                });
                              },
                              title: Text(
                                localizations.confirmDeleteAccount,
                                style: context.textTheme.bodyMedium!.copyWith(
                                  color: context.contentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                localizations.confirmDeleteAccountSubtitle,
                                style: context.textTheme.bodySmall!.copyWith(
                                  color: context.subtitleColor,
                                ),
                              ),
                              activeColor: Colors.red,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Botão de exclusão de conta
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: showLoading
                                    ? null 
                                    : _deleteAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.red.withAlpha(150),
                                ),
                                child: showLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        localizations.deleteAccount,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Botão para cancelar
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: context.borderColor),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  localizations.cancel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.subtitleColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Overlay de carregamento simplificado - apenas um indicador de carregamento circular
              if (showLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Efeito de pulsar ao redor do indicador
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 1),
                              builder: (context, value, child) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withOpacity(0.3 * (1 - value)),
                                  ),
                                );
                              },
                              onEnd: () {
                                // Reiniciar a animação quando ela terminar
                                if (mounted) setState(() {});
                              },
                            ),
                            
                            // Indicador de progresso principal
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                strokeWidth: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
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

// Extensão para adicionar strings que não estão no AppLocalizations
extension _DeleteAccountLocalizations on AppLocalizations {
  String get deleteAccountWarningTitle => 'This Action Cannot Be Undone';
  String get deleteAccountWarning => 'All your data, including tracking history, achievements, and settings will be permanently deleted. This action cannot be reversed.';
  String get confirmDeleteAccount => 'I understand this is permanent';
  String get confirmDeleteAccountSubtitle => 'I understand that all my data will be permanently deleted and cannot be recovered.';
  String get confirmDeleteRequired => 'Please confirm that you understand this action is permanent.';
  String get accountDeleted => 'Account Deleted Successfully';
  String get accountDeletedMessage => 'Your account and all associated data have been permanently deleted. You can always register again with the same email if you wish to return in the future.';
  String get ok => 'OK';
  String get delete => 'Delete';
  String get confirmDeleteAccountTitle => 'Are You Sure?';
  String get confirmDeleteAccountMessage => 'This will permanently delete your account and all of your data. You can always register again with the same email, but all your current progress will be lost.';
  String get deletingAccount => 'Deleting...';
  String get accountDeletionInProgress => 'Deleting Your Account';
  String get accountDeletionExplanation => 'We are permanently deleting your account and all associated data from our systems. This process may take a few moments to complete.';
  
}