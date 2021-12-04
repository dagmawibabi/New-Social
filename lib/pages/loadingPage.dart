import 'dart:async';
import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  List backgroundBehaviours = [
    SpaceBehaviour(),
    RacingLinesBehaviour(),
    SpaceBehaviour(),
    RacingLinesBehaviour(),
    SpaceBehaviour(),
  ];
  Behaviour backgroundBehaviour = SpaceBehaviour();

  // Loading Timer
  void loadingDelay() {
    Timer.periodic(Duration(seconds: 3), (time) {
      time.cancel();
      Navigator.popAndPushNamed(context, "homePage");
    });
  }

  //? INIT STATE
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    backgroundBehaviour =
        backgroundBehaviours[Random().nextInt(backgroundBehaviours.length)];
    loadingDelay();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBackground(
        behaviour:
            backgroundBehaviour, //SpaceBehaviour(), //RacingLinesBehaviour(numLines: 10),
        vsync: this,
        //height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.planet_outline,
                  color: Colors.grey[200],
                ),
                const SizedBox(width: 10.0),
                Text(
                  "Aurora",
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.grey[200],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
