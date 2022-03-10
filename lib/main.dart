import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsocial/pages/chatRoom.dart';
import 'package:newsocial/pages/contentViewerPage.dart';
import 'package:newsocial/pages/extensionApps/qrScanner.dart';
import 'package:newsocial/pages/homepage.dart';
import 'package:newsocial/pages/loadingPage.dart';
import 'package:newsocial/pages/onboardingpage.dart';
import 'package:newsocial/pages/videoViewerPage.dart';
import 'package:newsocial/dbModel/model.dart';

void main() async {
  /*WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SettingsAdapter());
  await Hive.openBox<Settings>("settings");*/

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
        "onboardingPage": (context) => OnboardingPage(),
        "homePage": (context) => HomePage(),
        "contentViewerPage": (context) => ContentViewerPage(),
        "VideoViewerPage": (content) => VideoViewerPage(),
        "chatRoom": (content) => ChatRoom(),
        "qrScannerPage": (content) => QRScannerPage(),
      },
      theme: ThemeData(
        fontFamily: "BlenderProBook",
      ),
    );
  }
}
