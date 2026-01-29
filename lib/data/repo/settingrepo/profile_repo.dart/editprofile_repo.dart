import 'dart:convert';

import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/settingmodels/editprofile_modles.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:aishwarya_gold/utils/exports/exports.dart' as http;
import 'package:http_parser/http_parser.dart';

class EditprofileRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// Update user profile
Future<UpdateProfileModel?> updateProfile(UserProfile userProfile) async {
  try {
    final userid = await SessionManager.getUserId();
    final url = Uri.parse("${AppUrl.editprofile}/$userid");

    final request = http.MultipartRequest('PUT', url);

    // Add text fields
    request.fields['name'] = userProfile.name ?? '';
    request.fields['email'] = userProfile.email ?? '';

    // Add file if exists
    if (userProfile.profilePath != null && userProfile.profilePath!.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
  'profile',
  userProfile.profilePath!,
  contentType: MediaType('image', 'jpeg'), // or dynamically detect below
));
    }

    // Add headers if needed (like token)
    request.headers['Accept'] = 'application/json';
    // request.headers['Authorization'] = 'Bearer ${yourToken}';

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);


    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UpdateProfileModel.fromJson(json);
    } else {
      return UpdateProfileModel(
        success: false,
        message: "Error: ${response.statusCode}",
        data: null,
        meta: null,
      );
    }
  } catch (e, st) {
    return UpdateProfileModel(
      success: false,
      message: e.toString(),
      data: null,
      meta: null,
    );
  }
}
}
