import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/views/animeScreen.dart';
import 'package:desk/views/downloads.dart';
import 'package:desk/views/settings.dart';
import 'package:desk/views/animeView.dart';
import 'package:desk/widgets/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List populars = [];
  List recents = [];
  Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    getData();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Internet Not Available / Server Not Responding',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }
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
            icon: Icon(Icons.save_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Downloads(),
                ),
              );
            },
            tooltip: 'Downloads',
          ),
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
          child: Container(
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
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AnimeView(
                                          name: recents[index]['animeName'],
                                          videoUrl: recents[index]['videoUrl'],
                                          recentScreen: true,
                                          epNumber: 0,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: "${recents[index]['imgUrl']}",
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 200,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    title(
                                        text: "${recents[index]['animeName']}"),
                                    title(text: "${recents[index]['extra']}")
                                  ],
                                ),
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
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AnimeScreen(
                                          name: populars[index]['animeName'],
                                          animeUrl: populars[index]['videoUrl'],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: "${populars[index]['imgUrl']}",
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 200,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    title(
                                        text: "${populars[index]['animeName']}")
                                  ],
                                ),
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
    );
  }
}
