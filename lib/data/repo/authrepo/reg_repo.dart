import 'dart:convert';
import 'package:aishwarya_gold/data/models/authmodels/reg_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class RegRepo {
  Future<RegModel> registerUser({
    required String name,
    required String phone,
    String? pin,
    String? aadhar,
    String? pan,
    String? referralCode
  }) async {
    final url = Uri.parse(AppUrl.register);
    print("\n📤 Register API: $url");
    print("🧾 Request Fields:");
    print("   Name: $name");
    print("   Phone: $phone");
    print("   PIN: $pin");
    print("   Aadhar: $aadhar");
    print("   PAN: $pan");
    print("   Referral Code: $referralCode");

    var request = http.MultipartRequest('POST', url);
    
    // Add text fields
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    if (pin != null && pin.isNotEmpty) {
      request.fields['pin'] = pin;
    }
    if (referralCode != null && referralCode.isNotEmpty) {
      request.fields['referralCode'] = referralCode; // ← SEND TO SERVER
    }

    // Helper function to determine MIME type
    MediaType? _getMimeType(String filePath) {
      final ext = path.extension(filePath).toLowerCase();
      switch (ext) {
        case '.jpg':
        case '.jpeg':
          return MediaType('image', 'jpeg');
        case '.png':
          return MediaType('image', 'png');
        case '.pdf':
          return MediaType('application', 'pdf');
        case '.webp':
          return MediaType('image', 'webp');
        default:
          return MediaType('application', 'octet-stream');
      }
    }

    try {
      // Add Aadhaar file if provided
      if (aadhar != null && aadhar.isNotEmpty) {
        print("📎 Adding Aadhaar file: ${path.basename(aadhar)}");
        request.files.add(await http.MultipartFile.fromPath(
          'Aadharcard', // Backend expects 'Aadharcard'
          aadhar,
          filename: path.basename(aadhar),
          contentType: _getMimeType(aadhar),
        ));
      }

      // Add PAN file if provided
      if (pan != null && pan.isNotEmpty) {
        print("📎 Adding PAN file: ${path.basename(pan)}");
        request.files.add(await http.MultipartFile.fromPath(
          'pancard', // Try without [] first - backend might expect 'pancard' not 'pancard[]'
          pan,
          filename: path.basename(pan),
          contentType: _getMimeType(pan),
        ));
      }

      print("\n🚀 Sending request to backend...");
      print("📋 Request fields: ${request.fields}");
      print("📎 Request files: ${request.files.map((f) => f.field).toList()}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print("\n📥 Response Status: ${response.statusCode}");
      print("📥 Raw Response Body: $responseBody");

      // Try to parse JSON response
      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(responseBody);
        print("✅ Decoded JSON: $jsonResponse");
      } catch (e) {
        print("❌ Failed to decode JSON: $e");
        return RegModel(
          success: false,
          message: "Invalid response from server: $responseBody",
          data: null,
          meta: null,
        );
      }

      final regModel = RegModel.fromJson(jsonResponse);
      print("🎯 Parsed Model: success=${regModel.success}, message=${regModel.message}");

      // Handle different response scenarios
      if (response.statusCode == 409 ||
          (regModel.message?.toLowerCase().contains('already exists') ?? false) ||
          (regModel.message?.toLowerCase().contains('already registered') ?? false)) {
        print("⚠️ User already exists");
        return RegModel(
          success: false,
          message: "User already exists",
          data: regModel.data,
          meta: regModel.meta,
        );
      } else if (response.statusCode == 400) {
        // Bad request - usually validation errors or unexpected fields
        print("❌ Bad Request (400): ${regModel.message}");
        return RegModel(
          success: false,
          message: regModel.message ?? "Validation failed. Please check your input.",
          data: null,
          meta: null,
        );
      } else if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        print("✅ Registration Successful");
        return regModel;
      } else {
        // Other errors
        print("❌ Registration failed with status ${response.statusCode}");
        return RegModel(
          success: false,
          message: regModel.message ?? "Registration failed: ${response.statusCode}",
          data: null,
          meta: null,
        );
      }
    } catch (e, stackTrace) {
      print("💥 Error in registerUser: $e");
      print("📍 Stack trace: $stackTrace");
      return RegModel(
        success: false,
        message: "Network error: $e",
        data: null,
        meta: null,
      );
    }
  }

Future<bool> checkUserExists(String phone) async {
  final url = Uri.parse(AppUrl.register);

  // 🔥 We try registering WITHOUT files just to check existence
  final response = await http.post(url, body: {
    "name": "temp",
    "phone": phone,
  });

  final data = jsonDecode(response.body);

  if (data["message"] != null &&
      data["message"].toString().toLowerCase().contains("already")) {
    return true; // USER EXISTS
  }

  return false; // NEW USER
}

  // Alternative method if backend expects different field names
  Future<RegModel> registerUserAlt({
    required String name,
    required String phone,
    String? pin,
    String? aadhar,
    String? pan,
  }) async {
    final url = Uri.parse(AppUrl.register);
    print("\n📤 Alternative Register API: $url");

    var request = http.MultipartRequest('POST', url);
    
    // Try different field name variations
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    
    if (pin != null && pin.isNotEmpty) {
      request.fields['pin'] = pin;
    }

    MediaType? _getMimeType(String filePath) {
      final ext = path.extension(filePath).toLowerCase();
      switch (ext) {
        case '.jpg':
        case '.jpeg':
          return MediaType('image', 'jpeg');
        case '.png':
          return MediaType('image', 'png');
        case '.pdf':
          return MediaType('application', 'pdf');
        default:
          return MediaType('application', 'octet-stream');
      }
    }

    try {
      if (aadhar != null && aadhar.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'aadhar', // Try lowercase
          aadhar,
          filename: path.basename(aadhar),
          contentType: _getMimeType(aadhar),
        ));
      }

      if (pan != null && pan.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'pan', // Try lowercase without []
          pan,
          filename: path.basename(pan),
          contentType: _getMimeType(pan),
        ));
      }

      print("🚀 Sending alternative request...");
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print("📥 Response: $responseBody");

      final jsonResponse = jsonDecode(responseBody);
      return RegModel.fromJson(jsonResponse);
    } catch (e) {
      print("💥 Error: $e");
      return RegModel(
        success: false,
        message: "Failed to register: $e",
        data: null,
        meta: null,
      );
    }
  }
}