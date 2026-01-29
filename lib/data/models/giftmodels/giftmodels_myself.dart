// lib/data/models/giftmodels/giftmodels_myself.dart

class MySelfGiftRequest {
  // final String? userId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final int giftValue;
  final String giftType; // "myself"
  final String message;

  MySelfGiftRequest({
    //  this.userId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.giftValue,
    required this.giftType,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        // "userId": userId,
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "giftValue": giftValue,
        "giftType": giftType,
        "message": message,
      };
}

class MySelfGiftResponse {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic meta;

  MySelfGiftResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory MySelfGiftResponse.fromJson(Map<String, dynamic> json) =>
      MySelfGiftResponse(
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
