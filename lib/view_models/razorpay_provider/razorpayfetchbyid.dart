// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// /// Provider to fetch plan details from Razorpay by ID
// class RazorpayPlanProvider with ChangeNotifier {
//   bool _loading = false;
//   Map<String, dynamic>? _planData;
//   String? _errorMessage;

//   bool get loading => _loading;
//   Map<String, dynamic>? get planData => _planData;
//   String? get errorMessage => _errorMessage;

//   static const String baseUrl = "https://api.razorpay.com/v1/plans";
//   static const String keyId = "rzp_test_RbX65RuyVPVf9h"; // 🔑 Replace with your Key ID
//   static const String keySecret = "wb6dy4QthkPT65aQ5g9lgw8R"; // 🔒 Replace with your Key Secret

//   /// Fetch Plan Details by ID
//   Future<void> fetchPlanById(String planId) async {
//     _loading = true;
//     _errorMessage = null;
//     _planData = null;
//     notifyListeners();

//     try {
//       final uri = Uri.parse("$baseUrl/$planId");

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization':
//               'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         _planData = jsonDecode(response.body);
//       } else {
//         final errorBody = jsonDecode(response.body);
//         _errorMessage = errorBody['error']?['description'] ??
//             'Failed to fetch plan details.';
//       }
//     } catch (e) {
//       _errorMessage = "Error fetching plan: $e";
//     } finally {
//       _loading = false;
//       notifyListeners();
//     }
//   }
// }
