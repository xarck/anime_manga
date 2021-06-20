import 'package:desk/provider/downloadProvider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watchingProvider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MangaView extends StatefulWidget {
  MangaView({Key key, this.name, this.detailUrl, this.chapterNumber})
      : super(key: key);
  final String name;
  final String detailUrl;
  final int chapterNumber;
  @override
  _MangaViewState createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView>
    with SingleTickerProviderStateMixin {
  List images;
  Watching reading;
  ScrollController _scrollController = ScrollController();
  TransformationController _transformationController =
      TransformationController();
  TapDownDetails _doubleTapDetails;
  AnimationController _animationController;
  Animation<Matrix4> _animation;
  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addListener(() {
        _transformationController.value = _animation.value;
      });
    reading = Provider.of<Watching>(context, listen: false);
    getChapterPages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  _checkPermission() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      PermissionStatus permission = await Permission.storage.request();
      return permission.isGranted;
    }
    return true;
  }

  setLastChapter(lastChapter, index) {
    reading.setLastChapter(lastChapter, index);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    Matrix4 _endMatrix;
    Offset _position = _doubleTapDetails.localPosition;
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
      _animationController.reverse();
    } else {
      _endMatrix = Matrix4.identity()
        ..translate(-_position.dx, -_position.dy)
        ..scale(2.0);
      _animation = Matrix4Tween(
        begin: _transformationController.value,
        end: _endMatrix,
      ).animate(
        CurveTween(curve: Curves.easeOut).animate(_animationController),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    int index = ModalRoute.of(context).settings.arguments;
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          actions: [
            images == null
                ? SizedBox()
                : IconButton(
                    tooltip: "Download",
                    icon: Icon(Icons.save_alt),
                    onPressed: () async {
                      DownloadProvider downloadProvider =
                          Provider.of<DownloadProvider>(context, listen: false);
                      downloadProvider.downloadManga(context, widget.name,
                          images, _checkPermission, _scaffoldMessengerKey);
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
                      GestureDetector(
                        onDoubleTapDown: _handleDoubleTapDown,
                        onDoubleTap: _handleDoubleTap,
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            thickness: 6,
                            controller: _scrollController,
                            child: ListView.builder(
                              itemCount: images.length,
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
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
                                );
                              },
                            ),
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
                                      '${data.reading[widget.chapterNumber + 1]['name']}',
                                      index + 1);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MangaView(
                                          name: data.reading[
                                              widget.chapterNumber + 1]['name'],
                                          detailUrl:
                                              '$domain/${data.reading[widget.chapterNumber + 1]['url']}',
                                          chapterNumber:
                                              widget.chapterNumber + 1,
                                        );
                                      },
                                      settings: RouteSettings(
                                        arguments: index + 1,
                                      ),
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
                                      '${data.reading[widget.chapterNumber - 1]['name']}',
                                      index - 1);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MangaView(
                                          name: data.reading[
                                              widget.chapterNumber - 1]['name'],
                                          detailUrl:
                                              '$domain/${data.reading[widget.chapterNumber - 1]['url']}',
                                          chapterNumber:
                                              widget.chapterNumber - 1,
                                        );
                                      },
                                      settings: RouteSettings(
                                        arguments: index - 1,
                                      ),
                                    ),
                                  );
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
      ),
    );
  }
}
