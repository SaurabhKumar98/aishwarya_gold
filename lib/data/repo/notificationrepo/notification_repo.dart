import 'package:aishwarya_gold/core/network/network_api_service.dart';
import 'package:aishwarya_gold/data/models/notificationmodels/notification_models.dart';
import 'package:aishwarya_gold/res/constants/urls.dart';

class NotificationRepo {
  final NetworkApiServices _apiServices =NetworkApiServices();
  Future<NotificationModels?> getAllNotifications() async {
    try {
      final response = await _apiServices.getApiResponse(AppUrl.notification);

      if (response != null) {
        return NotificationModels.fromJson(response);
      }
      return null;
    } catch (e) {
     
      rethrow;
    }
  }


}