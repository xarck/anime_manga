import 'package:desk/constants/constants.dart';
import 'package:desk/views/mangaScreen.dart';
import 'package:desk/widgets/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MangaSearch extends StatefulWidget {
  MangaSearch({Key key}) : super(key: key);

  @override
  _MangaSearchState createState() => _MangaSearchState();
}

class _MangaSearchState extends State<MangaSearch> {
  bool searching = false;
  TextEditingController _searchText = TextEditingController();
  FocusNode textNode = FocusNode();
  List searchResults = [];
  ScrollController _scrollController = ScrollController();

  getSearch() async {
    try {
      if (_searchText.text.length > 0) {
        setState(() {
          searching = true;
        });
        Response response = await Dio()
            .get('https://$ip/manga/search?search=${_searchText.text}');
        setState(() {
          searchResults = response.data;
          searching = false;
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
        title: Text('Manga'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _searchText.text.length == 0
              ? GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus.unfocus();
                  },
                  child: SizedBox(),
                )
              : searching
                  ? LinearProgressIndicator()
                  : searchResults.length == 0
                      ? Center(
                          child: Text(
                            'Nothing Available \nTry Searching In Their Japanese Name',
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.only(
                            bottom: 100,
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
                                return Column(
                                  children: [
                                    Material(
                                      clipBehavior: Clip.hardEdge,
                                      color: Colors.transparent,
                                      child: Ink.image(
                                        image: NetworkImage(
                                          "$domain${result['imgUrl']}",
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MangaScreen(
                                                  name: result['name'],
                                                  detailUrl:
                                                      '$domain${result['detailUrl']}',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.3,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3.2,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    title(
                                      text: '${result['name']}',
                                    )
                                  ],
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
                  setState(() {
                    searching = true;
                  });
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
