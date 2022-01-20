import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsocial/pages/contentViewerPage.dart';
import 'package:newsocial/pages/homepage.dart';
import 'package:newsocial/pages/loadingPage.dart';
import 'package:newsocial/pages/videoViewerPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Light Mode Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Colors.grey[200],
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => LoadingPage(),
        "homePage": (context) => HomePage(),
        "contentViewerPage": (context) => ContentViewerPage(),
        "VideoViewerPage": (content) => VideoViewerPage(),
      },
      theme: ThemeData(
        fontFamily: "BlenderProBook",
      ),
    );
  }
}
