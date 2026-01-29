import 'dart:convert';

GiftCancelResponse giftCancelResponseFromJson(String str) =>
    GiftCancelResponse.fromJson(json.decode(str));

String giftCancelResponseToJson(GiftCancelResponse data) =>
    json.encode(data.toJson());

class GiftCancelResponse {
  final bool success;
  final String message;
  final GiftCancelData? data;
  final dynamic meta;

  GiftCancelResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory GiftCancelResponse.fromJson(Map<String, dynamic> json) =>
      GiftCancelResponse(
        success: json["success"] is bool ? json["success"] : false,
        message: json["message"] is String ? json["message"] : "",
        data: json["data"] is Map<String, dynamic>
            ? GiftCancelData.fromJson(json["data"])
            : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class GiftCancelData {
  final bool cancelled;
  final String message;
  final String codeType;

  GiftCancelData({
    required this.cancelled,
    required this.message,
    required this.codeType,
  });

  factory GiftCancelData.fromJson(Map<String, dynamic> json) =>
      GiftCancelData(
        cancelled: json["cancelled"] is bool ? json["cancelled"] : false,
        message: json["message"] is String ? json["message"] : "",
        codeType: json["codeType"] is String ? json["codeType"] : "",
      );

  Map<String, dynamic> toJson() => {
        "cancelled": cancelled,
        "message": message,
        "codeType": codeType,
      };
}
