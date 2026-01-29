import 'dart:convert';
import 'package:aishwarya_gold/data/models/redeemCodemodels/cancelreddemcodemodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:http/http.dart' as http;

class GiftCancelRepo {
  final String baseUrl = "${AppUrl.localUrl}";

  Future<GiftCancelResponse> cancelGift(String token, String code) async {
    final url = Uri.parse("$baseUrl/user/gift/cancel");

    final body = {
      "code": code,
    };

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return GiftCancelResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to cancel gift: ${response.body}");
    }
  }
}
