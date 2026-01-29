import 'dart:convert';
import 'dart:io';
import 'package:aishwarya_gold/core/exception/appexception.dart';
import 'package:aishwarya_gold/core/network/base_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class NetworkApiServices extends BaseApiServices {
  final SessionManager _sharedPref = SessionManager();
  
  // Helper method to get headers with token
  Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    String? token = await SessionManager.getAccessToken();
    
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    
    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    print("🔑 Request headers: ${headers.keys.toList()}");
    if (token != null) {
      print("🔑 Token present: ${token.substring(0, 20)}...");
    }
    
    return headers;
  }
  
@override
Future<dynamic> getApiResponse(String url,
    {Map<String, String>? headers, Map<String, dynamic>? body}) async {
  try {
    print("🌐 GET url: $url");

    // ✅ Get access token manually (don’t use _getHeaders)
    final token = await SessionManager.getAccessToken();

    // ✅ Build headers — only Authorization, no Content-Type
    final requestHeaders = <String, String>{};
    if (token != null && token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    // ✅ Add custom headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    print("🔑 Final GET Headers: $requestHeaders");

    final response = await http.get(Uri.parse(url), headers: requestHeaders);

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...");

    return _processResponse(response);
  } on SocketException {
    throw FetchDataException("No Internet connection");
  }
}


  @override
  Future<dynamic> postApiResponse(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    List<XFile>? files,
  }) async {
    try {
      print("🌐 POST url: $url");
      
      if (files != null && files.isNotEmpty) {
        // Multipart request with files
        String? token = await SessionManager.getAccessToken();
        
        var request = http.MultipartRequest("POST", Uri.parse(url));
        
        // Add authorization header for multipart
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
          print("🔑 Token added to multipart request");
        }
        
        // Add additional headers if provided
        if (headers != null) {
          request.headers.addAll(headers);
        }
        
        // Add fields from data
        if (data != null) {
          if (data is Map<String, dynamic>) {
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          } else if (data is String) {
            Map<String, dynamic> data1 = json.decode(data);
            data1.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }
        
        // Add files
        for (var file in files) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            file.path,
          ));
        }
        
        final response = await http.Response.fromStream(await request.send());
        return _processResponse(response);
      } else {
        // Regular JSON POST request
        final requestHeaders = await _getHeaders(additionalHeaders: headers);
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: requestHeaders,
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    }
  }

  Future<dynamic> postApiResponseWithNamedFiles(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Map<String, XFile>? files,
  }) async {
    try {
      print("🌐 POST (named files) url: $url");
      
      String? token = await SessionManager.getAccessToken();
      
      if (files != null && files.isNotEmpty) {
        var request = http.MultipartRequest("POST", Uri.parse(url));
        
        // Add authorization header
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add additional headers
        if (headers != null) {
          request.headers.addAll(headers);
        }
        
        // Add fields
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        
        // Add named files
        for (var entry in files.entries) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ));
        }
        
        final response = await http.Response.fromStream(await request.send());
        return _processResponse(response);
      } else {
        final requestHeaders = await _getHeaders(additionalHeaders: headers);
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: requestHeaders,
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    }
  }

  Future<dynamic> putApiResponse(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    List<XFile>? images,
  }) async {
    try {
      print("🌐 PUT url: $url");
      
      String? token = await SessionManager.getAccessToken();
      
      if (images != null && images.isNotEmpty) {
        var imageFile = images.first;
        var imageBytes = await imageFile.readAsBytes();

        var request = http.Request("PUT", Uri.parse(url));
        
        // Add authorization header
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        request.headers['Content-Type'] = 'application/octet-stream';
        request.bodyBytes = imageBytes;

        if (data != null) {
          String jsonData = jsonEncode(data);
          request.headers['Content-Type'] = 'application/json';
          request.body = jsonData;
        }
        
        final response = await http.Response.fromStream(await request.send());
        return await _processResponse(response);
      } else {
        final requestHeaders = await _getHeaders(additionalHeaders: headers);
        final response = await http.put(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: requestHeaders,
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    }
  }

  Future<dynamic> patchApiResponse(String url, dynamic data,
      {Map<String, String>? headers, List<XFile>? images}) async {
    try {
      print("🌐 PATCH url: $url");
      
      String? token = await SessionManager.getAccessToken();

      if (images != null && images.isNotEmpty) {
        var request = http.MultipartRequest("PATCH", Uri.parse(url));
        
        // Add authorization header
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add additional headers
        if (headers != null) {
          request.headers.addAll(headers);
        }

        // Add fields
        if (data != null) {
          if (data is Map<String, dynamic>) {
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          } else if (data is String) {
            Map<String, dynamic> dataMap = json.decode(data);
            dataMap.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }

        // Add images
        for (var image in images) {
          request.files.add(await http.MultipartFile.fromPath(
            'image',
            image.path,
          ));
        }

        final response = await http.Response.fromStream(await request.send());
        return await _processResponse(response);
      } else {
        final requestHeaders = await _getHeaders(additionalHeaders: headers);
        final response = await http.patch(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: requestHeaders,
        );
        print("📤 Request data: $data");
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    }
  }

Future<dynamic> deleteApiResponse(
  String url, {
  Map<String, String>? headers,
  dynamic data,
  List<XFile>? images,
  bool skipContentType = false, // 👈 optional flag
}) async {
  try {
    print("🌐 DELETE url: $url");

    String? token = await SessionManager.getAccessToken();

    // Build headers manually
    final requestHeaders = <String, String>{};

    // 👇 Add Authorization only if available
    if (token != null && token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    // 👇 Add other headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // 👇 Add content-type only if not skipped
    if (!skipContentType && !requestHeaders.containsKey('Content-Type')) {
      requestHeaders['Content-Type'] = 'application/json';
    }

    print('🔑 Final Headers: $requestHeaders');

    // Case 1: DELETE with Multipart (if images present)
    if (images != null && images.isNotEmpty) {
      var request = http.MultipartRequest("DELETE", Uri.parse(url));
      request.headers.addAll(requestHeaders);

      // Add fields if present
      if (data != null) {
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            request.fields[key] = value.toString();
          });
        } else if (data is String) {
          Map<String, dynamic> dataMap = json.decode(data);
          dataMap.forEach((key, value) {
            request.fields[key] = value.toString();
          });
        }
      }

      // Add images
      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await http.Response.fromStream(await request.send());
      return await _processResponse(response);
    }

    // Case 2: Normal DELETE request
    final response = await http.delete(
      Uri.parse(url),
      headers: requestHeaders,
      body: (data != null) ? jsonEncode(data) : null,
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    return _processResponse(response);
  } on SocketException {
    throw FetchDataException("No Internet connection");
  }
}

  
  
  
  
  dynamic _processResponse(http.Response response) {
    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...");
    
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.body.isNotEmpty ? jsonDecode(response.body) : response;
      case 404:
        return jsonDecode(response.body);
      case 400:
        final decoded = jsonDecode(response.body);
        final errorMessage = decoded['message'] ?? 'Bad request occurred';
        throw BadRequestException(errorMessage);
      case 401:
      case 403:
        final decoded = jsonDecode(response.body);
        final errorMessage = decoded['message'] ?? 'Unauthorized access';
        throw UnauthorizedException(errorMessage);
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server. Status code: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> postApiResponseWithHeader(
  String url,
  Map<String, dynamic> body,
  Map<String, String> headers,
) async {
  try {
    print("🌐 POST (with header) url: $url");
    print("📤 Request body: $body");
    print("🔑 Request headers: $headers");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  } on SocketException {
    throw FetchDataException("No Internet connection");
  } catch (e) {
    print("🔴 postApiResponseWithHeader Error: $e");
    rethrow;
  }
}

}