import 'dart:convert';

KycStatusModels kycStatusModelsFromJson(String str) =>
    KycStatusModels.fromJson(json.decode(str));

String kycStatusModelsToJson(KycStatusModels data) =>
    json.encode(data.toJson());

class KycStatusModels {
  bool success;
  String message;
  KycStatus? data;
  dynamic meta;

  KycStatusModels({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory KycStatusModels.fromJson(Map<String, dynamic> json) =>
      KycStatusModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "No message provided",
        data: json["data"] != null ? KycStatus.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class KycStatus {
  String name;
  String phone;
  List<String> pancard;
  String aadharcard;
  String kycStatus;

  KycStatus({
    required this.name,
    required this.phone,
    required this.pancard,
    required this.aadharcard,
    required this.kycStatus,
  });

  factory KycStatus.fromJson(Map<String, dynamic> json) => KycStatus(
        name: json["name"] ?? "",
        phone: json["phone"] ?? "",
        pancard: json["pancard"] != null
            ? List<String>.from(json["pancard"].map((x) => x.toString()))
            : [],
        aadharcard: json["Aadharcard"] ?? json["aadharcard"] ?? "",
        kycStatus: json["kycStatus"] ?? json["kyc_status"] ?? "Pending",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "pancard": List<dynamic>.from(pancard.map((x) => x)),
        "Aadharcard": aadharcard,
        "kycStatus": kycStatus,
      };
}