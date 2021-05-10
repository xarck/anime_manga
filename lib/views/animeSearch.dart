import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/views/animeScreen.dart';
import 'package:desk/widgets/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AnimeSearch extends StatefulWidget {
  AnimeSearch({Key key}) : super(key: key);

  @override
  _AnimeSearchState createState() => _AnimeSearchState();
}

class _AnimeSearchState extends State<AnimeSearch> {
  TextEditingController _searchText = TextEditingController();
  FocusNode textNode = FocusNode();
  List searchResults = [];
  ScrollController _scrollControler = ScrollController();
  bool searching = false;
  getSearch() async {
    try {
      Box animeSearchList = await Hive.openBox('animeSearch');

      if (animeSearchList.get(_searchText.text) != null) {
        setState(() {
          searchResults = animeSearchList.get(_searchText.text);
          searching = false;
        });
      }
      if (_searchText.text.length > 0) {
        setState(() {
          searching = true;
        });
        Response response =
            await Dio().get('https://$ip/search?search=${_searchText.text}');
        if (mounted) {
          setState(() {
            animeSearchList.put(_searchText.text, response.data);
            searchResults = animeSearchList.get(_searchText.text);
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
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: getSize(context).height,
                    ),
                  ),
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
                            controller: _scrollControler,
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              controller: _scrollControler,
                              children: searchResults.map<Widget>((result) {
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            .unfocus();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AnimeScreen(
                                              name: result['name'],
                                              animeUrl: result['url'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: "${result['imageUrl']}",
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
                },
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Write Anime Name Here',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus.unfocus();
                      setState(() {
                        _searchText.text = '';
                        searchResults = [];
                        searching = false;
                      });
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
