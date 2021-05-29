import 'dart:isolate';
import 'dart:ui';
import 'package:desk/provider/downloadProvider.dart';
import 'package:desk/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

class Downloads extends StatefulWidget {
  Downloads({Key key}) : super(key: key);

  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  ReceivePort _port = ReceivePort();
  DownloadProvider downloadProvider;
  @override
  void initState() {
    super.initState();
    getDownloads();
    _downloadListener();
  }

  _downloadListener() {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloading');
    _port.listen((dynamic data) {
      if (mounted) {
        getDownloads();
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  getDownloads() {
    downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    downloadProvider.intialize();
  }

  Future<bool> _openDownloadedFile(taskId) {
    return FlutterDownloader.open(taskId: taskId);
  }

  void _delete(taskId) async {
    await FlutterDownloader.remove(
      taskId: taskId,
      shouldDeleteContent: false,
    );
    downloadProvider.currentlyDownloading = true;
    getDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloads',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Consumer<DownloadProvider>(
          builder: (context, data, child) {
            List _downloads = data.downloads;
            return data.downloads == null
                ? LinearProgressIndicator()
                : SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: _downloads.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _openDownloadedFile(
                                          _downloads[index].taskId);
                                    },
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: _downloads[index].status.value == 3
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                downloadTitle(
                                                  text: _downloads[index]
                                                      .filename,
                                                ),
                                                IconButton(
                                                    icon: Icon(Icons.close),
                                                    onPressed: () {
                                                      _delete(
                                                        _downloads[index]
                                                            .taskId,
                                                      );
                                                    })
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                LinearProgressIndicator(
                                                  value: _downloads[index]
                                                          .progress /
                                                      100.0,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    downloadTitle(
                                                      text: _downloads[index]
                                                          .filename,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(Icons.close),
                                                        onPressed: () {
                                                          _delete(
                                                            _downloads[index]
                                                                .taskId,
                                                          );
                                                        })
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
