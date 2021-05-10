

import 'package:desk/provider/watching_provider.dart';
import 'package:desk/views/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('libraryWatch');
  await Hive.openBox('libraryRead');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Watching(),
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

class MyApp extends StatelessWidget {
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
