import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watchingProvider.dart';
import 'package:desk/views/mangaView.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class MangaScreen extends StatefulWidget {
  MangaScreen({Key key, this.name, this.detailUrl, this.imageUrl})
      : super(key: key);
  final String name;
  final String detailUrl;
  final String imageUrl;
  @override
  _MangaScreenState createState() => _MangaScreenState();
}

class _MangaScreenState extends State<MangaScreen> {
  List chapters;
  Watching reading;
  Box mangaList;
  int lastChapterIndex = 0;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    getChapters();
  }

  getChapters() async {
    try {
      mangaList = await Hive.openBox('mangaList');
      reading = Provider.of<Watching>(context, listen: false);
      if (mangaList.get(widget.detailUrl) != null) {
        setState(() {
          chapters = mangaList.get(widget.detailUrl)['mangaData'];
        });
        reading.intializeReading(chapters, widget.detailUrl);
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   _scrollToLastIndex();
        // });
      }

      if (mounted) {
        Response response = await Dio()
            .get('https://$ip:/manga/details/?mangaUrl=${widget.detailUrl}');
        reading.intializeReading(response.data, widget.detailUrl);
        if (_scrollController != null &&
            mangaList.get(widget.detailUrl) != null) {
          mangaList.put(widget.detailUrl,
              {...mangaList.get(widget.detailUrl), 'mangaData': response.data});
        } else {
          mangaList.put(widget.detailUrl, {'mangaData': response.data});
        }
        if (mounted) {
          setState(() {
            chapters = mangaList.get(widget.detailUrl)['mangaData'];
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // _scrollToLastIndex() {
  //   int lastIndex = mangaList.get(widget.detailUrl)['lastIndex'];
  //   if (lastIndex != null) {
  //     _scrollController.animateTo(
  //       (lastIndex - 1) * 56.0,
  //       duration: Duration(
  //         seconds: lastIndex < 50
  //             ? 1
  //             : lastIndex < 150
  //                 ? 3
  //                 : lastIndex < 300
  //                     ? 5
  //                     : 10,
  //       ),
  //       curve: Curves.linear,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          chapters == null
              ? SizedBox()
              : IconButton(
                  icon: Icon(
                    Icons.bookmark_border_outlined,
                  ),
                  color: Hive.box('libraryRead').get(widget.detailUrl) != null
                      ? Colors.green
                      : Colors.red,
                  onPressed: () {
                    Box watchList = Hive.box('libraryRead');
                    Hive.box('libraryRead').get(widget.detailUrl) != null
                        ? watchList.delete(widget.detailUrl)
                        : watchList.put(widget.detailUrl, {
                            'data': chapters,
                            'url': widget.detailUrl,
                            'name': widget.name,
                            'imageUrl': widget.imageUrl
                          });
                    setState(() {});
                  })
        ],
      ),
      body: chapters == null
          ? LinearProgressIndicator()
          : Consumer<Watching>(
              builder: (context, data, child) {
                return Scrollbar(
                  isAlwaysShown: true,
                  thickness: 6,
                  controller: _scrollController,
                  child: ListView.builder(
                    itemCount: chapters.length,
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      return chapters[index]['name'].length != 0
                          ? ListTile(
                              onTap: () {
                                data.setLastChapter(
                                    chapters[index]['name'], index);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MangaView(
                                      name: chapters[index]['name'],
                                      detailUrl:
                                          '$domain/${chapters[index]['url']}',
                                      chapterNumber: index,
                                    ),
                                    settings: RouteSettings(
                                      arguments: index,
                                    ),
                                  ),
                                );
                              },
                              title: Text(
                                chapters[index]['name'],
                                style: TextStyle(
                                  color: chapters[index]['name'] ==
                                          mangaList.get(
                                              widget.detailUrl)['lastChapter']
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                            )
                          : SizedBox();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: chapters == null
          ? SizedBox()
          : FloatingActionButton(
              onPressed: () {
                int lastIndex =
                    mangaList.get(widget.detailUrl)['lastIndex'] != null
                        ? mangaList.get(widget.detailUrl)['lastIndex']
                        : chapters.length - 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaView(
                      name: chapters[lastIndex]['name'],
                      detailUrl: '$domain/${chapters[lastIndex]['url']}',
                      chapterNumber: lastIndex,
                    ),
                    settings: RouteSettings(
                      arguments: lastIndex,
                    ),
                  ),
                );
              },
              tooltip: "Continue",
              backgroundColor: Colors.white,
              child: Icon(
                Icons.play_arrow_outlined,
                color: Colors.black,
                size: 40,
              ),
            ),
    );
  }
}
