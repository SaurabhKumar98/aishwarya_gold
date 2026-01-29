import 'dart:convert';

GoldPrice goldPriceFromJson(String str) => GoldPrice.fromJson(json.decode(str));

String goldPriceToJson(GoldPrice data) => json.encode(data.toJson());

class GoldPrice {
  bool? success;
  String? message;
  Data? data;
  dynamic meta;

  GoldPrice({
    this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) => GoldPrice(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "meta": meta,
      };
}

class Data {
  double? currentPricePerGram;

  Data({this.currentPricePerGram});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currentPricePerGram: json["currentPricePerGram"] != null
            ? json["currentPricePerGram"].toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "currentPricePerGram": currentPricePerGram,
      };
}
