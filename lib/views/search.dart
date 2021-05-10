import 'package:desk/views/mangaSearch.dart';
import 'package:desk/views/animeSearch.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 100,
          centerTitle: true,
          title: Text(
            "Search",
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Anime'),
              Tab(text: 'Manga'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AnimeSearch(),
            MangaSearch(),
          ],
        ),
      ),
    );
  }
}
