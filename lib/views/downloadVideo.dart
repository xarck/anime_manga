// import 'package:desk/models/download.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:desk/provider/download_provider.dart';
// import 'package:provider/provider.dart';

// class DownloadVideo extends StatefulWidget {
//   DownloadVideo({
//     Key key,
//     this.videoUrl,
//     this.name,
//     this.epUrl,
//   }) : super(key: key);
//   final String videoUrl;
//   final String name;
//   final String epUrl;
//   @override
//   _DownloadVideoState createState() => _DownloadVideoState();
// }

// class _DownloadVideoState extends State<DownloadVideo> {
//   DownloadProvider downloadProvider;
//   bool avail = false;
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   @override
//   void initState() {
//     super.initState();
//     downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
//   }

//   addToList() {
//     Download newDownload = Download(
//       name: widget.name,
//       progress: 0.0,
//       epUrl: widget.videoUrl,
//       size: 0,
//     );
//     downloadProvider.addDownloading(newDownload);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(
//         top: 20,
//       ),
//       child: Builder(
//         builder: (context) {
//           return IconButton(
//             onPressed: () {
//               Scaffold.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Episode Added To List'),
//                 ),
//               );
//               addToList();
//             },
//             tooltip: 'Download',
//             icon: Icon(
//               Icons.arrow_downward,
//               color: Colors.red,
//             ),
//             iconSize: 48,
//           );
//         },
//       ),
//     );
//   }
// }
