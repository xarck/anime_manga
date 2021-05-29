import 'dart:isolate';
import 'dart:ui';

import 'package:better_player/better_player.dart';
import 'package:desk/provider/downloadProvider.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watchingProvider.dart';

class AnimeView extends StatefulWidget {
  final String name;
  final String videoUrl;
  final int epNumber;
  final bool recentScreen;
  AnimeView({
    Key key,
    this.name,
    this.videoUrl,
    this.epNumber,
    this.recentScreen,
  }) : super(key: key);

  @override
  _AnimeViewState createState() => _AnimeViewState();
}

class _AnimeViewState extends State<AnimeView> {
  String videoUrl = '';
  String nextEp = '';
  String prevEp = '';
  BetterPlayerController _betterPlayerController;
  DownloadProvider _downloadProvider;
  Watching watching;
  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);
    _downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    getVideo();
  }

  getVideo() async {
    try {
      Response response =
          await Dio().get('https://$ip/download?epUrl=${widget.videoUrl}');
      if (mounted) {
        setState(() {
          videoUrl = response.data;
        });
      }
      if (!widget.recentScreen) {
        watching = Provider.of<Watching>(context, listen: false);
        var episodes = watching.watching['episodes'];
        if (mounted) {
          setState(() {
            nextEp = episodes.length - 1 == widget.epNumber
                ? ''
                : episodes[widget.epNumber + 1]['url'];
            prevEp = widget.epNumber == 0
                ? ''
                : episodes[widget.epNumber - 1]['url'];
          });
        }
      }
      _downloadProvider.checkDownloading(videoUrl);
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoUrl,
      );

      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableAudioTracks: false,
            enableQualities: false,
            enableSubtitles: false,
          ),
          allowedScreenSleep: false,
          autoDispose: true,
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  setLastEpisode(epNumber) {
    watching.setLastEpisode(epNumber);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloading');
    _downloadProvider.currentlyDownloading = false;
    _downloadProvider.alreadyExists = false;
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    SendPort send = IsolateNameServer.lookupPortByName('downloading');
    send.send([id, status, progress]);
  }

  _checkPermission() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      PermissionStatus permission = await Permission.storage.request();
      return permission.isGranted;
    }
    return true;
  }

  _requestDownload(link) async {
    bool _permission = await _checkPermission();
    if (_permission == false) {
      await _checkPermission();
    } else {
      // String _localPath = '/sdcard/Download';
      String _localPath = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS,
      );
      await _downloadProvider.checkDownloading(videoUrl);
      _downloadProvider.alreadyExists = true;
      await FlutterDownloader.enqueue(
        url: link,
        fileName: '${widget.name}--Episode-${widget.epNumber + 1}.mp4',
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: videoUrl == ''
            ? []
            : [
                Consumer<DownloadProvider>(
                  builder: (context, data, child) {
                    return data.currentlyDownloading || data.alreadyExists
                        ? SizedBox()
                        : IconButton(
                            icon: Icon(Icons.save_alt),
                            onPressed: () {
                              _requestDownload(videoUrl);
                            },
                            tooltip: "Download",
                          );
                  },
                )
              ],
      ),
      body: videoUrl == ''
          ? LinearProgressIndicator()
          : SingleChildScrollView(
              child: Consumer<Watching>(
                builder: (context, data, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: BetterPlayer(
                          controller: _betterPlayerController,
                        ),
                      ),
                      widget.recentScreen
                          ? SizedBox()
                          : Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              child: Text(
                                'Episode Number : ${widget.epNumber + 1}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                      widget.recentScreen
                          ? SizedBox()
                          : Container(
                              width: getSize(context).width,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  widget.epNumber == 0
                                      ? SizedBox()
                                      : TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            setLastEpisode(widget.epNumber);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return AnimeView(
                                                    name: widget.name,
                                                    epNumber:
                                                        widget.epNumber - 1,
                                                    videoUrl: prevEp,
                                                    recentScreen: false,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Previous Episode',
                                            style: TextStyle(fontSize: 22),
                                          ),
                                        ),
                                  widget.epNumber ==
                                          data.watching['episodes'].length - 1
                                      ? SizedBox()
                                      : TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            setLastEpisode(widget.epNumber + 2);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return AnimeView(
                                                    name: widget.name,
                                                    epNumber:
                                                        widget.epNumber + 1,
                                                    videoUrl: nextEp,
                                                    recentScreen: false,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Next Expisode',
                                            style: TextStyle(fontSize: 22),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
