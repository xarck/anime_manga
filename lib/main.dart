import 'dart:ui';

import 'package:desk/provider/downloadProvider.dart';
import 'package:desk/provider/watchingProvider.dart';
import 'package:desk/views/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);
  await Hive.initFlutter();
  await Hive.openBox('libraryWatch');
  await Hive.openBox('libraryRead');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Watching(),
        ),
        ChangeNotifierProvider(
          create: (context) => DownloadProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DownloadProvider downloadProvider = Provider.of(context, listen: false);
    downloadProvider.intialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Down',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Proxima',
        accentColor: Colors.red,
        primarySwatch: Colors.red,
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontSize: 20,
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return Colors.purple;
            },
          ),
        ),
      ),
      home: Nav(),
    );
  }
}
