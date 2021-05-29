import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/views/mangaScreen.dart';
import 'package:desk/widgets/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MangaSearch extends StatefulWidget {
  MangaSearch({Key key}) : super(key: key);

  @override
  _MangaSearchState createState() => _MangaSearchState();
}

class _MangaSearchState extends State<MangaSearch> {
  TextEditingController _searchText = TextEditingController();
  FocusNode textNode = FocusNode();
  List searchResults = [];
  bool searching = false;
  ScrollController _scrollController = ScrollController();

  getSearch() async {
    try {
      Box mangaSearchList = await Hive.openBox('mangaSearch');
      if (mangaSearchList.get(_searchText.text) != null) {
        setState(() {
          searchResults = mangaSearchList.get(_searchText.text);
          searching = false;
        });
      }
      if (_searchText.text.length > 0) {
        setState(() {
          searching = true;
        });
        Response response = await Dio()
            .get('https://$ip/manga/search?search=${_searchText.text}');
        if (mounted) {
          setState(() {
            mangaSearchList.put(_searchText.text, response.data);
            searchResults = mangaSearchList.get(_searchText.text);
            searching = false;
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _searchText.text.length == 0
              ? GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus.unfocus();
                  },
                  child: SizedBox(),
                )
              : searching && searchResults.length == 0
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : searchResults.length == 0
                      ? Center(
                          child: Text(
                            'Nothing Available \nTry Searching In Their Japanese Name',
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.only(
                            bottom: 80,
                          ),
                          child: Scrollbar(
                            isAlwaysShown: true,
                            thickness: 6,
                            controller: _scrollController,
                            child: GridView.count(
                              controller: _scrollController,
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              children: searchResults.map<Widget>((result) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MangaScreen(
                                          name: result['name'],
                                          detailUrl:
                                              '$domain${result['detailUrl']}',
                                          imageUrl:
                                              "$domain${result['imgUrl']}",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: "$domain${result['imgUrl']}",
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 240,
                                        fadeInDuration: Duration(seconds: 0),
                                      ),
                                      SizedBox(height: 10),
                                      title(
                                        text: '${result['name']}',
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: EdgeInsets.all(5),
              child: TextField(
                focusNode: textNode,
                controller: _searchText,
                onSubmitted: (val) {
                  getSearch();
                },
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Write Manga Name Here',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _searchText.text = '';
                      searchResults = [];
                      FocusManager.instance.primaryFocus.unfocus();
                      setState(() {});
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
