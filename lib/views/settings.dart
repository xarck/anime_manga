import 'package:desk/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        width: getSize(context).width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                    'You can read mangas offline if manga chapters are cached.',
                  ),
                  Text('Always check drawer for updates.')
                ],
              ),
            ),
            Builder(
              builder: (context) {
                return Center(
                  child: TextButton(
                    onPressed: () async {
                      Box box = Hive.box('libraryWatch');
                      box.clear();
                      Scaffold.of(context).showSnackBar(
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
                      backgroundColor: MaterialStateColor.resolveWith((states) {
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
                );
              },
            ),
            Builder(
              builder: (context) {
                return Center(
                  child: TextButton(
                    onPressed: () async {
                      Box box = Hive.box('libraryRead');
                      box.clear();
                      Scaffold.of(context).showSnackBar(
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
                      backgroundColor: MaterialStateColor.resolveWith((states) {
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
