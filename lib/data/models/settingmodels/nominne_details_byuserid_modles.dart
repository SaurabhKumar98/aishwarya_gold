import 'dart:convert';

NomineeDetails nomineeDetailsFromJson(String str) =>
    NomineeDetails.fromJson(json.decode(str));

String nomineeDetailsToJson(NomineeDetails data) =>
    json.encode(data.toJson());

class NomineeDetails {
  bool? success;
  String? message;
  List<Nomineedet>? data;
  Meta? meta;

  NomineeDetails({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory NomineeDetails.fromJson(Map<String, dynamic> json) => NomineeDetails(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<Nomineedet>.from(
                json["data"].map((x) => Nomineedet.fromJson(x)),
              ),
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
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

class Nomineedet {
  String? id;
  UserId? userId;
  String? name;
  String? relation;
  DateTime? dob;
  String? contactNo;
  String? address;
  List<String>? planType;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Nomineedet({
    this.id,
    this.userId,
    this.name,
    this.relation,
    this.dob,
    this.contactNo,
    this.address,
    this.planType,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Nomineedet.fromJson(Map<String, dynamic> json) => Nomineedet(
        id: json["_id"] ?? "",
        userId: json["userId"] != null
            ? UserId.fromJson(json["userId"])
            : null,
        name: json["name"] ?? "",
        relation: json["relation"] ?? "",
        dob: json["DOB"] != null ? DateTime.tryParse(json["DOB"]) : null,
        contactNo: json["contactNo"] ?? "",
        address: json["address"] ?? "",
        planType: json["planType"] == null
            ? []
            : List<String>.from(json["planType"].map((x) => x ?? "")),
        isDeleted: json["isDeleted"] ?? false,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId?.toJson(),
        "name": name,
        "relation": relation,
        "DOB": dob?.toIso8601String(),
        "contactNo": contactNo,
        "address": address,
        "planType": planType == null
            ? []
            : List<dynamic>.from(planType!.map((x) => x)),
        "isDeleted": isDeleted,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class UserId {
  String? id;
  String? name;
  String? email;

  UserId({
    this.id,
    this.name,
    this.email,
  });

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        email: json["email"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
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
        page: json["page"] ?? 0,
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
