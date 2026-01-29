// lib/data/models/gift_model.dart

// lib/data/models/giftmodels/send_giftmodels.dart

class GiftRequest {
  // final String? userId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final int giftValue;
  final String giftType; // "others"
  final String name;
  final String email;
  final String phone;
  final String message;

  GiftRequest({
    //  this.userId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.giftValue,
    required this.giftType,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        // "userId": userId,
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "giftValue": giftValue,
        "giftType": giftType,
        "name": name,
        "email": email,
        "phone": phone,
        "message": message,
      };
}

class GiftResponse {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic meta;

  GiftResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory GiftResponse.fromJson(Map<String, dynamic> json) => GiftResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
        meta: json['meta'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data,
        'meta': meta,
      };
}
