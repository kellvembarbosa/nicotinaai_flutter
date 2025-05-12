import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nicotinaai_flutter/features/auth/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para verificar o estado atual de autenticação
class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

/// Evento para o login com e-mail e senha
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento para o registro com e-mail e senha
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Evento para o logout
class LogoutRequested extends AuthEvent {
  final BuildContext? context;
  
  const LogoutRequested({this.context});
  
  @override
  List<Object?> get props => [context];
}

/// Evento para atualizar o estado de autenticação
class RefreshAuthStateRequested extends AuthEvent {
  const RefreshAuthStateRequested();
}

/// Evento para enviar e-mail de recuperação de senha
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Evento para atualizar os dados do usuário
class UpdateUserDataRequested extends AuthEvent {
  final String? name;
  final String? avatarUrl;
  final String? currencyCode;
  final String? currencySymbol;
  final String? currencyLocale;

  const UpdateUserDataRequested({
    this.name,
    this.avatarUrl,
    this.currencyCode,
    this.currencySymbol,
    this.currencyLocale,
  });

  @override
  List<Object?> get props => [
    name,
    avatarUrl,
    currencyCode,
    currencySymbol,
    currencyLocale,
  ];
}

/// Evento para atualizar o perfil completo do usuário
class UpdateProfileRequested extends AuthEvent {
  final UserModel user;

  const UpdateProfileRequested({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Evento para atualizar o perfil do usuário (alternativa simplificada)
class UpdateProfile extends AuthEvent {
  final UserModel user;

  const UpdateProfile({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Evento para limpar uma mensagem de erro
class ClearAuthErrorRequested extends AuthEvent {
  const ClearAuthErrorRequested();
}

/// Evento para forçar o logout após a exclusão da conta
/// Usado quando a conta foi excluída com sucesso no servidor
class AccountDeletedLogout extends AuthEvent {
  const AccountDeletedLogout();
}