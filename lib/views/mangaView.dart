import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watching_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: images == null
          ? LinearProgressIndicator()
          : Stack(
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
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          progressIndicatorBuilder: (context, child, progress) {
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
                reading.reading.length - widget.chapterNumber == 1
                    ? SizedBox()
                    : Align(
                        alignment: Alignment.bottomLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return MangaView(
                                name: reading.reading[widget.chapterNumber + 1]
                                    ['name'],
                                detailUrl:
                                    '$domain/${reading.reading[widget.chapterNumber + 1]['url']}',
                                chapterNumber: widget.chapterNumber + 1,
                              );
                            }));
                          },
                          icon: Icon(
                            Icons.arrow_back,
                          ),
                          color: Colors.purple,
                          iconSize: 40,
                          tooltip: 'Previous Chapter',
                        ),
                      ),
                reading.reading.length ==
                        reading.reading.length - widget.chapterNumber + 1
                    ? SizedBox()
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return MangaView(
                                name: reading.reading[widget.chapterNumber - 1]
                                    ['name'],
                                detailUrl:
                                    '$domain/${reading.reading[widget.chapterNumber - 1]['url']}',
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
            ),
    );
  }
}
