import 'package:desk/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List details = [
    {"url": "https://4anime.to", "title": "Powered By 4Anime"},
    {"url": "https://mangadex.tv/", "title": "Powered By Mangadex"},
  ];
  List _info;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    try {
      Response response = await Dio().get('https://$ip/info');
      setState(() {
        _info = response.data;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          _info == null
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.share_outlined),
                  onPressed: () {
                    Share.share('${_info[2][0]['url']}');
                  },
                )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: getSize(context).width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info == null
                  ? SizedBox()
                  : _info[1]['updates'] == '3.0.1'
                      ? SizedBox()
                      : Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          width: getSize(context).width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white10,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'New Update Available',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                  itemCount: _info[2].length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: TextButton(
                                        onPressed: () async {
                                          await canLaunch(
                                                  _info[2][index]['url'])
                                              ? await launch(
                                                  _info[2][index]['url'])
                                              : throw 'Could not launch';
                                        },
                                        style: ButtonStyle(backgroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) {
                                          return Colors.purple;
                                        })),
                                        child: Text(
                                          _info[2][index]['title'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.all(10),
                width: getSize(context).width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s New',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('1. Now Every Request And Image Is Cached'),
                    Text('2. Bookmark Support'),
                    Text('3. UI Update'),
                    Text('4. Download Support For Both Anime And Manga'),
                    Text('5. Bugs Fixed'),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.all(10),
                width: getSize(context).width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note : ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                        '1. You Can Read Mangas Offline If Manga Chapters Are Cached.'),
                    Text('2. Always Check Settings For Updates.'),
                    Text(
                        "3. Manga Download May Not Work Sometimes, In That Cases Just Try Again To Download."),
                    Text(
                        "4. 1 Download At A Time Is Supported Due To Server Limitations.")
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    padding: EdgeInsets.all(10),
                    width: getSize(context).width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white10,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'Clear Bookmarks ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              Box box = Hive.box('libraryWatch');
                              box.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Anime Bookmarks Cleared',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateColor.resolveWith((states) {
                                return Colors.red;
                              }),
                            ),
                            child: Text(
                              'Clear Anime Bookmarks',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              Box box = Hive.box('libraryRead');
                              box.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Manga Bookmarks Cleared',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateColor.resolveWith((states) {
                                return Colors.red;
                              }),
                            ),
                            child: Text(
                              'Clear Manga Bookmarks',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                padding: EdgeInsets.all(10),
                width: getSize(context).width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Credits',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount: details.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Center(
                          child: TextButton(
                            onPressed: () async {
                              await canLaunch(details[index]['url'])
                                  ? await launch(details[index]['url'])
                                  : throw 'Could not launch';
                            },
                            style: ButtonStyle(backgroundColor:
                                MaterialStateColor.resolveWith((states) {
                              return Colors.blue;
                            })),
                            child: Text(
                              details[index]['title'],
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _info == null
                  ? SizedBox()
                  : Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      padding: EdgeInsets.all(10),
                      width: getSize(context).width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white10,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Info',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          ListView.builder(
                            itemCount: _info[0].length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Center(
                                child: TextButton(
                                  onPressed: () async {
                                    await canLaunch(_info[0][index]['url'])
                                        ? await launch(_info[0][index]['url'])
                                        : throw 'Could not launch';
                                  },
                                  style: ButtonStyle(backgroundColor:
                                      MaterialStateColor.resolveWith((states) {
                                    return Colors.green;
                                  })),
                                  child: Text(
                                    _info[0][index]['title'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
