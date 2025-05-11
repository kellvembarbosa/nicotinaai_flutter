import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_event.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// Tela para edição de perfil do usuário
class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/profile/edit';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  /// Controlador do campo de nome
  final TextEditingController _nameController = TextEditingController();
  
  /// Formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// Flag para indicar se está carregando
  bool _isLoading = false;
  
  /// Mensagem de erro
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initUserData();
  }
  
  /// Inicializa os dados do usuário nos controladores
  void _initUserData() {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    
    if (user != null) {
      _nameController.text = user.name ?? '';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  /// Valida o formulário e atualiza o perfil
  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final authState = context.read<AuthBloc>().state;
        final currentUser = authState.user;
        
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            name: _nameController.text,
          );
          
          // Despacha evento de atualização de perfil
          context.read<AuthBloc>().add(UpdateProfile(user: updatedUser));
          
          // Volta para a tela anterior após sucesso
          if (mounted) {
            Navigator.of(context).pop();
            
            // Mostra mensagem de sucesso
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).profileUpdatedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        title: Text(
          localizations.editProfile,
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
            builder: (context, state) {
              final user = state.user;
              
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da seção
                    Text(
                      localizations.profileInformation,
                      style: context.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      localizations.editProfileDescription,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Avatar do usuário (placeholder para futura implementação)
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: context.primaryColor.withOpacity(0.2),
                            child: Text(
                              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.backgroundColor,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Campo de nome
                    Text(
                      localizations.name,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.nameRequired;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: localizations.enterName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: context.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Campo de email (não editável)
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
                    
                    // Mensagem de erro (se houver)
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage!,
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Botões de ação
                    Row(
                      children: [
                        // Botão de cancelar
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.primaryColor),
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
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Botão de salvar
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: context.primaryColor.withOpacity(0.6),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    localizations.save,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Extensão para adicionar strings que não estão no AppLocalizations
extension _EditProfileLocalizations on AppLocalizations {
  String get profileInformation => 'Profile Information';
  String get editProfileDescription => 'Update your profile information below.';
  String get enterName => 'Enter your name';
  String get profileUpdatedSuccessfully => 'Profile updated successfully';
}