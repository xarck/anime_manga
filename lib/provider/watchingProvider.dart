import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

class Watching extends ChangeNotifier {
  Map watching;
  List reading;
  String _detailUrl;
  intialization(data) async {
    await Hive.openBox('animeList');
    watching = data;
    notifyListeners();
  }

  setLastEpisode(epNumber) {
    Box animeList = Hive.box('animeList');
    animeList.put(
      watching['url'],
      {
        'animeData': watching,
        'lastEpisode': '$epNumber',
      },
    );
  }

  intializeReading(data, detailUrl) async {
    await Hive.openBox('mangaList');
    reading = data;
    _detailUrl = detailUrl;
    notifyListeners();
  }

  setLastChapter(chapterName) {
    Box mangaList = Hive.box('mangaList');
    mangaList.put(
      _detailUrl,
      {
        'mangaData': reading,
        'lastChapter': '$chapterName',
      },
    );
    notifyListeners();
  }
}
