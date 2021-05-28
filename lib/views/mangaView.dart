import 'package:ext_storage/ext_storage.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watchingProvider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class MangaView extends StatefulWidget {
  MangaView({Key key, this.name, this.detailUrl, this.chapterNumber})
      : super(key: key);
  final String name;
  final String detailUrl;
  final int chapterNumber;
  @override
  _MangaViewState createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
  List images;
  Watching reading;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    reading = Provider.of<Watching>(context, listen: false);
    getChapterPages();
  }

  getChapterPages() async {
    try {
      Box mangaChapters = await Hive.openBox('mangaChapters');
      if (mangaChapters.get(widget.detailUrl) != null) {
        setState(() {
          images = mangaChapters.get(widget.detailUrl);
        });
      }
      Response response = await Dio()
          .get('https://$ip/manga/chapter/?chapterUrl=${widget.detailUrl}');
      if (mounted) {
        setState(() {
          mangaChapters.put(widget.detailUrl, response.data);
          images = response.data;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  downloadManga() async {
    bool _permission = await _checkPermission();
    if (_permission == false) {
      await _checkPermission();
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('${widget.name} Downloading'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            );
          });
      List htmlImages = images;
      String imgTag = '';
      htmlImages.forEach((element) {
        imgTag += ('<img src="$element" width="100%" height="100%" />');
      });
      String pdf = """
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    $imgTag
</body>
</html>
    """;

      // String targetPath = '/sdcard/Download';
      String targetPath = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS,
      );
      var targetFileName = widget.name;

      await FlutterHtmlToPdf.convertFromHtmlContent(
        pdf,
        targetPath,
        targetFileName,
      );
      Navigator.pop(context);
    }
  }

  _checkPermission() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      PermissionStatus permission = await Permission.storage.request();
      return permission.isGranted;
    }
    return true;
  }

  setLastChapter(lastChapter) {
    reading.setLastChapter(lastChapter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          images == null
              ? SizedBox()
              : IconButton(
                  tooltip: "Download",
                  icon: Icon(Icons.save_alt),
                  onPressed: () async {
                    downloadManga();
                  },
                )
        ],
      ),
      body: images == null
          ? LinearProgressIndicator()
          : Consumer<Watching>(
              builder: (context, data, child) {
                return Stack(
                  children: [
                    InteractiveViewer(
                      child: Scrollbar(
                        isAlwaysShown: true,
                        thickness: 6,
                        controller: _scrollController,
                        child: ListView.builder(
                          itemCount: images.length,
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            return ZoomOverlay(
                              child: CachedNetworkImage(
                                imageUrl: images[index],
                                fadeInDuration: Duration(seconds: 0),
                                fadeOutDuration: Duration(seconds: 0),
                                progressIndicatorBuilder:
                                    (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : Material(
                                          child: Container(
                                            height: 300,
                                            color: Colors.white,
                                          ),
                                        );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    data.reading.length - widget.chapterNumber == 1
                        ? SizedBox()
                        : Align(
                            alignment: Alignment.bottomLeft,
                            child: IconButton(
                              onPressed: () async {
                                setLastChapter(
                                    '${data.reading[widget.chapterNumber + 1]['name']}');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MangaView(
                                        name: data.reading[
                                            widget.chapterNumber + 1]['name'],
                                        detailUrl:
                                            '$domain/${data.reading[widget.chapterNumber + 1]['url']}',
                                        chapterNumber: widget.chapterNumber + 1,
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.arrow_back,
                              ),
                              color: Colors.purple,
                              iconSize: 40,
                              tooltip: 'Previous Chapter',
                            ),
                          ),
                    data.reading.length ==
                            data.reading.length - widget.chapterNumber + 1
                        ? SizedBox()
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () {
                                setLastChapter(
                                    '${data.reading[widget.chapterNumber - 1]['name']}');
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return MangaView(
                                    name: data.reading[widget.chapterNumber - 1]
                                        ['name'],
                                    detailUrl:
                                        '$domain/${data.reading[widget.chapterNumber - 1]['url']}',
                                    chapterNumber: widget.chapterNumber - 1,
                                  );
                                }));
                              },
                              tooltip: 'Next Chapter',
                              color: Colors.purple,
                              iconSize: 40,
                              icon: Icon(
                                Icons.arrow_forward,
                              ),
                            ),
                          ),
                  ],
                );
              },
            ),
    );
  }
}
