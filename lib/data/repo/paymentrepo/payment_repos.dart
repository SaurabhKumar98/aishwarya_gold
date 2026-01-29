// // // repository/payment_repository.dart

// // import 'dart:convert';
// // import 'package:aishwarya_gold/data/models/payment_method_models.dart';
// // import 'package:http/http.dart' as http;

// // class PaymentRepository {
// //   final String baseUrl;
// //   final Map<String, String> headers;

// //   PaymentRepository({
// //     required this.baseUrl,
// //     Map<String, String>? headers,
// //   }) : headers = headers ?? {
// //     'Content-Type': 'application/json',
// //     'Accept': 'application/json',
// //   };

// //   // Get all payment methods
// //   Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('$baseUrl/payment-methods'),
// //         headers: headers,
// //       );

// //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

// //       if (response.statusCode == 200) {
// //         final List<dynamic> data = jsonResponse['data'] ?? [];
// //         final List<PaymentMethod> paymentMethods = data
// //             .map((item) => PaymentMethod.fromJson(item))
// //             .toList();

// //         return ApiResponse<List<PaymentMethod>>(
// //           success: true,
// //           data: paymentMethods,
// //           message: jsonResponse['message'],
// //         );
// //       } else {
// //         return ApiResponse<List<PaymentMethod>>(
// //           success: false,
// //           error: jsonResponse['error'] ?? 'Failed to fetch payment methods',
// //         );
// //       }
// //     } catch (e) {
// //       return ApiResponse<List<PaymentMethod>>(
// //         success: false,
// //         error: 'Network error: $e',
// //       );
// //     }
// //   }

// //   // Add new payment method
// //   Future<ApiResponse<PaymentMethod>> addPaymentMethod(
// //       AddPaymentMethodRequest request) async {
// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/payment-methods'),
// //         headers: headers,
// //         body: json.encode(request.toJson()),
// //       );

// //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         final PaymentMethod paymentMethod = PaymentMethod.fromJson(jsonResponse['data']);

// //         return ApiResponse<PaymentMethod>(
// //           success: true,
// //           data: paymentMethod,
// //           message: jsonResponse['message'] ?? 'Payment method added successfully',
// //         );
// //       } else {
// //         return ApiResponse<PaymentMethod>(
// //           success: false,
// //           error: jsonResponse['error'] ?? 'Failed to add payment method',
// //         );
// //       }
// //     } catch (e) {
// //       return ApiResponse<PaymentMethod>(
// //         success: false,
// //         error: 'Network error: $e',
// //       );
// //     }
// //   }

// //   // Update payment method
// //   Future<ApiResponse<PaymentMethod>> updatePaymentMethod(
// //       String id, AddPaymentMethodRequest request) async {
// //     try {
// //       final response = await http.put(
// //         Uri.parse('$baseUrl/payment-methods/$id'),
// //         headers: headers,
// //         body: json.encode(request.toJson()),
// //       );

// //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

// //       if (response.statusCode == 200) {
// //         final PaymentMethod paymentMethod = PaymentMethod.fromJson(jsonResponse['data']);

// //         return ApiResponse<PaymentMethod>(
// //           success: true,
// //           data: paymentMethod,
// //           message: jsonResponse['message'] ?? 'Payment method updated successfully',
// //         );
// //       } else {
// //         return ApiResponse<PaymentMethod>(
// //           success: false,
// //           error: jsonResponse['error'] ?? 'Failed to update payment method',
// //         );
// //       }
// //     } catch (e) {
// //       return ApiResponse<PaymentMethod>(
// //         success: false,
// //         error: 'Network error: $e',
// //       );
// //     }
// //   }

// //   // Delete payment method
// //   Future<ApiResponse<String>> deletePaymentMethod(String id) async {
// //     try {
// //       final response = await http.delete(
// //         Uri.parse('$baseUrl/payment-methods/$id'),
// //         headers: headers,
// //       );

// //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

// //       if (response.statusCode == 200) {
// //         return ApiResponse<String>(
// //           success: true,
// //           message: jsonResponse['message'] ?? 'Payment method deleted successfully',
// //         );
// //       } else {
// //         return ApiResponse<String>(
// //           success: false,
// //           error: jsonResponse['error'] ?? 'Failed to delete payment method',
// //         );
// //       }
// //     } catch (e) {
// //       return ApiResponse<String>(
// //         success: false,
// //         error: 'Network error: $e',
// //       );
// //     }
// //   }

// //   // Set primary payment method
// //   Future<ApiResponse<String>> setPrimaryPaymentMethod(String id) async {
// //     try {
// //       final response = await http.patch(
// //         Uri.parse('$baseUrl/payment-methods/$id/set-primary'),
// //         headers: headers,
// //       );

// //       final Map<String, dynamic> jsonResponse = json.decode(response.body);

// //       if (response.statusCode == 200) {
// //         return ApiResponse<String>(
// //           success: true,
// //           message: jsonResponse['message'] ?? 'Primary payment method updated',
// //         );
// //       } else {
// //         return ApiResponse<String>(
// //           success: false,
// //           error: jsonResponse['error'] ?? 'Failed to set primary payment method',
// //         );
// //       }
// //     } catch (e) {
// //       return ApiResponse<String>(
// //         success: false,
// //         error: 'Network error: $e',
// //       );
// //     }
// //   }
// // }

// // repository/payment_repository.dart

// import 'dart:convert';
// import 'package:aishwarya_gold/data/models/payment_method_models.dart';
// import 'package:http/http.dart' as http;

// class PaymentRepository {
//   final String baseUrl;
//   final Map<String, String> headers;
//   final bool useStaticData;

//   // Static data storage for testing
//   static List<PaymentMethod> _staticPaymentMethods = [
//     PaymentMethod(
//       id: '1',
//       type: 'upi',
//       displayName: 'saurabh@okicici',
//       identifier: 'saurabh@okicici',
//       isPrimary: true,
//       createdAt: DateTime.now().subtract(const Duration(days: 10)),
//     ),
//     PaymentMethod(
//       id: '2',
//       type: 'bank',
//       displayName: 'HDFC Bank',
//       identifier: '****1234',
//       bankName: 'HDFC Bank',
//       ifscCode: 'HDFC0001234',
//       isPrimary: false,
//       createdAt: DateTime.now().subtract(const Duration(days: 5)),
//     ),
//   ];

//   PaymentRepository({
//     required this.baseUrl,
//     Map<String, String>? headers,
//     this.useStaticData = true, // Set to false when you want to use API
//   }) : headers = headers ?? {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };

//   // Get all payment methods
//   Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
//     if (useStaticData) {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 800));
      
//       return ApiResponse<List<PaymentMethod>>(
//         success: true,
//         data: List.from(_staticPaymentMethods),
//         message: 'Payment methods retrieved successfully',
//       );
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payment-methods'),
//         headers: headers,
//       );

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonResponse['data'] ?? [];
//         final List<PaymentMethod> paymentMethods = data
//             .map((item) => PaymentMethod.fromJson(item))
//             .toList();

//         return ApiResponse<List<PaymentMethod>>(
//           success: true,
//           data: paymentMethods,
//           message: jsonResponse['message'],
//         );
//       } else {
//         return ApiResponse<List<PaymentMethod>>(
//           success: false,
//           error: jsonResponse['error'] ?? 'Failed to fetch payment methods',
//         );
//       }
//     } catch (e) {
//       return ApiResponse<List<PaymentMethod>>(
//         success: false,
//         error: 'Network error: $e',
//       );
//     }
//   }

//   // Add new payment method
//   Future<ApiResponse<PaymentMethod>> addPaymentMethod(
//       AddPaymentMethodRequest request) async {
//     if (useStaticData) {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 1000));

//       // Create new payment method
//       final newPaymentMethod = PaymentMethod(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         type: request.type,
//         displayName: request.displayName,
//         identifier: request.identifier,
//         bankName: request.bankName,
//         ifscCode: request.ifscCode,
//         isPrimary: _staticPaymentMethods.isEmpty, // First one becomes primary
//         createdAt: DateTime.now(),
//       );

//       _staticPaymentMethods.add(newPaymentMethod);

//       return ApiResponse<PaymentMethod>(
//         success: true,
//         data: newPaymentMethod,
//         message: 'Payment method added successfully',
//       );
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/payment-methods'),
//         headers: headers,
//         body: json.encode(request.toJson()),
//       );

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final PaymentMethod paymentMethod = PaymentMethod.fromJson(jsonResponse['data']);

//         return ApiResponse<PaymentMethod>(
//           success: true,
//           data: paymentMethod,
//           message: jsonResponse['message'] ?? 'Payment method added successfully',
//         );
//       } else {
//         return ApiResponse<PaymentMethod>(
//           success: false,
//           error: jsonResponse['error'] ?? 'Failed to add payment method',
//         );
//       }
//     } catch (e) {
//       return ApiResponse<PaymentMethod>(
//         success: false,
//         error: 'Network error: $e',
//       );
//     }
//   }

//   // Update payment method
//   Future<ApiResponse<PaymentMethod>> updatePaymentMethod(
//       String id, AddPaymentMethodRequest request) async {
//     if (useStaticData) {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 800));

//       final index = _staticPaymentMethods.indexWhere((method) => method.id == id);
//       if (index == -1) {
//         return ApiResponse<PaymentMethod>(
//           success: false,
//           error: 'Payment method not found',
//         );
//       }

//       // Update the payment method
//       final updatedMethod = _staticPaymentMethods[index].copyWith(
//         displayName: request.displayName,
//         identifier: request.identifier,
//         bankName: request.bankName,
//         ifscCode: request.ifscCode,
//       );

//       _staticPaymentMethods[index] = updatedMethod;

//       return ApiResponse<PaymentMethod>(
//         success: true,
//         data: updatedMethod,
//         message: 'Payment method updated successfully',
//       );
//     }

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/payment-methods/$id'),
//         headers: headers,
//         body: json.encode(request.toJson()),
//       );

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       if (response.statusCode == 200) {
//         final PaymentMethod paymentMethod = PaymentMethod.fromJson(jsonResponse['data']);

//         return ApiResponse<PaymentMethod>(
//           success: true,
//           data: paymentMethod,
//           message: jsonResponse['message'] ?? 'Payment method updated successfully',
//         );
//       } else {
//         return ApiResponse<PaymentMethod>(
//           success: false,
//           error: jsonResponse['error'] ?? 'Failed to update payment method',
//         );
//       }
//     } catch (e) {
//       return ApiResponse<PaymentMethod>(
//         success: false,
//         error: 'Network error: $e',
//       );
//     }
//   }

//   // Delete payment method
//   Future<ApiResponse<String>> deletePaymentMethod(String id) async {
//     if (useStaticData) {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 600));

//       final index = _staticPaymentMethods.indexWhere((method) => method.id == id);
//       if (index == -1) {
//         return ApiResponse<String>(
//           success: false,
//           error: 'Payment method not found',
//         );
//       }

//       // If deleting primary method, make another one primary
//       final deletingPrimary = _staticPaymentMethods[index].isPrimary;
//       _staticPaymentMethods.removeAt(index);

//       if (deletingPrimary && _staticPaymentMethods.isNotEmpty) {
//         _staticPaymentMethods[0] = _staticPaymentMethods[0].copyWith(isPrimary: true);
//       }

//       return ApiResponse<String>(
//         success: true,
//         message: 'Payment method deleted successfully',
//       );
//     }

//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/payment-methods/$id'),
//         headers: headers,
//       );

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       if (response.statusCode == 200) {
//         return ApiResponse<String>(
//           success: true,
//           message: jsonResponse['message'] ?? 'Payment method deleted successfully',
//         );
//       } else {
//         return ApiResponse<String>(
//           success: false,
//           error: jsonResponse['error'] ?? 'Failed to delete payment method',
//         );
//       }
//     } catch (e) {
//       return ApiResponse<String>(
//         success: false,
//         error: 'Network error: $e',
//       );
//     }
//   }

//   // Set primary payment method
//   Future<ApiResponse<String>> setPrimaryPaymentMethod(String id) async {
//     if (useStaticData) {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 500));

//       final index = _staticPaymentMethods.indexWhere((method) => method.id == id);
//       if (index == -1) {
//         return ApiResponse<String>(
//           success: false,
//           error: 'Payment method not found',
//         );
//       }

//       // Update all methods to remove primary, then set the selected one as primary
//       for (int i = 0; i < _staticPaymentMethods.length; i++) {
//         _staticPaymentMethods[i] = _staticPaymentMethods[i].copyWith(
//           isPrimary: i == index,
//         );
//       }

//       return ApiResponse<String>(
//         success: true,
//         message: 'Primary payment method updated successfully',
//       );
//     }

//     try {
//       final response = await http.patch(
//         Uri.parse('$baseUrl/payment-methods/$id/set-primary'),
//         headers: headers,
//       );

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);

//       if (response.statusCode == 200) {
//         return ApiResponse<String>(
//           success: true,
//           message: jsonResponse['message'] ?? 'Primary payment method updated',
//         );
//       } else {
//         return ApiResponse<String>(
//           success: false,
//           error: jsonResponse['error'] ?? 'Failed to set primary payment method',
//         );
//       }
//     } catch (e) {
//       return ApiResponse<String>(
//         success: false,
//         error: 'Network error: $e',
//       );
//     }
//   }

//   // Method to switch between static and API data
//   void enableApiMode() {
//     // When ready to connect to API, you can call this method
//     // or simply change useStaticData to false in the constructor
//   }

//   // Clear static data (useful for testing)
//   static void clearStaticData() {
//     _staticPaymentMethods.clear();
//   }

//   // Add mock data
//   static void addMockData() {
//     _staticPaymentMethods = [
//       PaymentMethod(
//         id: '1',
//         type: 'upi',
//         displayName: 'user@okicici',
//         identifier: 'user@okicici',
//         isPrimary: true,
//         createdAt: DateTime.now().subtract(const Duration(days: 10)),
//       ),
//       PaymentMethod(
//         id: '2',
//         type: 'bank',
//         displayName: 'HDFC Bank',
//         identifier: '****1234',
//         bankName: 'HDFC Bank',
//         ifscCode: 'HDFC0001234',
//         isPrimary: false,
//         createdAt: DateTime.now().subtract(const Duration(days: 5)),
//       ),
//     ];
//   }
// }