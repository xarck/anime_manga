import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:pdf/widgets.dart' as pw;

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

  downloadManga(context, name, images, checkPermission, key) async {
    bool _permission = await checkPermission();
    if (_permission == false) {
      await checkPermission();
    } else {
      key.currentState.showSnackBar(
        SnackBar(
          content: Container(
            child: Text(
              '$name Downloading',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          ),
        ),
      );
      final pdf = pw.Document();
      final stopwatch = Stopwatch()..start();
      await createPdfPages(pdf, images, context);
      print('doSomething() executed in ${stopwatch.elapsed}');
      String output = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS,
      );
      final file = File("$output/$name.pdf");
      await file.writeAsBytes(await pdf.save());
      // key.currentState.showSnackBar(
      //   SnackBar(
      //     content: Container(
      //       child: Text(
      //         '$name Downloaded',
      //         style: TextStyle(
      //           color: Colors.green,
      //         ),
      //       ),
      //     ),
      //   ),
      // );
    }
  }

  createPdfPages(pdf, images, context) async {
    await Future.forEach(
      images,
      (pageImage) async {
        try {
          Response response = await Dio().get(
            pageImage,
            options: Options(
              responseType: ResponseType.bytes,
            ),
          );
          final image = pw.MemoryImage(response.data);
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Image(image);
              },
            ),
          );
        } catch (e) {
          print(e.toString());
        }
      },
    );
  }
}
