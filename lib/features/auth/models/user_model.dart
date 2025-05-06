import 'package:flutter/foundation.dart';

/// Modelo de usuário para armazenar informações do usuário autenticado
class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final bool emailConfirmed;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.emailConfirmed = false,
    this.createdAt,
    this.metadata,
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
      'user_metadata': metadata,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
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
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, '
        'avatarUrl: $avatarUrl, emailConfirmed: $emailConfirmed, '
        'createdAt: $createdAt, metadata: $metadata)';
  }
}