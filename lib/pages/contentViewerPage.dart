import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:ionicons/ionicons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class ContentViewerPage extends StatefulWidget {
  const ContentViewerPage({Key? key}) : super(key: key);

  @override
  _ContentViewerPageState createState() => _ContentViewerPageState();
}

class _ContentViewerPageState extends State<ContentViewerPage> {
  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Blurred BG Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(receivedData["image"]),
                fit: BoxFit.cover,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          // Back, Share and Download Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back Button
              Container(
                width: 50.0,
                height: 50.0,
                margin: EdgeInsets.symmetric(horizontal: 2.4, vertical: 100.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(
                    Radius.circular(100.0),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.keyboard_backspace_outlined),
                ),
              ),
              // Share Button
              Container(
                width: 50.0,
                height: 50.0,
                margin: EdgeInsets.symmetric(horizontal: 2.4, vertical: 100.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(
                    Radius.circular(100.0),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    String shareLink = receivedData["shareLink"];
                    Share.share('Check this out @ Aurora \n ${shareLink}');
                  },
                  icon: Icon(
                    Icons.share_outlined,
                  ),
                ),
              ),
              // Download Button
              Container(
                  width: 50.0,
                  height: 50.0,
                  margin:
                      EdgeInsets.symmetric(horizontal: 2.4, vertical: 100.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(
                      Radius.circular(100.0),
                    ),
                  ),
                  child: receivedData["downloadingImageIndex"] ==
                          receivedData["index"]
                      ? (receivedData["downloadingImage"] == false
                          ? IconButton(
                              onPressed: () async {
                                receivedData["downloadingImageIndex"] =
                                    receivedData["index"];
                                receivedData["downloadImage"](
                                    receivedData["image"]);
                              },
                              icon: Icon(
                                receivedData["downloadingImageDone"] == true
                                    ? Icons.done
                                    : Ionicons.download_outline,
                                color:
                                    receivedData["downloadingImageDone"] == true
                                        ? Colors.green
                                        : Colors.black,
                              ),
                            )
                          : Container(
                              width: 25.0,
                              height: 25.0,
                              child: CircularProgressIndicator(
                                color: Colors.grey[900],
                              ),
                            ))
                      : IconButton(
                          onPressed: () async {
                            receivedData["downloadingImageIndex"] =
                                receivedData["index"];
                            receivedData["downloadImage"](
                                receivedData["image"]);
                          },
                          icon: Icon(
                            Ionicons.download_outline,
                          ),
                        )),
            ],
          ),
          // Clear Image
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 200.0, bottom: 20.0),
            child: PhotoView(
              imageProvider: NetworkImage(
                receivedData["image"],
              ),
              basePosition: Alignment.topCenter,
              backgroundDecoration: BoxDecoration(
                color: Colors.grey[200]!.withOpacity(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
