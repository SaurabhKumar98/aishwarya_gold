import 'dart:convert';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/history_models/history_models.dart';
import 'package:aishwarya_gold/data/models/savingagplanmodels/agsavingmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:http/http.dart' as http;

class HistoryRepository {

  Future<HistoryModels> fetchUserPlans(String userId) async {
    try {
      final userId =await SessionManager.getUserId();
      final url = await http.get(
        Uri.parse('${AppUrl.historyurl}$userId'), );
      

      if (url.statusCode == 200) {
        final jsonData = json.decode(url.body);
        return HistoryModels.fromJson(jsonData);
      } else {
        throw Exception('Failed to load plans: ${url.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching plans: $e');
    }
  }
}