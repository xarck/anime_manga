import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watching_provider.dart';
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

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    getChapters();
  }

  getChapters() async {
    try {
      Box mangaList = await Hive.openBox('mangaList');
      var reading = Provider.of<Watching>(context, listen: false);

      if (mangaList.get(widget.detailUrl) != null) {
        setState(() {
          chapters = mangaList.get(widget.detailUrl);
        });
        reading.intializeReading(chapters);
      }
      Response response = await Dio()
          .get('https://$ip:/manga/details/?mangaUrl=${widget.detailUrl}');
      if (mounted) {
        setState(() {
          mangaList.put(widget.detailUrl, response.data);
          chapters = mangaList.get(widget.detailUrl);
        });
      }
      reading.intializeReading(response.data);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
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
          : Container(
              child: Scrollbar(
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MangaView(
                                      name: chapters[index]['name'],
                                      detailUrl:
                                          '$domain/${chapters[index]['url']}',
                                      chapterNumber: index),
                                ),
                              );
                            },
                            title: Text(chapters[index]['name']),
                          )
                        : SizedBox();
                  },
                ),
              ),
            ),
    );
  }
}
