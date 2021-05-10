import 'package:desk/provider/watching_provider.dart';
import 'package:desk/views/videoScreen.dart';
import 'package:dio/dio.dart';
import 'package:desk/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class AnimeScreen extends StatefulWidget {
  AnimeScreen({
    Key key,
    this.name,
    this.animeUrl,
  }) : super(key: key);
  final String name;
  final String animeUrl;
  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  var details;
  @override
  void initState() {
    super.initState();
    getAnime();
  }

  getAnime() async {
    try {
      var animeList = await Hive.openBox('animeList');
      var watching = Provider.of<Watching>(context, listen: false);
      if (animeList.get(widget.animeUrl) != null) {
        setState(() {
          details = animeList.get(widget.animeUrl);
        });
        watching.intialization(details);
      }
      Response response =
          await Dio().get('https://$ip/details/?url=${widget.animeUrl}');
      watching.intialization(response.data);
      if (mounted) {
        setState(() {
          animeList.put(widget.animeUrl, response.data);
          details = animeList.get(widget.animeUrl);
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
        actions: [
          IconButton(
              icon: Icon(
                Icons.bookmark_border_outlined,
              ),
              color: Hive.box('libraryWatch').get(widget.animeUrl) != null
                  ? Colors.green
                  : Colors.red,
              onPressed: () {
                Box watchList = Hive.box('libraryWatch');
                Hive.box('libraryWatch').get(widget.animeUrl) != null
                    ? watchList.delete(widget.animeUrl)
                    : watchList.put(widget.animeUrl, details);
                setState(() {});
              })
        ],
      ),
      body: details == null
          ? LinearProgressIndicator()
          : Scrollbar(
              isAlwaysShown: true,
              thickness: 6,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                children: details['episodes'].map<Widget>((episode) {
                  return TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return VideoScreen(
                              name: details['name'],
                              videoUrl: episode['url'],
                              epNumber: details['episodes'].indexOf(
                                episode,
                              ),
                              recentScreen: false,
                            );
                          },
                        ),
                      );
                    },
                    child: Text(
                      episode['episode'].toString(),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

removeNonASCII(String str) {
  return str.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
}
