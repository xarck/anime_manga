import 'package:desk/provider/watching_provider.dart';
import 'package:desk/views/videoScreen.dart';
import 'package:dio/dio.dart';
import 'package:desk/constants/constants.dart';
import 'package:flutter/material.dart';
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
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getAnime();
  }

  getAnime() async {
    try {
      Response response =
          await Dio().get('https://$ip/details/?url=${widget.animeUrl}');
      var watching = Provider.of<Watching>(context, listen: false);
      watching.intialization(response.data);
      setState(() {
        details = response.data;
        _loading = false;
      });
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
