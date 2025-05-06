import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';

class SmokingLog {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final ProductType productType;
  final int quantity;
  final String? location;
  final String? mood;
  final String? trigger;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SmokingLog({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.productType,
    this.quantity = 1,
    this.location,
    this.mood,
    this.trigger,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Copy constructor
  SmokingLog copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    ProductType? productType,
    int? quantity,
    String? location,
    String? mood,
    String? trigger,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SmokingLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      trigger: trigger ?? this.trigger,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON to Model
  factory SmokingLog.fromJson(Map<String, dynamic> json) {
    return SmokingLog(
      id: json['id'],
      userId: json['user_id'],
      timestamp: DateTime.parse(json['timestamp']),
      productType: _stringToProductType(json['product_type']),
      quantity: json['quantity'] ?? 1,
      location: json['location'],
      mood: json['mood'],
      trigger: json['trigger'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // From Model to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'product_type': _productTypeToString(productType),
      'quantity': quantity,
      if (location != null) 'location': location,
      if (mood != null) 'mood': mood,
      if (trigger != null) 'trigger': trigger,
      if (notes != null) 'notes': notes,
    };
  }

  // Helper methods for conversion
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
  
    return other is SmokingLog &&
      other.id == id &&
      other.userId == userId &&
      other.timestamp == timestamp &&
      other.productType == productType &&
      other.quantity == quantity &&
      other.location == location &&
      other.mood == mood &&
      other.trigger == trigger &&
      other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      timestamp.hashCode ^
      productType.hashCode ^
      quantity.hashCode ^
      location.hashCode ^
      mood.hashCode ^
      trigger.hashCode ^
      notes.hashCode;
  }
}