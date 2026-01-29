// To parse this JSON data, do
//
//     final agPlanModel = agPlanModelFromJson(jsonString);

import 'dart:convert';

AgPlanModel agPlanModelFromJson(String str) => AgPlanModel.fromJson(json.decode(str));

String agPlanModelToJson(AgPlanModel data) => json.encode(data.toJson());

class AgPlanModel {
  final bool? success;
  final String? message;
  final List<Plan>? data;
  final Meta? meta;

  AgPlanModel({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory AgPlanModel.fromJson(Map<String, dynamic> json) => AgPlanModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Plan>.from(json["data"].map((x) => Plan.fromJson(x))),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "meta": meta?.toJson(),
      };
}

class Plan {
  final String? id;
  final String? name;
  final String? type;
  final int? amount;
  final int? durationMonths;
  final int? totalInvestment;
  final int? profitBonus;
  final int? maturityAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String ?orderId;
  final String ? paymentId;
  final String ? signature;

  Plan({
    this.id,
    this.name,
    this.type,
    this.amount,
    this.durationMonths,
    this.totalInvestment,
    this.profitBonus,
    this.maturityAmount,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.orderId,
    this.paymentId,
    this.signature,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["_id"],
        name: json["name"],
        type: json["type"],
        amount: json["amount"],
        durationMonths: json["durationMonths"],
        totalInvestment: json["totalInvestment"],
        profitBonus: json["profitBonus"],
        maturityAmount: json["maturityAmount"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
        v: json["__v"],
        orderId: json['orderId'],
        signature: json['signature'],
        paymentId: json['paymentId']
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "type": type,
        "amount": amount,
        "durationMonths": durationMonths,
        "totalInvestment": totalInvestment,
        "profitBonus": profitBonus,
        "maturityAmount": maturityAmount,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        'orderId':orderId,
        'paymentId':paymentId,
        'signature':signature
      };
}

class Meta {
  final int? page;
  final int? limit;
  final int? total;
  final int? pages;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.pages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "pages": pages,
      };
}
