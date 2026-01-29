// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AuthApi {
//   static const String baseUrl = "http://10.0.2.2:8000/user"; // emulator friendly

//   // Sign Up + Send OTP
//   static Future<Map<String, dynamic>> registerUser({
//     required String name,
//     required String phone,
//   }) async {
//     final url = Uri.parse('$baseUrl/register');

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "name": name,
//         "phone": phone,
//       }),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to register: ${response.body}');
//     }
//   }
// }
