import 'dart:convert';

/// =======================================================
/// JSON Helpers
/// =======================================================

RefferHistoryModels refferHistoryModelsFromJson(String str) =>
    RefferHistoryModels.fromJson(json.decode(str));

String refferHistoryModelsToJson(RefferHistoryModels data) =>
    json.encode(data.toJson());

/// =======================================================
/// ROOT RESPONSE MODEL
/// =======================================================

class RefferHistoryModels {
  final bool success;
  final String message;
  final ReferralData? data;
  final dynamic meta;

  RefferHistoryModels({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory RefferHistoryModels.fromJson(Map<String, dynamic> json) {
    return RefferHistoryModels(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ReferralData.fromJson(json['data'])
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
        'meta': meta,
      };
}

/// =======================================================
/// REFERRAL DATA
/// =======================================================

class ReferralData {
  final double walletBalance;
  final String redeemReferralCode;        // optional (future-safe)
  final bool showReferralRedemption;      // optional (future-safe)
  final List<ReferralHistory> history;

  ReferralData({
    required this.walletBalance,
    required this.redeemReferralCode,
    required this.showReferralRedemption,
    required this.history,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      walletBalance: _toDouble(json['walletBalance']),
      redeemReferralCode: json['redeemReferralCode'] ?? '',
      showReferralRedemption: json['showReferralRedemption'] ?? false,
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => ReferralHistory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'walletBalance': walletBalance,
        'redeemReferralCode': redeemReferralCode,
        'showReferralRedemption': showReferralRedemption,
        'history': history.map((e) => e.toJson()).toList(),
      };
}

/// =======================================================
/// REFERRAL HISTORY ITEM
/// =======================================================

class ReferralHistory {
  final ReferredUser? referredUser;
  final String referredUserName;
  final double amountEarned;
  final DateTime? referredAt;
  final String status;

  ReferralHistory({
    this.referredUser,
    required this.referredUserName,
    required this.amountEarned,
    this.referredAt,
    required this.status,
  });

  factory ReferralHistory.fromJson(Map<String, dynamic> json) {
    final referredUserJson = json['referredUser'];

    return ReferralHistory(
      referredUser: referredUserJson != null
          ? ReferredUser.fromJson(referredUserJson)
          : null,

      /// ✅ NAME PRIORITY FIX
      /// 1️⃣ referredUser.name
      /// 2️⃣ referredUserName
      /// 3️⃣ "User"
      referredUserName: referredUserJson?['name']
          ?? json['referredUserName']
          ?? 'User',

      amountEarned: _toDouble(json['amountEarned']),
      referredAt: json['referredAt'] != null
          ? DateTime.tryParse(json['referredAt'])
          : null,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'referredUser': referredUser?.toJson(),
        'referredUserName': referredUserName,
        'amountEarned': amountEarned,
        'referredAt': referredAt?.toIso8601String(),
        'status': status,
      };
}

/// =======================================================
/// REFERRED USER
/// =======================================================

class ReferredUser {
  final String id;
  final String name;
  final String phone;

  ReferredUser({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'phone': phone,
      };
}

/// =======================================================
/// SAFE NUMBER PARSER (INT / DOUBLE / STRING)
/// =======================================================

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
