import 'dart:convert';

OneTimeSavingPlan oneTimeSavingPlanFromJson(String str) =>
    OneTimeSavingPlan.fromJson(json.decode(str));

String oneTimeSavingPlanToJson(OneTimeSavingPlan data) =>
    json.encode(data.toJson());

class OneTimeSavingPlan {
  bool success;
  String message;
  List<OneTimeSav>? data;
  Meta? meta;

  OneTimeSavingPlan({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory OneTimeSavingPlan.fromJson(Map<String, dynamic> json) =>
      OneTimeSavingPlan(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? null
            : List<OneTimeSav>.from(
                json["data"].map((x) => OneTimeSav.fromJson(x))),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "meta": meta?.toJson(),
      };
}

class OneTimeSav {
  String? id;
  UserId? userId; // <-- FIXED: now supports nested map
  double? goldQty;
  double? totalAmountToPay;
  double? gstAmount;
  double? discountAmount;
  double? amountPaid;
  double? currentDayGoldPrice;
  String? redeemCode;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  

  OneTimeSav({
    this.id,
    this.userId,
    this.goldQty,
    this.totalAmountToPay,
    this.gstAmount,
    this.discountAmount,
    this.amountPaid,
    this.currentDayGoldPrice,
    this.redeemCode,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OneTimeSav.fromJson(Map<String, dynamic> json) => OneTimeSav(
        id: json["_id"] ?? "",
        userId: json["userId"] == null
            ? null
            : json["userId"] is String
                ? UserId(id: json["userId"]) // handle both string & object
                : UserId.fromJson(json["userId"]),
        goldQty: (json["goldQty"] ?? 0).toDouble(),
        totalAmountToPay: (json["totalAmountToPay"] ?? 0).toDouble(),
        gstAmount: (json["gstAmount"] ?? 0).toDouble(),
        discountAmount: (json["discountAmount"] ?? 0).toDouble(),
        amountPaid: (json["amountPaid"] ?? 0).toDouble(),
        currentDayGoldPrice: (json["currentDayGoldPrice"] ?? 0).toDouble(),
        redeemCode: json["redeemCode"] ?? "",
        status: json["status"] ?? "",
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId?.toJson(),
        "goldQty": goldQty,
        "totalAmountToPay": totalAmountToPay,
        "gstAmount": gstAmount,
        "discountAmount": discountAmount,
        "amountPaid": amountPaid,
        "currentDayGoldPrice": currentDayGoldPrice,
        "redeemCode": redeemCode,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class UserId {
  String? id;
  String? name;

  UserId({
    this.id,
    this.name,
  });

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

class Meta {
  int? page;
  int? limit;
  int? totalRecords;
  int? totalPages;

  Meta({
    this.page,
    this.limit,
    this.totalRecords,
    this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"] ?? 1,
        limit: json["limit"] ?? 0,
        totalRecords: json["totalRecords"] ?? 0,
        totalPages: json["totalPages"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "totalRecords": totalRecords,
        "totalPages": totalPages,
      };
}
