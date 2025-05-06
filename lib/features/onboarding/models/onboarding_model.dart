import 'package:flutter/foundation.dart';

enum ConsumptionLevel { low, moderate, high, veryHigh }
enum GoalType { reduce, quit }
enum GoalTimeline { sevenDays, fourteenDays, thirtyDays, noDeadline }
enum QuitChallenge { stress, habit, social, addiction }
enum ProductType { cigaretteOnly, vapeOnly, both }

class OnboardingModel {
  final String? id;
  final String userId;
  final bool completed;
  
  // Core questions
  final ConsumptionLevel? cigarettesPerDay;
  final int? cigarettesPerDayCount;
  final int? packPrice; // em centavos
  final String packPriceCurrency;
  final int? cigarettesPerPack;
  
  // Goals
  final GoalType? goal;
  final GoalTimeline? goalTimeline;
  
  // Challenges and preferences
  final QuitChallenge? quitChallenge;
  final List<String> helpPreferences;
  final ProductType? productType;
  
  // Additional data
  final Map<String, dynamic> additionalData;
  
  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OnboardingModel({
    this.id,
    required this.userId,
    this.completed = false,
    this.cigarettesPerDay,
    this.cigarettesPerDayCount,
    this.packPrice,
    this.packPriceCurrency = 'BRL',
    this.cigarettesPerPack,
    this.goal,
    this.goalTimeline,
    this.quitChallenge,
    this.helpPreferences = const [],
    this.productType,
    this.additionalData = const {},
    this.createdAt,
    this.updatedAt,
  });

  // Construtor de cópia
  OnboardingModel copyWith({
    String? id,
    String? userId,
    bool? completed,
    ConsumptionLevel? cigarettesPerDay,
    int? cigarettesPerDayCount,
    int? packPrice,
    String? packPriceCurrency,
    int? cigarettesPerPack,
    GoalType? goal,
    GoalTimeline? goalTimeline,
    QuitChallenge? quitChallenge,
    List<String>? helpPreferences,
    ProductType? productType,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OnboardingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      completed: completed ?? this.completed,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      cigarettesPerDayCount: cigarettesPerDayCount ?? this.cigarettesPerDayCount,
      packPrice: packPrice ?? this.packPrice,
      packPriceCurrency: packPriceCurrency ?? this.packPriceCurrency,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      goal: goal ?? this.goal,
      goalTimeline: goalTimeline ?? this.goalTimeline,
      quitChallenge: quitChallenge ?? this.quitChallenge,
      helpPreferences: helpPreferences ?? this.helpPreferences,
      productType: productType ?? this.productType,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // De JSON para Modelo
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      id: json['id'],
      userId: json['user_id'],
      completed: json['completed'] ?? false,
      cigarettesPerDay: json['cigarettes_per_day'] != null
          ? _stringToConsumptionLevel(json['cigarettes_per_day'])
          : null,
      cigarettesPerDayCount: json['cigarettes_per_day_count'],
      packPrice: json['pack_price'],
      packPriceCurrency: json['pack_price_currency'] ?? 'BRL',
      cigarettesPerPack: json['cigarettes_per_pack'],
      goal: json['goal'] != null ? _stringToGoalType(json['goal']) : null,
      goalTimeline: json['goal_timeline'] != null
          ? _stringToGoalTimeline(json['goal_timeline'])
          : null,
      quitChallenge: json['quit_challenge'] != null
          ? _stringToQuitChallenge(json['quit_challenge'])
          : null,
      helpPreferences: json['help_preferences'] != null
          ? List<String>.from(json['help_preferences'])
          : [],
      productType: json['product_type'] != null
          ? _stringToProductType(json['product_type'])
          : null,
      additionalData: json['additional_data'] ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // De Modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'completed': completed,
      'cigarettes_per_day': cigarettesPerDay != null
          ? _consumptionLevelToString(cigarettesPerDay!)
          : null,
      'cigarettes_per_day_count': cigarettesPerDayCount,
      'pack_price': packPrice,
      'pack_price_currency': packPriceCurrency,
      'cigarettes_per_pack': cigarettesPerPack,
      'goal': goal != null ? _goalTypeToString(goal!) : null,
      'goal_timeline':
          goalTimeline != null ? _goalTimelineToString(goalTimeline!) : null,
      'quit_challenge':
          quitChallenge != null ? _quitChallengeToString(quitChallenge!) : null,
      'help_preferences': helpPreferences,
      'product_type':
          productType != null ? _productTypeToString(productType!) : null,
      'additional_data': additionalData,
    };
  }

  // Métodos de conversão entre enum e string
  static ConsumptionLevel _stringToConsumptionLevel(String value) {
    switch (value) {
      case 'LOW':
        return ConsumptionLevel.low;
      case 'MODERATE':
        return ConsumptionLevel.moderate;
      case 'HIGH':
        return ConsumptionLevel.high;
      case 'VERY_HIGH':
        return ConsumptionLevel.veryHigh;
      default:
        return ConsumptionLevel.moderate;
    }
  }

  static String _consumptionLevelToString(ConsumptionLevel level) {
    switch (level) {
      case ConsumptionLevel.low:
        return 'LOW';
      case ConsumptionLevel.moderate:
        return 'MODERATE';
      case ConsumptionLevel.high:
        return 'HIGH';
      case ConsumptionLevel.veryHigh:
        return 'VERY_HIGH';
    }
  }

  static GoalType _stringToGoalType(String value) {
    switch (value) {
      case 'REDUCE':
        return GoalType.reduce;
      case 'QUIT':
        return GoalType.quit;
      default:
        return GoalType.quit;
    }
  }

  static String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.reduce:
        return 'REDUCE';
      case GoalType.quit:
        return 'QUIT';
    }
  }

  static GoalTimeline _stringToGoalTimeline(String value) {
    switch (value) {
      case 'SEVEN_DAYS':
        return GoalTimeline.sevenDays;
      case 'FOURTEEN_DAYS':
        return GoalTimeline.fourteenDays;
      case 'THIRTY_DAYS':
        return GoalTimeline.thirtyDays;
      case 'NO_DEADLINE':
        return GoalTimeline.noDeadline;
      default:
        return GoalTimeline.thirtyDays;
    }
  }

  static String _goalTimelineToString(GoalTimeline timeline) {
    switch (timeline) {
      case GoalTimeline.sevenDays:
        return 'SEVEN_DAYS';
      case GoalTimeline.fourteenDays:
        return 'FOURTEEN_DAYS';
      case GoalTimeline.thirtyDays:
        return 'THIRTY_DAYS';
      case GoalTimeline.noDeadline:
        return 'NO_DEADLINE';
    }
  }

  static QuitChallenge _stringToQuitChallenge(String value) {
    switch (value) {
      case 'STRESS':
        return QuitChallenge.stress;
      case 'HABIT':
        return QuitChallenge.habit;
      case 'SOCIAL':
        return QuitChallenge.social;
      case 'ADDICTION':
        return QuitChallenge.addiction;
      default:
        return QuitChallenge.habit;
    }
  }

  static String _quitChallengeToString(QuitChallenge challenge) {
    switch (challenge) {
      case QuitChallenge.stress:
        return 'STRESS';
      case QuitChallenge.habit:
        return 'HABIT';
      case QuitChallenge.social:
        return 'SOCIAL';
      case QuitChallenge.addiction:
        return 'ADDICTION';
    }
  }

  static ProductType _stringToProductType(String value) {
    switch (value) {
      case 'CIGARETTE_ONLY':
        return ProductType.cigaretteOnly;
      case 'VAPE_ONLY':
        return ProductType.vapeOnly;
      case 'BOTH':
        return ProductType.both;
      default:
        return ProductType.cigaretteOnly;
    }
  }

  static String _productTypeToString(ProductType type) {
    switch (type) {
      case ProductType.cigaretteOnly:
        return 'CIGARETTE_ONLY';
      case ProductType.vapeOnly:
        return 'VAPE_ONLY';
      case ProductType.both:
        return 'BOTH';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is OnboardingModel &&
      other.id == id &&
      other.userId == userId &&
      other.completed == completed &&
      other.cigarettesPerDay == cigarettesPerDay &&
      other.cigarettesPerDayCount == cigarettesPerDayCount &&
      other.packPrice == packPrice &&
      other.packPriceCurrency == packPriceCurrency &&
      other.cigarettesPerPack == cigarettesPerPack &&
      other.goal == goal &&
      other.goalTimeline == goalTimeline &&
      other.quitChallenge == quitChallenge &&
      listEquals(other.helpPreferences, helpPreferences) &&
      other.productType == productType &&
      mapEquals(other.additionalData, additionalData);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      completed.hashCode ^
      cigarettesPerDay.hashCode ^
      cigarettesPerDayCount.hashCode ^
      packPrice.hashCode ^
      packPriceCurrency.hashCode ^
      cigarettesPerPack.hashCode ^
      goal.hashCode ^
      goalTimeline.hashCode ^
      quitChallenge.hashCode ^
      helpPreferences.hashCode ^
      productType.hashCode ^
      additionalData.hashCode;
  }
}