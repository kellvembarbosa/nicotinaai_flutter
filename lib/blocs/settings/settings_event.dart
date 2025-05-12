import 'package:equatable/equatable.dart';

/// Eventos para o BLoC de configurações
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  
  @override
  List<Object?> get props => [];
}

/// Evento para carregar as configurações do usuário
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Evento para atualizar o preço do maço de cigarros
class UpdatePackPrice extends SettingsEvent {
  final int priceInCents;
  
  const UpdatePackPrice({required this.priceInCents});
  
  @override
  List<Object?> get props => [priceInCents];
}

/// Evento para atualizar a quantidade de cigarros por dia
class UpdateCigarettesPerDay extends SettingsEvent {
  final int cigarettesPerDay;
  
  const UpdateCigarettesPerDay({required this.cigarettesPerDay});
  
  @override
  List<Object?> get props => [cigarettesPerDay];
}

/// Evento para atualizar a data em que o usuário parou de fumar
class UpdateQuitDate extends SettingsEvent {
  final DateTime? quitDate;
  
  const UpdateQuitDate({this.quitDate});
  
  @override
  List<Object?> get props => [quitDate];
}

/// Evento para solicitar redefinição de senha
class RequestPasswordReset extends SettingsEvent {
  final String email;
  
  const RequestPasswordReset({required this.email});
  
  @override
  List<Object?> get props => [email];
}

/// Evento para alterar a senha do usuário
class ChangePassword extends SettingsEvent {
  final String currentPassword;
  final String newPassword;
  
  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });
  
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Evento para excluir a conta do usuário
class DeleteAccount extends SettingsEvent {
  const DeleteAccount();
  
  @override
  List<Object?> get props => [];
}
