
import 'dart:convert';
import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/settingmodels/kycstatusmodels.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Add this import

class KycStatusRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  // Fetch KYC Status
  Future<KycStatusModels> fetchKycStatus() async {
    try {
      final userId = await SessionManager.getUserId();
      final url = "${AppUrl.kycverf}$userId";
      final response = await _apiServices.getApiResponse(url);

      if (response != null) {
        final Map<String, dynamic> jsonData =
            response is String ? json.decode(response) : response;
        return KycStatusModels.fromJson(jsonData);
      } else {
        return KycStatusModels(
          success: false,
          message: "No response from server",
          data: null,
          meta: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("KycStatusRepo fetchKycStatus Error: $e");
      }
      return KycStatusModels(
        success: false,
        message: "Failed to fetch KYC status. Please try again.",
        data: null,
        meta: null,
      );
    }
  }

  // Upload KYC Documents (for rejected status)
  Future<KycStatusModels> uploadKycDocuments(String aadhaarPath, String panPath) async {
    try {
      final userId = await SessionManager.getUserId();
      final url = "${AppUrl.kycreject}$userId";

      if (kDebugMode) {
        print("📤 Upload URL: $url");
        print("📄 Aadhaar Path: $aadhaarPath");
        print("📄 PAN Path: $panPath");
      }

      var request = http.MultipartRequest('PUT', Uri.parse(url));
      
      // Get token if needed
      final token = await SessionManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'multipart/form-data';

      // FIXED: Use correct field names and explicitly set content type
      // The backend validates MIME types, so we must set them correctly
      
      // Determine MIME type based on file extension
      MediaType getContentType(String path) {
        final extension = path.toLowerCase().split('.').last;
        switch (extension) {
          case 'pdf':
            return MediaType('application', 'pdf');
          case 'jpg':
          case 'jpeg':
            return MediaType('image', 'jpeg');
          case 'png':
            return MediaType('image', 'png');
          default:
            return MediaType('application', 'pdf'); // default to PDF
        }
      }

      // Add Aadhaar with explicit content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'Aadharcard',
          aadhaarPath,
          contentType: getContentType(aadhaarPath),
        )
      );
      
      // Add PAN card with explicit content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'pancard',
          panPath,
          contentType: getContentType(panPath),
        )
      );

      if (kDebugMode) {
        print("📋 Request Headers: ${request.headers}");
        print("📋 Request Files: ${request.files.map((f) => f.field).toList()}");
      }

      // Send request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
        print("✅ Response Body: $responseString");
      }

      final jsonData = json.decode(responseString);

      if (response.statusCode == 200) {
        if (jsonData['success'] == true) {
          return KycStatusModels.fromJson(jsonData);
        } else {
          return KycStatusModels(
            success: false,
            message: jsonData['message'] ?? "Failed to upload documents",
            data: null,
            meta: null,
          );
        }
      } else {
        return KycStatusModels(
          success: false,
          message: jsonData['message'] ?? "Server error: ${response.statusCode}",
          data: null,
          meta: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ KycStatusRepo uploadKycDocuments Error: $e");
      }
      return KycStatusModels(
        success: false,
        message: "Failed to upload documents. Error: $e",
        data: null,
        meta: null,
      );
    }
  }
}