import 'dart:async';
import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PostContentPage extends StatefulWidget {
  const PostContentPage({Key? key}) : super(key: key);

  @override
  State<PostContentPage> createState() => _PostContentPageState();
}

class _PostContentPageState extends State<PostContentPage> {
  //! API URL
  String apiURL =
      "http://dagmawibabi.com/aurora/api"; //"http://dagmawibabi.com/aurora/api";
  TextEditingController titleTextController = TextEditingController();
  TextEditingController bodyTextController = TextEditingController();

  // Post New Content
  void postContent(String title, String body) async {
    isLoading = true;
    setState(() {});
    var url = await Uri.parse(apiURL +
        "/createNewPost/" +
        curUser["username"] +
        "/" +
        curUser["password"] +
        "/" +
        title +
        "/" +
        body);
    await http.get(url);
    // Success
    /*CherryToast.success(
      title: "Posted Successfully!",
      titleStyle: TextStyle(fontSize: 16.0),
      autoDismiss: true,
      animationDuration: Duration(milliseconds: 200),
      toastDuration: Duration(milliseconds: 1300),
    ).show(context);
    titleTextController.clear();
    bodyTextController.clear();*/
    isLoading = false;
    setState(() {});
    Navigator.pop(context);
  }

  // Get Content
  void getContent() async {
    isLoading = true;
    setState(() {});
    var url = await Uri.parse(apiURL +
        "/getPosts/" +
        curUser["username"] +
        "/" +
        curUser["password"]);
    var response = await http.get(url);
    var responseJSON = jsonDecode(response.body);
    isLoading = false;
    setState(() {});
  }

  bool isFirstTime = true;
  dynamic curUser = {};
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)!.settings.arguments;
    if (isFirstTime) {
      curUser = receivedData["curUser"];
      isFirstTime = false;
    }
    bool isDarkMode = receivedData["isDarkMode"];
    Color iconColor = receivedData["iconColor"];
    Color textColor = receivedData["textColor"];
    Color containerColor = receivedData["containerColor"];
    Color feedCardShadow = receivedData["feedCardShadow"];
    Color textColorDim = receivedData["textColorDim"];
    Color textColorDimmer = receivedData["textColorDimmer"];
    Color scaffoldBGColor = receivedData["scaffoldBGColor"];
    return Scaffold(
      backgroundColor: scaffoldBGColor,
      appBar: AppBar(
        backgroundColor: scaffoldBGColor,
        elevation: 0.0,
        title: Text(
          "New Post",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        iconTheme: IconThemeData(
          color: iconColor,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            // Title
            Container(
              padding: const EdgeInsets.only(left: 15.0, right: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //border: Border.all(color: Colors.black),
              ),
              child: TextField(
                controller: titleTextController,
                style: TextStyle(
                  fontSize: 19.0,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Title",
                  hintStyle: TextStyle(
                    fontSize: 19.0,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Divider(color: Colors.black),
            SizedBox(height: 4.0),
            // Body
            Container(
              height: 300.0,
              padding: const EdgeInsets.only(left: 15.0, right: 5.0),
              decoration: BoxDecoration(
                color: feedCardShadow.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //border: Border.all(color: Colors.black),
              ),
              child: TextField(
                maxLines: 100,
                controller: bodyTextController,
                style: TextStyle(
                  fontSize: 20.0,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Body",
                  hintStyle: TextStyle(
                    fontSize: 20.0,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Post Button
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isDarkMode
                          ? feedCardShadow.withOpacity(0.5)
                          : containerColor),
                    ),
                    onPressed: () {
                      postContent(titleTextController.text.trim(),
                          bodyTextController.text.trim());
                    },
                    child: isLoading
                        ? LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.greenAccent,
                            size: 25.0,
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.post_add,
                                color: iconColor,
                                size: 22.0,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                "Post",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                  ),
                  // Attach
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isDarkMode
                          ? feedCardShadow.withOpacity(0.5)
                          : containerColor),
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file_outlined,
                          color: iconColor,
                          size: 22.0,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          "Attach",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
