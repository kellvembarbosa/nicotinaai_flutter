class UserStats {
  final String? id;
  final String userId;
  final int cigarettesAvoided;
  final int moneySaved; // stored in cents
  final int cravingsResisted;
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? healthiestDayDate;
  final DateTime? lastSmokeDate;
  final int totalSmokeFreedays;
  final int totalXp;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Fields used in DeveloperDashboardScreen
  final int? productType;
  final int? cigarettesPerDay;
  final int? cigarettesPerPack;
  final int? packPrice;
  final String? currencyCode;
  
  // Novos campos para o sistema centralizado
  final int? cigarettesSmoked;
  final int? smokingRecordsCount; // Number of smoking records
  final int? minutesGainedToday; // Minutos ganhos hoje
  final int? totalMinutesGained; // Total de minutos ganhos durante todo o período

  // Campo adicional para controle de atualização em memória (não persistido no banco)
  final int? lastUpdated;

  const UserStats({
    this.id,
    required this.userId,
    this.cigarettesAvoided = 0,
    this.moneySaved = 0,
    this.cravingsResisted = 0,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.healthiestDayDate,
    this.lastSmokeDate,
    this.totalSmokeFreedays = 0,
    this.totalXp = 0,
    this.createdAt,
    this.updatedAt,
    this.productType,
    this.cigarettesPerDay,
    this.cigarettesPerPack,
    this.packPrice,
    this.currencyCode,
    this.cigarettesSmoked = 0,
    this.smokingRecordsCount = 0,
    this.minutesGainedToday = 0,
    this.totalMinutesGained = 0,
    this.lastUpdated,
  });


  // Copy constructor
  UserStats copyWith({
    String? id,
    String? userId,
    int? cigarettesAvoided,
    int? moneySaved,
    int? cravingsResisted,
    int? currentStreakDays,
    int? longestStreakDays,
    DateTime? healthiestDayDate,
    DateTime? lastSmokeDate,
    int? totalSmokeFreedays,
    int? totalXp,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? productType,
    int? cigarettesPerDay,
    int? cigarettesPerPack,
    int? packPrice,
    String? currencyCode,
    int? cigarettesSmoked,
    int? smokingRecordsCount,
    int? minutesGainedToday,
    int? totalMinutesGained,
    int? lastUpdated,
  }) {
    return UserStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cigarettesAvoided: cigarettesAvoided ?? this.cigarettesAvoided,
      moneySaved: moneySaved ?? this.moneySaved,
      cravingsResisted: cravingsResisted ?? this.cravingsResisted,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      healthiestDayDate: healthiestDayDate ?? this.healthiestDayDate,
      lastSmokeDate: lastSmokeDate ?? this.lastSmokeDate,
      totalSmokeFreedays: totalSmokeFreedays ?? this.totalSmokeFreedays,
      totalXp: totalXp ?? this.totalXp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productType: productType ?? this.productType,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      packPrice: packPrice ?? this.packPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      cigarettesSmoked: cigarettesSmoked ?? this.cigarettesSmoked,
      smokingRecordsCount: smokingRecordsCount ?? this.smokingRecordsCount,
      minutesGainedToday: minutesGainedToday ?? this.minutesGainedToday,
      totalMinutesGained: totalMinutesGained ?? this.totalMinutesGained,
      lastUpdated: lastUpdated ?? this.lastUpdated ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Calculated properties
  // This is a legacy method kept for backward compatibility
  // Use CurrencyUtils.format instead for actual formatting
  String get formattedMoneySaved {
    final dollars = moneySaved / 100;
    return 'R\$ ${dollars.toStringAsFixed(2)}';
  }
  
  // Calculate the money saved percentage (based on a default target)
  double get moneySavedPercentage {
    const targetSavings = 100000; // R$1000,00 as target savings
    return moneySaved / targetSavings;
  }

  // Days since last smoke
  int get daysSinceLastSmoke {
    if (lastSmokeDate == null) return 0;
    
    final now = DateTime.now();
    return now.difference(lastSmokeDate!).inDays;
  }
  
  // Current smoke-free streak in days (alias for currentStreakDays)
  int get smokeFreeStreak {
    return currentStreakDays;
  }

  // From JSON to Model
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'],
      userId: json['user_id'],
      cigarettesAvoided: json['cigarettes_avoided'] ?? 0,
      moneySaved: json['money_saved'] ?? 0,
      cravingsResisted: json['cravings_resisted'] ?? 0,
      currentStreakDays: json['current_streak_days'] ?? 0,
      longestStreakDays: json['longest_streak_days'] ?? 0,
      healthiestDayDate: json['healthiest_day_date'] != null
          ? DateTime.parse(json['healthiest_day_date'])
          : null,
      lastSmokeDate: json['last_smoke_date'] != null
          ? DateTime.parse(json['last_smoke_date'])
          : null,
      totalSmokeFreedays: json['total_smoke_free_days'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      productType: json['product_type'],
      cigarettesPerDay: json['cigarettes_per_day'],
      cigarettesPerPack: json['cigarettes_per_pack'],
      packPrice: json['pack_price'],
      currencyCode: json['currency_code'],
      cigarettesSmoked: json['cigarettes_smoked'] ?? 0,
      smokingRecordsCount: json['smoking_records_count'] ?? 0,
      minutesGainedToday: json['minutes_gained_today'] ?? 0,
      totalMinutesGained: json['total_minutes_gained'] ?? 0,
    );
  }

  // From Model to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'cigarettes_avoided': cigarettesAvoided,
      'money_saved': moneySaved,
      'cravings_resisted': cravingsResisted,
      'current_streak_days': currentStreakDays,
      'longest_streak_days': longestStreakDays,
      if (healthiestDayDate != null)
        'healthiest_day_date': healthiestDayDate!.toIso8601String(),
      if (lastSmokeDate != null)
        'last_smoke_date': lastSmokeDate!.toIso8601String(),
      'total_smoke_free_days': totalSmokeFreedays,
      'total_xp': totalXp,
      if (productType != null) 'product_type': productType,
      if (cigarettesPerDay != null) 'cigarettes_per_day': cigarettesPerDay,
      if (cigarettesPerPack != null) 'cigarettes_per_pack': cigarettesPerPack,
      if (packPrice != null) 'pack_price': packPrice,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (cigarettesSmoked != null) 'cigarettes_smoked': cigarettesSmoked,
      if (smokingRecordsCount != null) 'smoking_records_count': smokingRecordsCount,
      if (minutesGainedToday != null) 'minutes_gained_today': minutesGainedToday,
      if (totalMinutesGained != null) 'total_minutes_gained': totalMinutesGained,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserStats &&
      other.id == id &&
      other.userId == userId &&
      other.cigarettesAvoided == cigarettesAvoided &&
      other.moneySaved == moneySaved &&
      other.cravingsResisted == cravingsResisted &&
      other.currentStreakDays == currentStreakDays &&
      other.longestStreakDays == longestStreakDays &&
      other.healthiestDayDate == healthiestDayDate &&
      other.lastSmokeDate == lastSmokeDate &&
      other.totalSmokeFreedays == totalSmokeFreedays &&
      other.totalXp == totalXp &&
      other.productType == productType &&
      other.cigarettesPerDay == cigarettesPerDay &&
      other.cigarettesPerPack == cigarettesPerPack &&
      other.packPrice == packPrice &&
      other.currencyCode == currencyCode &&
      other.cigarettesSmoked == cigarettesSmoked &&
      other.smokingRecordsCount == smokingRecordsCount &&
      other.minutesGainedToday == minutesGainedToday &&
      other.totalMinutesGained == totalMinutesGained &&
      other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      cigarettesAvoided.hashCode ^
      moneySaved.hashCode ^
      cravingsResisted.hashCode ^
      currentStreakDays.hashCode ^
      longestStreakDays.hashCode ^
      healthiestDayDate.hashCode ^
      lastSmokeDate.hashCode ^
      totalSmokeFreedays.hashCode ^
      totalXp.hashCode ^
      productType.hashCode ^
      cigarettesPerDay.hashCode ^
      cigarettesPerPack.hashCode ^
      packPrice.hashCode ^
      currencyCode.hashCode ^
      cigarettesSmoked.hashCode ^
      smokingRecordsCount.hashCode ^
      minutesGainedToday.hashCode ^
      totalMinutesGained.hashCode ^
      lastUpdated.hashCode;
  }
}