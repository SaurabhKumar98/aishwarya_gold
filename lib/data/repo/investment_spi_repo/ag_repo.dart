import 'dart:convert';
import 'package:aishwarya_gold/data/models/agplanmodels/agplanmodel.dart';
import 'package:aishwarya_gold/data/models/agplanmodels/purchase_agplan_modles.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:http/http.dart' as http;
 // <-- your existing AppUrl file

class AgRepository {
  /// Fetch all AG Plans (e.g., type = "monthly" or "yearly")
  Future<AgPlanModel?> fetchAgPlans({
    String type = "monthly",
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppUrl.localUrl}/admin/agplans?type=$type&page=$page&limit=$limit",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return AgPlanModel.fromJson(jsonResponse);
        
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

    Future<Plan?> fetchAgPlanById(String id) async {
    try {
      final uri = Uri.parse("${AppUrl.localUrl}/admin/agplans/$id");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body); 
    
        if (jsonResponse["success"] == true && jsonResponse["data"] != null) {
          
          return Plan.fromJson(jsonResponse["data"]);
  
        } else {
         
        }
      } else {
        
      }
    } catch (e) {
      
    }
    return null;
  }

  /// Add a plan to a local in-memory list (for temporary use)
  void addPlan(
    List<Map<String, dynamic>> agPlans,
    Plan plan,
    DateTime startDate,
    DateTime endDate,
    int amount,
  ) {
    agPlans.add({
      'amount': amount,
      'plan': plan,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  Future<PurchaseAgModel?> purchaseAgPlan({
    required String userId,
    required String planId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppUrl.buyagPlan}'), // Replace with your actual endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'planId': planId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PurchaseAgModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to purchase plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error purchasing plan: $e');
    }
  }
}
