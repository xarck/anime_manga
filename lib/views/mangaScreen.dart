import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watching_provider.dart';
import 'package:desk/views/mangaView.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MangaScreen extends StatefulWidget {
  MangaScreen({Key key, this.name, this.detailUrl}) : super(key: key);
  final String name;
  final String detailUrl;
  @override
  _MangaScreenState createState() => _MangaScreenState();
}

class _MangaScreenState extends State<MangaScreen> {
  List chapters = [];
  bool _loading = true;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    getChapters();
  }

  getChapters() async {
    try {
      Response response = await Dio()
          .get('https://$ip:/manga/details/?mangaUrl=${widget.detailUrl}');
      setState(() {
        chapters = response.data;
        _loading = false;
      });
      var reading = Provider.of<Watching>(context, listen: false);
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
      ),
      body: _loading
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
