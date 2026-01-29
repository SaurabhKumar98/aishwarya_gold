import 'dart:convert';

StoreModels storeFromJson(String str) => StoreModels.fromJson(json.decode(str));

String storeToJson(StoreModels data) => json.encode(data.toJson());

class StoreModels {
  bool success;
  String message;
  List<StoreData> data;
  dynamic meta;

  StoreModels({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory StoreModels.fromJson(Map<String, dynamic> json) => StoreModels(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<StoreData>.from(
                (json["data"] as List).map((x) => StoreData.fromJson(x)))
            : [],
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta,
      };

  /// Get only active stores
  List<StoreData> get activeStores {
    return data.where((store) => store.isActive).toList();
  }
}

class StoreData {
  String id;
  String? storeId;
  String? name;
  String? location;
  String? map;
  String? number;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String storeImage;

  StoreData({
    required this.id,
    this.storeId,
    this.name,
    this.location,
    this.map,
    this.number,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    required this.storeImage,
  });

  /// Check if store is active
  bool get isActive {
    if (status == null) return true; // Default to active if status not provided
    return status!.toLowerCase() == 'active';
  }

  factory StoreData.fromJson(Map<String, dynamic> json) => StoreData(
        id: json["_id"] ?? "",
        storeId: json["storeId"],
        name: json["name"],
        location: json["location"],
        map: json["map"],
        number: json["number"],
        status: json["status"],
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        v: json["__v"],
        storeImage: json["storeImage"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "storeId": storeId,
        "name": name,
        "location": location,
        "map": map,
        "number": number,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "storeImage": storeImage,
      };
}