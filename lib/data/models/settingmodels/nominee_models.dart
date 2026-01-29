import 'dart:convert';

// To parse JSON string
Nominee nomineeFromJson(String str) => Nominee.fromJson(json.decode(str));

String nomineeToJson(Nominee data) => json.encode(data.toJson());

class Nominee {
  String? userId;
  String? name;
  String? relation;
  DateTime? dob;
  String? contactNo;
  String? address;
  List<String>? planType;

  Nominee({
    this.userId,
    this.name,
    this.relation,
    this.dob,
    this.contactNo,
    this.address,
    this.planType,
  });

  factory Nominee.fromJson(Map<String, dynamic> json) => Nominee(
        userId: json["userId"],
        name: json["name"],
        relation: json["relation"],
        dob: json["DOB"] != null ? DateTime.parse(json["DOB"]) : null,
        contactNo: json["contactNo"],
        address: json["address"],
        planType: json["planType"] != null
            ? List<String>.from(json["planType"])
            : [],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "relation": relation,
        "DOB": dob?.toIso8601String(),
        "contactNo": contactNo,
        "address": address,
        "planType": planType,
      };
}
