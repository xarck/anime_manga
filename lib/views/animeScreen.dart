import 'package:desk/provider/watchingProvider.dart';
import 'package:desk/views/animeView.dart';
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
  Box animeList;
  @override
  void initState() {
    super.initState();
    getAnime();
  }

  getAnime() async {
    try {
      animeList = await Hive.openBox('animeList');
      var watching = Provider.of<Watching>(context, listen: false);
      if (animeList.get(widget.animeUrl) != null) {
        setState(() {
          details = animeList.get(widget.animeUrl)['animeData'];
        });
        watching.intialization(details);
      }

      Response response =
          await Dio().get('https://$ip/details/?url=${widget.animeUrl}');
      watching.intialization(response.data);
      if (mounted) {
        if (animeList.get(widget.animeUrl) != null) {
          animeList.put(widget.animeUrl,
              {...animeList.get(widget.animeUrl), 'animeData': response.data});
        } else {
          animeList.put(widget.animeUrl, {'animeData': response.data});
        }
        setState(() {
          details = animeList.get(widget.animeUrl)['animeData'];
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
        title: Text('${widget.name}'),
        actions: [
          details == null
              ? SizedBox()
              : IconButton(
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
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith(
                        (states) => episode['episode'].toString() ==
                                animeList.get(widget.animeUrl)['lastEpisode']
                            ? Colors.blue
                            : Colors.red,
                      ),
                    ),
                    onPressed: () {
                      animeList.put(
                        widget.animeUrl,
                        {
                          'animeData': details,
                          'lastEpisode': episode['episode'].toString(),
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AnimeView(
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
