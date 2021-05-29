import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/views/animeScreen.dart';
import 'package:desk/views/mangaScreen.dart';
import 'package:desk/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Library extends StatefulWidget {
  Library({Key key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Animes Bookmarked',
                    style: headStyle,
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: Hive.box('libraryWatch').listenable(),
                builder: (builder, box, widget) {
                  List watchingList = box.values.toList();
                  return watchingList.length == 0
                      ? Column(
                          children: [
                            Container(
                              width: getSize(context).width / 2.6,
                              height: 200,
                              decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text('You Have Not Bookmarked Any Anime')
                          ],
                        )
                      : Container(
                          height: 250,
                          child: ListView.builder(
                            itemCount: watchingList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (itemBuilder, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AnimeScreen(
                                            name: watchingList[index]['name'],
                                            animeUrl: watchingList[index]
                                                ['url'],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "${watchingList[index]['imageUrl']}",
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 200,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      title(
                                          text:
                                              "${watchingList[index]['name']}"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Text('Mangas Bookmarked', style: headStyle),
              ),
              ValueListenableBuilder(
                valueListenable: Hive.box('libraryRead').listenable(),
                builder: (BuildContext context, dynamic box, Widget child) {
                  List readingList = box.values.toList();
                  return readingList.length == 0
                      ? Column(
                          children: [
                            Container(
                              width: getSize(context).width / 2.6,
                              height: 200,
                              decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text('You Have Not Bookmarked Any Manga')
                          ],
                        )
                      : Container(
                          height: 240,
                          child: ListView.builder(
                            itemCount: readingList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (itemBuilder, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return MangaScreen(
                                            name: readingList[index]['name'],
                                            detailUrl:
                                                '${readingList[index]['url']}',
                                            imageUrl:
                                                "${readingList[index]['imageUrl']}",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "${readingList[index]['imageUrl']}",
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 200,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      title(
                                        text: "${readingList[index]['name']}",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const headStyle = TextStyle(
  color: Colors.blue,
  fontSize: 24,
);
