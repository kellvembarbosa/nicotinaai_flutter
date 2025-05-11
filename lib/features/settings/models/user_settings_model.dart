import 'package:equatable/equatable.dart';

/// Classe que representa as configurações do usuário relacionadas ao tabagismo
class UserSettingsModel extends Equatable {
  /// Preço de um maço de cigarros em centavos
  final int packPriceInCents;
  
  /// Quantidade de cigarros por dia antes de parar
  final int cigarettesPerDay;
  
  /// Data em que o usuário parou de fumar
  final DateTime? quitDate;
  
  /// Quantidade de cigarros em um maço
  final int cigarettesPerPack;
  
  /// Código da moeda (ex: BRL, USD)
  final String currencyCode;
  
  /// Símbolo da moeda (ex: R$, $)
  final String currencySymbol;

  const UserSettingsModel({
    this.packPriceInCents = 0,
    this.cigarettesPerDay = 0,
    this.quitDate,
    this.cigarettesPerPack = 20,
    this.currencyCode = 'BRL',
    this.currencySymbol = r'R$',
  });

  /// Cria uma instância a partir de um JSON
  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    DateTime? quitDateValue;
    
    // Processa a data de parada, que pode vir de diferentes campos
    if (json['quit_date'] != null) {
      quitDateValue = DateTime.parse(json['quit_date']);
    } else if (json['last_smoke_date'] != null) {
      quitDateValue = DateTime.parse(json['last_smoke_date']);
    }
    
    return UserSettingsModel(
      packPriceInCents: json['pack_price_in_cents'] ?? json['pack_price'] ?? 0,
      cigarettesPerDay: json['cigarettes_per_day'] ?? 0,
      quitDate: quitDateValue,
      cigarettesPerPack: json['cigarettes_per_pack'] ?? 20,
      currencyCode: json['currency_code'] ?? 'BRL',
      currencySymbol: json['currency_symbol'] ?? r'R$',
    );
  }

  /// Converte a instância para JSON
  Map<String, dynamic> toJson() {
    return {
      'pack_price': packPriceInCents,
      'cigarettes_per_day': cigarettesPerDay,
      'last_smoke_date': quitDate?.toIso8601String(),
      'cigarettes_per_pack': cigarettesPerPack,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    };
  }

  /// Cria uma cópia desta instância com valores opcionalmente substituídos
  UserSettingsModel copyWith({
    int? packPriceInCents,
    int? cigarettesPerDay,
    DateTime? quitDate,
    bool clearQuitDate = false,
    int? cigarettesPerPack,
    String? currencyCode,
    String? currencySymbol,
  }) {
    return UserSettingsModel(
      packPriceInCents: packPriceInCents ?? this.packPriceInCents,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      quitDate: clearQuitDate ? null : (quitDate ?? this.quitDate),
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  /// Calcula o dinheiro economizado desde que parou de fumar
  /// 
  /// Retorna o valor em centavos.
  int calculateSavings() {
    if (quitDate == null || packPriceInCents == 0 || cigarettesPerDay == 0) {
      return 0;
    }

    final now = DateTime.now();
    final daysSinceQuit = now.difference(quitDate!).inDays;
    
    if (daysSinceQuit <= 0) {
      return 0;
    }

    // Calcula quantos maços seriam consumidos, baseado no consumo diário
    final packsPerDay = cigarettesPerDay / cigarettesPerPack;
    
    // Calcula o valor economizado, arredondando para o inteiro mais próximo
    return (packsPerDay * daysSinceQuit * packPriceInCents).round();
  }

  /// Lista imutável de propriedades para o Equatable
  @override
  List<Object?> get props => [
    packPriceInCents,
    cigarettesPerDay,
    quitDate,
    cigarettesPerPack,
    currencyCode,
    currencySymbol,
  ];
}