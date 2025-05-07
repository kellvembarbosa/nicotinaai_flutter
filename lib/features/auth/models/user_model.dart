import 'package:flutter/foundation.dart';
import 'package:nicotinaai_flutter/utils/supported_currencies.dart';

/// Modelo de usuário para armazenar informações do usuário autenticado
class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final bool emailConfirmed;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;
  final String? currencyCode;
  final String? currencySymbol;
  final String? currencyLocale;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.emailConfirmed = false,
    this.createdAt,
    this.metadata,
    this.currencyCode,
    this.currencySymbol,
    this.currencyLocale,
  });

  /// Cria um modelo de usuário a partir do JSON retornado pelo Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      name: json['user_metadata']?['name'] ?? json['name'],
      avatarUrl: json['user_metadata']?['avatar_url'] ?? json['avatar_url'],
      emailConfirmed: json['email_confirmed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      metadata: json['user_metadata'],
      currencyCode: json['user_metadata']?['currency_code'] ?? json['currency_code'],
      currencySymbol: json['user_metadata']?['currency_symbol'] ?? json['currency_symbol'],
      currencyLocale: json['user_metadata']?['currency_locale'] ?? json['currency_locale'],
    );
  }
  
  /// Cria um modelo de usuário a partir de um perfil do Supabase
  factory UserModel.fromProfile(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      name: json['full_name'],
      avatarUrl: json['avatar_url'],
      emailConfirmed: true, // Assume email confirmed for profile data
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      currencyCode: json['currency_code'] ?? SupportedCurrencies.defaultCurrency.code,
      currencySymbol: json['currency_symbol'] ?? SupportedCurrencies.defaultCurrency.symbol,
      currencyLocale: json['currency_locale'] ?? SupportedCurrencies.defaultCurrency.locale,
    );
  }

  /// Converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'email_confirmed': emailConfirmed,
      'created_at': createdAt?.toIso8601String(),
      'user_metadata': {
        ...?metadata,
        'currency_code': currencyCode,
        'currency_symbol': currencySymbol,
        'currency_locale': currencyLocale,
      },
    };
  }
  
  /// Converte o modelo para JSON para atualização de perfil no Supabase
  Map<String, dynamic> toProfileJson() {
    return {
      'full_name': name,
      'avatar_url': avatarUrl,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'currency_locale': currencyLocale,
    };
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    bool? emailConfirmed,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? currencyCode,
    String? currencySymbol,
    String? currencyLocale,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyLocale: currencyLocale ?? this.currencyLocale,
    );
  }
  
  /// Atualiza a moeda do usuário
  UserModel withCurrency(CurrencyInfo currency) {
    return copyWith(
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      currencyLocale: currency.locale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.emailConfirmed == emailConfirmed &&
        other.createdAt == createdAt &&
        other.currencyCode == currencyCode &&
        other.currencySymbol == currencySymbol &&
        other.currencyLocale == currencyLocale &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      name,
      avatarUrl,
      emailConfirmed,
      createdAt,
      metadata.hashCode,
      currencyCode,
      currencySymbol,
      currencyLocale,
    );
  }
  
  /// Retorna a moeda selecionada pelo usuário ou a moeda padrão
  CurrencyInfo get currency {
    if (currencyCode != null) {
      final currency = SupportedCurrencies.getByCurrencyCode(currencyCode!);
      if (currency != null) {
        return currency;
      }
    }
    return SupportedCurrencies.defaultCurrency;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, '
        'avatarUrl: $avatarUrl, emailConfirmed: $emailConfirmed, '
        'createdAt: $createdAt, metadata: $metadata, '
        'currencyCode: $currencyCode, '
        'currencySymbol: $currencySymbol, currencyLocale: $currencyLocale)';
  }
}