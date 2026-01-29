import 'package:flutter/material.dart';
import 'package:aishwarya_gold/data/models/videomodels/videomodels.dart';
import 'package:aishwarya_gold/data/repo/videorepo/videorepo.dart';

class VideoProvider with ChangeNotifier {
  final Videorepo _repo = Videorepo();

  bool isLoading = false;
  String? errorMessage;
  List<Datum> videoList = [];

Future<void> fetchVideos() async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final VideoModels response = await _repo.getVideos();

    videoList = response.data;   // ✔ Correct

    // 🔥 Add THIS to see URL is coming correctly
    if (videoList.isNotEmpty) {
      print("🔥 PROVIDER URL → ${videoList.first.url}");
    } else {
      print("🔥 PROVIDER has NO videos!");
    }

    isLoading = false;
    notifyListeners();
  } catch (e) {
    isLoading = false;
    errorMessage = e.toString();
    print("❌ VideoProvider Error: $e");
    notifyListeners();
  }
}


}
