import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
      /*appBar: AppBar(
        backgroundColor: Colors.grey[200]!.withOpacity(0.0),
        foregroundColor: Colors.black,
        elevation: 0.0,
      ),*/
      body: Stack(
        children: [
          // Blurred BG Image
          Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new NetworkImage(receivedData["image"]),
                  fit: BoxFit.cover,
                ),
                color: Colors.red),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                decoration:
                    new BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          // Back Button
          Container(
            width: 50.0,
            height: 50.0,
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 2.4,
                vertical: 100.0),
            //padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
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
          // Clear Image
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 250.0),
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
