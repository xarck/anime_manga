import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadProvider extends ChangeNotifier {
  List downloads;
  bool currentlyDownloading = false;
  bool alreadyExists = false;
  intialize() async {
    downloads = await FlutterDownloader.loadTasks();
    notifyListeners();
  }

  checkDownloading(videoUrl) async {
    await intialize();
    downloads.forEach((element) {
      if (element.status.value == 2) {
        currentlyDownloading = true;
      }
      if (element.url == videoUrl) {
        alreadyExists = true;
      }
    });
    notifyListeners();
  }
}
