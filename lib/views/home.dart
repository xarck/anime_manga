import 'package:desk/constants/constants.dart';
import 'package:desk/views/animeScreen.dart';
import 'package:desk/views/videoScreen.dart';
import 'package:desk/widgets/widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    getRecent();
    getPopular();
    getDetails();
  }

  getRecent() async {
    try {
      Response response = await _dio.get(
        'https://$ip/recent',
      );
      if (response.data.length != 0) {
        setState(() {
          recents = response.data;
        });
      } else {
        setState(() {
          notResponding = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getPopular() async {
    try {
      Response response = await _dio.get(
        'https://$ip/popular',
      );
      setState(() {
        populars = response.data;
      });
    } catch (e) {
      print(e.toString());
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
                                        Material(
                                          clipBehavior: Clip.hardEdge,
                                          color: Colors.transparent,
                                          child: Ink.image(
                                            image: NetworkImage(
                                              "${recents[index]['imgUrl']}",
                                            ),
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 200,
                                            child: InkWell(
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
                                            ),
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
                                        Material(
                                          clipBehavior: Clip.hardEdge,
                                          color: Colors.transparent,
                                          child: Ink.image(
                                            image: NetworkImage(
                                              "${populars[index]['imgUrl']}",
                                            ),
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 200,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return AnimeScreen(
                                                        name: populars[index]
                                                            ['animeName'],
                                                        animeUrl:
                                                            populars[index]
                                                                ['videoUrl'],
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
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
