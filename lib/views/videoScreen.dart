import 'package:better_player/better_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:desk/constants/constants.dart';
import 'package:desk/provider/watching_provider.dart';

class VideoScreen extends StatefulWidget {
  final String name;
  final String videoUrl;
  final int epNumber;
  final bool recentScreen;
  VideoScreen({
    Key key,
    this.name,
    this.videoUrl,
    this.epNumber,
    this.recentScreen,
  }) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _loading = true;
  String videoUrl = '';
  String nextEp = '';
  String prevEp = '';
  BetterPlayerController _betterPlayerController;
  @override
  void initState() {
    super.initState();
    getVideo();
  }

  getVideo() async {
    try {
      Response response =
          await Dio().get('https://$ip/download?epUrl=${widget.videoUrl}');
      setState(() {
        videoUrl = response.data;
      });
      if (!widget.recentScreen) {
        var watching = Provider.of<Watching>(context, listen: false);
        var episodes = watching.watching['episodes'];

        setState(() {
          nextEp = episodes.length - 1 == widget.epNumber
              ? ''
              : episodes[widget.epNumber + 1]['url'];
          prevEp =
              widget.epNumber == 0 ? '' : episodes[widget.epNumber - 1]['url'];
        });
      }

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        response.data,
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      setState(() {
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
          : SingleChildScrollView(
              child: Consumer<Watching>(
                builder: (context, data, child) {
                  return Column(
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
                              width: getSize(context).width,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  widget.epNumber == 0
                                      ? SizedBox()
                                      : TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return VideoScreen(
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
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return VideoScreen(
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
                      // DownloadVideo(
                      //   name: '${widget.name}--Episode-${widget.epNumber + 1}',
                      //   videoUrl: videoUrl,
                      //   epUrl: widget.videoUrl,
                      // )
                    ],
                  );
                },
              ),
            ),
    );
  }
}
