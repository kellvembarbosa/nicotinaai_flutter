import 'package:nicotinaai_flutter/features/home/models/craving_model.dart';
import 'package:nicotinaai_flutter/features/onboarding/models/onboarding_model.dart';

class SmokingRecordModel {
  final String? id;
  final String reason; // Maps to trigger in smoking_logs
  final String? notes;
  final String amount; // Will be used to determine quantity
  final String duration;
  final DateTime timestamp;
  final String userId;
  final SyncStatus syncStatus;
  
  // Additional fields to match smoking_logs
  final ProductType productType;
  final String? location;
  final String? mood;

  SmokingRecordModel({
    this.id,
    required this.reason,
    this.notes,
    required this.amount,
    required this.duration,
    required this.timestamp,
    required this.userId,
    this.syncStatus = SyncStatus.synced,
    this.productType = ProductType.cigaretteOnly, // Default value
    this.location,
    this.mood,
  });

  // Add copy method for state manipulation
  SmokingRecordModel copyWith({
    String? id,
    String? reason,
    String? notes,
    String? amount,
    String? duration,
    DateTime? timestamp,
    String? userId,
    SyncStatus? syncStatus,
    ProductType? productType,
    String? location,
    String? mood,
  }) {
    return SmokingRecordModel(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      syncStatus: syncStatus ?? this.syncStatus,
      productType: productType ?? this.productType,
      location: location ?? this.location,
      mood: mood ?? this.mood,
    );
  }

  factory SmokingRecordModel.fromJson(Map<String, dynamic> json) {
    // Maps smoking_logs fields to SmokingRecordModel
    return SmokingRecordModel(
      id: json['id'],
      // Map 'trigger' to 'reason' if available, otherwise use existing 'reason' field
      reason: json['trigger'] ?? json['reason'] ?? '',
      notes: json['notes'],
      // Map 'quantity' to textual 'amount' if available
      amount: json['amount'] ?? _quantityToAmount(json['quantity']),
      // Currently no direct field mapping for duration
      duration: json['duration'] ?? 'less_than_5min',
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
      syncStatus: SyncStatus.synced,
      // Map additional fields from smoking_logs
      productType: json['product_type'] != null 
          ? _stringToProductType(json['product_type']) 
          : ProductType.cigaretteOnly,
      location: json['location'],
      mood: json['mood'],
    );
  }

  Map<String, dynamic> toJson() {
    // We don't include syncStatus in the JSON since it's internal state
    // Create a map compatible with smoking_logs table
    final Map<String, dynamic> json = {
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'product_type': _productTypeToString(productType),
      'quantity': _amountToQuantity(amount),
      'trigger': reason, // Map reason to trigger
      'notes': notes,
    };
    
    // Add optional fields if they exist
    if (location != null) json['location'] = location;
    if (mood != null) json['mood'] = mood;
    
    // Only include id if it's not null and not a temporary id
    if (id != null && !id!.startsWith('temp_')) {
      json['id'] = id;
    }
    
    return json;
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
  
  // Convert amount string to quantity integer
  static int _amountToQuantity(String amount) {
    switch (amount) {
      case 'one_or_less':
        return 1;
      case 'two_to_five':
        return 3; // Average of 2-5
      case 'more_than_five':
        return 6;
      default:
        return 1;
    }
  }
  
  // Convert quantity integer to amount string
  static String _quantityToAmount(dynamic quantity) {
    if (quantity == null) return 'one_or_less';
    
    final int quantityInt = int.tryParse(quantity.toString()) ?? 1;
    
    if (quantityInt <= 1) {
      return 'one_or_less';
    } else if (quantityInt <= 5) {
      return 'two_to_five';
    } else {
      return 'more_than_five';
    }
  }
}