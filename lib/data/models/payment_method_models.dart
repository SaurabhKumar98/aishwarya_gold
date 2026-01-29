// models/payment_method_model.dart

class PaymentMethod {
  final String id;
  final String type; // 'upi' or 'bank'
  final String displayName;
  final String identifier; // UPI ID or Account Number
  final String? bankName;
  final String? ifscCode;
  final bool isPrimary;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.identifier,
    this.bankName,
    this.ifscCode,
    required this.isPrimary,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      displayName: json['displayName'],
      identifier: json['identifier'],
      bankName: json['bankName'],
      ifscCode: json['ifscCode'],
      isPrimary: json['isPrimary'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'displayName': displayName,
      'identifier': identifier,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? displayName,
    String? identifier,
    String? bankName,
    String? ifscCode,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      identifier: identifier ?? this.identifier,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AddPaymentMethodRequest {
  final String type;
  final String displayName;
  final String identifier;
  final String? bankName;
  final String? ifscCode;

  AddPaymentMethodRequest({
    required this.type,
    required this.displayName,
    required this.identifier,
    this.bankName,
    this.ifscCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'displayName': displayName,
      'identifier': identifier,
      'bankName': bankName,
      'ifscCode': ifscCode,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'],
      error: json['error'],
    );
  }
}