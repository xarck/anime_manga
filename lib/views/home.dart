import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/views/animeScreen.dart';
import 'package:desk/views/settings.dart';
import 'package:desk/views/videoScreen.dart';
import 'package:desk/widgets/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List populars = [];
  List recents = [];
  List details = [];
  Dio _dio = Dio();
  bool notResponding = false;

  @override
  void initState() {
    super.initState();
    getData();
    getDetails();
  }

  getData() async {
    Box home = await Hive.openBox('home');
    try {
      if (home.get('recents') != null && home.get('populars') != null) {
        setState(() {
          recents = home.get('recents');
          populars = home.get('populars');
        });
      }
      Response recentResponse = await _dio.get(
        'https://$ip/recent',
      );
      setState(() {
        home.put('recents', recentResponse.data);
        recents = home.get('recents');
      });
      Response popularResponse = await _dio.get(
        'https://$ip/popular',
      );
      setState(() {
        home.put('populars', popularResponse.data);
        populars = home.get('populars');
      });
    } catch (SocketExcetion) {
      Timer.periodic(Duration(seconds: 10), (e) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Internet Not Available',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        );
      });
    }
  }

  getDetails() async {
    try {
      Response response = await Dio().get(
        'https://$ip/officials',
      );
      setState(() {
        details = response.data;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Color getColor(Set<MaterialState> states) {
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Overview',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
            ),
            tooltip: 'Settings',
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: notResponding
              ? Container(
                  height: getSize(context).height / 1.5,
                  child: Center(
                    child: Text(
                      'Server Not Responding \nIt May Take Some Time \nCheckout Manga Section',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                      ),
                    ),
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Text(
                          'Recent',
                        ),
                      ),
                      recents.length == 0
                          ? CircularProgressIndicator()
                          : Container(
                              height: 260,
                              child: ListView.builder(
                                itemCount: recents.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return VideoScreen(
                                                    name: recents[index]
                                                        ['animeName'],
                                                    videoUrl: recents[index]
                                                        ['videoUrl'],
                                                    recentScreen: true,
                                                    epNumber: int.parse(
                                                          recents[index]
                                                                  ['extra']
                                                              .substring(
                                                                  8,
                                                                  recents[index]
                                                                          [
                                                                          'extra']
                                                                      .length),
                                                        ) -
                                                        1,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${recents[index]['imgUrl']}",
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 200,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        title(
                                            text:
                                                "${recents[index]['animeName']}"),
                                        title(
                                            text: "${recents[index]['extra']}")
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Text(
                          'Popular',
                        ),
                      ),
                      populars.length == 0
                          ? CircularProgressIndicator()
                          : Container(
                              height: 250,
                              child: ListView.builder(
                                itemCount: recents.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return AnimeScreen(
                                                    name: populars[index]
                                                        ['animeName'],
                                                    animeUrl: populars[index]
                                                        ['videoUrl'],
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${populars[index]['imgUrl']}",
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 200,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        title(
                                            text:
                                                "${populars[index]['animeName']}")
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/drawer.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.map<Widget>(
              (detail) {
                return TextButton(
                  onPressed: () async {
                    await canLaunch(detail['url'])
                        ? await launch(detail['url'])
                        : throw 'Could not launch';
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(getColor),
                  ),
                  child: Text(
                    detail['title'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
