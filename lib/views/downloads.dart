// import 'package:desk/constants/constants.dart';
// import 'package:desk/provider/download_provider.dart';
// import 'package:desk/views/videoScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Downloads extends StatefulWidget {
//   Downloads({Key key}) : super(key: key);

//   @override
//   _DownloadsState createState() => _DownloadsState();
// }

// class _DownloadsState extends State<Downloads> {
//   DownloadProvider downloadProvider;
//   final String url = 'https://4anime.to';
//   final String releaseUrl =
//       'https://github.com/iamashking123/download_down/releases';
//   @override
//   void initState() {
//     super.initState();
//     downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
//   }

//   cancelDownload(name) {
//     downloadProvider.cancelDownload(name);
//   }

//   Color getColor(Set<MaterialState> states) {
//     return Colors.red;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Download'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Consumer<DownloadProvider>(
//           builder: (context, data, child) {
//             var downlist = data.downloading;
//             var penlist = data.pending;
//             return Container(
//               padding: EdgeInsets.symmetric(
//                 vertical: 20,
//                 horizontal: 15,
//               ),
//               constraints: BoxConstraints(
//                 minHeight: getSize(context).height / 1.3,
//                 minWidth: getSize(context).width,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     children: [
//                       Text('Downloading'),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       downlist.length == 0
//                           ? Text('Nothing Is Here')
//                           : ListView.builder(
//                               itemCount: downlist.length,
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => VideoScreen(
//                                           name: downlist[index].name.substring(
//                                                 0,
//                                                 downlist[index]
//                                                     .name
//                                                     .indexOf('--'),
//                                               ),
//                                           videoUrl: downlist[index].epUrl,
//                                           epNumber: int.parse(
//                                                 downlist[index].name.substring(
//                                                       downlist[index]
//                                                               .name
//                                                               .length -
//                                                           1,
//                                                     ),
//                                               ) -
//                                               1,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     color: Colors.white10,
//                                     margin: EdgeInsets.symmetric(vertical: 10),
//                                     padding: EdgeInsets.all(10),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         LinearProgressIndicator(
//                                           value: downlist[index].progress / 100,
//                                         ),
//                                         Container(
//                                           width: getSize(context).width,
//                                           padding: EdgeInsets.symmetric(
//                                               vertical: 10),
//                                           child: Column(
//                                             children: [
//                                               Text(
//                                                 downlist[index].name,
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceAround,
//                                                 children: [
//                                                   Text(
//                                                     'Episode - ${downlist[index].name.substring(
//                                                           downlist[index]
//                                                                   .name
//                                                                   .length -
//                                                               1,
//                                                         )}',
//                                                   ),
//                                                   Text(
//                                                     ' ${downlist[index].progress.toInt()}% ',
//                                                   ),
//                                                   Text(
//                                                     ' ${(downlist[index].size / 1000000).toString().substring(0, 4)} MB',
//                                                   ),
//                                                   IconButton(
//                                                     icon: Icon(
//                                                       Icons.remove_outlined,
//                                                     ),
//                                                     tooltip: 'Cancel',
//                                                     onPressed: () {
//                                                       cancelDownload(
//                                                         downlist[index].name,
//                                                       );
//                                                     },
//                                                   )
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ],
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Pending'),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       penlist.length == 0
//                           ? Text('Nothing Is Here')
//                           : ListView.builder(
//                               itemCount: penlist.length,
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => VideoScreen(
//                                           name: penlist[index].name,
//                                           videoUrl: penlist[index].epUrl,
//                                           epNumber: int.parse(
//                                             penlist[index].name.substring(
//                                                 penlist[index].name.length - 1),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     color: Colors.white10,
//                                     margin: EdgeInsets.symmetric(vertical: 10),
//                                     padding: EdgeInsets.all(10),
//                                     child: Column(
//                                       children: [
//                                         Text(
//                                           penlist[index].name,
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceAround,
//                                           children: [
//                                             IconButton(
//                                               icon: Icon(
//                                                 Icons.arrow_downward,
//                                               ),
//                                               tooltip: 'Download',
//                                               color: Colors.green,
//                                               onPressed: () {
//                                                 downloadProvider.startDownload(
//                                                     penlist[index]);
//                                               },
//                                               iconSize: 38,
//                                             ),
//                                             IconButton(
//                                               icon: Icon(
//                                                 Icons.remove,
//                                               ),
//                                               tooltip: 'Cancel',
//                                               color: Colors.red,
//                                               onPressed: () {
//                                                 cancelDownload(
//                                                     penlist[index].name);
//                                               },
//                                               iconSize: 38,
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ],
//                   ),
//                   Wrap(
//                     spacing: 20,
//                     children: [
//                       TextButton(
//                         onPressed: () async {
//                           await canLaunch(url)
//                               ? await launch(url)
//                               : throw 'Could not launch';
//                         },
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateColor.resolveWith(getColor),
//                         ),
//                         child: Text(
//                           'Powered By 4Anime',
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () async {
//                           await canLaunch(releaseUrl)
//                               ? await launch(releaseUrl)
//                               : throw 'Could not launch';
//                         },
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateColor.resolveWith(getColor),
//                         ),
//                         child: Text(
//                           'App Releases',
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
