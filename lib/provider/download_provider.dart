// import 'dart:io';

// import 'package:desk/models/download.dart';

// import 'package:dio/dio.dart';
// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DownloadProvider extends ChangeNotifier {
//   List<Download> downloading = [];
//   List<Download> pending = [];
//   String name;
//   String videoUrl;
//   Download current;
//   CancelToken cancelToken = CancelToken();

//   // Download Functions
//   Future<void> download(Download item) async {
//     name = item.name;
//     videoUrl = item.epUrl;
//     current = item;
//     final dir = await _getDownloadDirectory();
//     final isPermissionStatusGranted = await _requestPermissions();

//     if (isPermissionStatusGranted) {
//       final savePath = path.join(dir.path, '$name.mp4');
//       await _startDownload(savePath, videoUrl);
//     } else {
//       // handle the scenario when user declines the permissions
//     }
//   }

//   Future<void> _startDownload(String savePath, videoUrl) async {
//     Map<String, dynamic> result = {
//       'isSuccess': false,
//       'filePath': null,
//       'error': null,
//     };
//     try {
//       final response = await Dio().download(
//         videoUrl,
//         savePath,
//         onReceiveProgress: _onReceiveProgress,
//         cancelToken: cancelToken,
//       );
//       result['isSuccess'] = response.statusCode == 200;
//       result['filePath'] = savePath;
//       downloadCompleted(name);
//     } catch (ex) {
//       result['error'] = ex.toString();
//     } finally {
//       // await _showNotification(result);
//     }
//   }

//   Future<Directory> _getDownloadDirectory() async {
//     if (Platform.isAndroid) {
//       return await DownloadsPathProvider.downloadsDirectory;
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   Future<bool> _requestPermissions() async {
//     var permission = await PermissionHandler()
//         .checkPermissionStatus(PermissionGroup.storage);

//     if (permission != PermissionStatus.granted) {
//       await PermissionHandler().requestPermissions([PermissionGroup.storage]);
//       permission = await PermissionHandler()
//           .checkPermissionStatus(PermissionGroup.storage);
//     }

//     return permission == PermissionStatus.granted;
//   }

//   void _onReceiveProgress(int received, int total) {
//     if (current.size == 0) {
//       current.size = total;
//     }
//     if (total != -1) {
//       setProgress(
//         name,
//         double.parse(
//           (received / total * 100).toStringAsFixed(0),
//         ),
//       );
//     }
//   }

//   // Download Provider Functions

//   addDownloading(Download item) {
//     if (!pending.contains(item)) {
//       pending.add(item);
//     }
//     notifyListeners();
//   }

//   startDownload(Download item) {
//     if (!downloading.contains(item) && downloading.length == 0) {
//       downloading.add(item);
//       pending.remove(item);
//       download(item);
//     }
//   }

//   setProgress(name, progress) {
//     downloading.forEach((element) {
//       if (element.name == name) {
//         element.progress = progress;
//       }
//     });
//     notifyListeners();
//   }

//   downloadCompleted(name) {
//     downloading.forEach((element) {
//       if (element.name == name) {
//         downloading.remove(element);
//         if (pending.length > 0) {
//           addDownloading(pending[0]);
//           startDownload(downloading[0]);
//         }
//       }
//     });
//     notifyListeners();
//   }

//   cancelDownload(name) {
//     Download item1;
//     Download item2;
//     downloading.forEach((element) {
//       if (element.name == name) {
//         item1 = element;
//       }
//     });
//     pending.forEach((element) {
//       if (element.name == name) {
//         item2 = element;
//       }
//     });
//     if (item1 != null) {
//       downloading.remove(item1);
//       cancelToken.cancel();
//     }
//     if (item2 != null) {
//       pending.remove(item2);
//     }

//     notifyListeners();
//   }

//   checkAnime(name) {
//     bool avail = false;
//     downloading.forEach((element) {
//       if (element.name == name) {
//         avail = true;
//       }
//     });
//     pending.forEach((element) {
//       if (element.name == name) {
//         avail = true;
//       }
//     });
//     notifyListeners();
//     return avail;
//   }
// }
