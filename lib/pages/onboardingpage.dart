import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:onboarding/onboarding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  //! API URL
  String apiURL =
      "http://dagmawibabi.com/aurora/api"; //"http://dagmawibabi.com/aurora/api";
  // User Model
  dynamic user = {};
  bool isDarkMode = false;
  bool isLoginForm = false;
  TextEditingController fullnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Check permission status
  bool locPermissionStat = false;
  bool camPermissionStat = false;
  bool storagePermissionStat = false;
  bool allPermissionState = false;
  void checkPermissions() async {
    locPermissionStat = await Permission.location.status.isGranted;
    camPermissionStat = await Permission.camera.status.isGranted;
    storagePermissionStat = await Permission.storage.status.isGranted;
    if (locPermissionStat && camPermissionStat && storagePermissionStat) {
      allPermissionState = true;
    }
    setState(() {});
  }

  // Ask Permissions
  void askPermission(int index) async {
    switch (index) {
      case 1: // Camera Permissions
        await Permission.camera.request();
        camPermissionStat = await Permission.camera.status.isGranted;
        checkPermissions();
        setState(() {});
        break;
      case 2: // Storage Permissions
        await Permission.storage.request();
        storagePermissionStat = await Permission.storage.status.isGranted;
        checkPermissions();
        setState(() {});
        break;
      case 3: // Location Permissions
        await Permission.location.request();
        locPermissionStat = await Permission.location.status.isGranted;
        checkPermissions();
        setState(() {});
        break;
    }
  }

  // Create new user
  bool isUsernameTaken = false;
  bool isLoading = false;
  bool isUsernameCorrect = true;
  bool isPasswordCorrect = true;
  void createNewUser(String fullname, String username, String password) async {
    // reset
    isUsernameTaken = false;
    isUsernameCorrect = true;
    isPasswordCorrect = true;
    // Status
    isLoading = true;
    setState(() {});

    // Check if username exists
    dynamic url = Uri.parse(apiURL + "/getAllUsers");
    dynamic userNames = await http.get(url);
    dynamic userNamesJSON = jsonDecode(userNames.body);
    for (var users in userNamesJSON) {
      print(users);
      if (users["username"].toString().toLowerCase() ==
          username.toLowerCase()) {
        isUsernameTaken = true;
        isLoading = false;
        setState(() {});
      }
    }
    /* Password Validation should happen here */
    if (isUsernameTaken == false) {
      dynamic url = Uri.parse(apiURL +
          "/createNewUser/" +
          fullname.toString() +
          "/" +
          username.toString() +
          "/" +
          password.toString());
      await http.get(url);
      dynamic url2 = Uri.parse(apiURL + "/login/" + username + "/" + password);
      dynamic responseOBJ = await http.get(url2);
      dynamic responseJSON = jsonDecode(responseOBJ.body);
      user = responseJSON;
      Navigator.pushReplacementNamed(
        context,
        "homePage",
        arguments: {
          "currentUser": user,
          "masterUser": usernameController.text,
          "isDarkMode": isDarkMode,
        },
      );
    }
  }

  // Login old user
  void loginUser(String username, String password) async {
    // Reset
    // reset
    isUsernameTaken = false;
    isUsernameCorrect = true;
    isPasswordCorrect = true;
    // Status
    isLoading = true;
    setState(() {});
    // Check if username exists
    dynamic url = Uri.parse(apiURL + "/getAllUsers");
    dynamic userNames = await http.get(url);
    dynamic userNamesJSON = jsonDecode(userNames.body);
    isUsernameCorrect = false;
    for (var users in userNamesJSON) {
      if (users["username"].toString().toLowerCase() ==
          username.toLowerCase()) {
        isUsernameCorrect = true;
      }
    }
    if (isUsernameCorrect == true) {
      dynamic url = Uri.parse(apiURL + "/login/" + username + "/" + password);
      dynamic responseOBJ = await http.get(url);
      try {
        dynamic responseJSON = jsonDecode(responseOBJ.body);
        user = responseJSON;
        Navigator.pushReplacementNamed(
          context,
          "homePage",
          arguments: {
            "currentUser": user,
            "masterUser": usernameController.text,
            "isDarkMode": isDarkMode,
          },
        );
      } catch (e) {
        isPasswordCorrect = false;
        isLoading = false;
        setState(() {});
      }
    } else {
      isUsernameCorrect = false;
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    // Light Mode Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Colors.grey[200],
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Onboarding(
        background: Colors.grey[900]!,
        proceedButtonStyle: ProceedButtonStyle(
          proceedButtonRoute: (context) {
            isLoginForm = !isLoginForm;
            setState(() {});
          },
          proceedpButtonText: Text(
            !allPermissionState ? "Disabled" : "Sign Up | Login",
            style: TextStyle(
              fontSize: !allPermissionState ? 16.0 : 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        indicator: Indicator(
          indicatorDesign: IndicatorDesign.line(
            lineDesign: LineDesign(
              lineType: DesignType.line_nonuniform,
              lineSpacer: 22.0,
              lineWidth: 16.0,
            ),
          ),
        ),
        pages: [
          // Page 0 - Welcome
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(
                  "assets/images/content_illustrations/5.png",
                ),
                //Spacer(),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Welcome to Aurora",
                    style: pageTitleStyle,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "An All-in-One multi-purpose social media! \nWith an aesthetically pleasing, minimal and simple interface.",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),

          // Page 1 - Feed and weather
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset("assets/images/onboarding_illustrations/2.png"),
                //Spacer(),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Mesmerizing Content",
                    style: pageTitleStyle,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Explore incredible content, get informed on the latest news, get the current weather all organized and perfectly labelled on your home feed.",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),
          // Page 2 - Chat
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset("assets/images/onboarding_illustrations/6.png"),
                //Spacer(),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Secure Chat",
                    style: pageTitleStyle,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Chat and share content with your friends, family and beloved ones using fast, reliable and secured texting.",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),
          // Page 3 - Music Player
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset("assets/images/onboarding_illustrations/7.png"),
                //Spacer(),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Aesthetic Music Player",
                    style: pageTitleStyle,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Our music player is one of the most aesthetically pleasing music players you've ever seen. We hope you'll love to jam to your fav tunes as much as we do.",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),
          // Page 4 - Crypto Wallet
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset("assets/images/onboarding_illustrations/3.png"),
                //Spacer(),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Protected Crypto Wallet",
                    style: pageTitleStyle,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "We've built a very secure and protected crypto wallet right into this app so you can manage your virtual expenses with ease.",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),

          //
          // Page 5 - DarkLight
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset("assets/images/onboarding_illustrations/5.png"),
                //Spacer(),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Dark or Light Mode?",
                    style: pageTitleStyle,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Choose a theme...",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                // Dark Mode
                Container(
                  //width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250.0, 30.0)),
                      backgroundColor: MaterialStateProperty.all(
                        isDarkMode
                            ? Colors.greenAccent
                            : Colors.grey[
                                850], // isDarkMode ? Colors.grey[850] : Colors.grey[800],
                      ),
                    ),
                    child: Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: isDarkMode
                            ? Colors.black
                            : Colors.grey[
                                200], // isDarkMode ? Colors.greenAccent : Colors.grey[200],
                      ),
                    ),
                    onPressed: () {
                      isDarkMode = true;
                      setState(() {});
                    },
                  ),
                ),
                // Light Mode
                Container(
                  //width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250.0, 30.0)),
                      backgroundColor: MaterialStateProperty.all(
                        isDarkMode ? Colors.grey[200] : Colors.greenAccent,
                      ),
                    ),
                    child: Text(
                      "Light Mode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      isDarkMode = false;
                      setState(() {});
                    },
                  ),
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),

          //
          // Page 6 - Permissions
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset("assets/images/onboarding_illustrations/4.png"),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Grant Permissions",
                    style: pageTitleStyle,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    "This app depends on the following permissions to operate flawlessly and present you with precise data.",
                    style: pageInfoStyle,
                  ),
                ),
                Spacer(),
                // Camera Permission
                Container(
                  //width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250.0, 30.0)),
                      backgroundColor: MaterialStateProperty.all(
                        camPermissionStat ? Colors.greenAccent : Colors.blue,
                      ),
                    ),
                    child: Text(
                      "Grant Camera Access",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: camPermissionStat ? Colors.black : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      askPermission(1);
                    },
                  ),
                ),
                // Storage and Media Permission
                Container(
                  //width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250.0, 30.0)),
                      backgroundColor: MaterialStateProperty.all(
                        storagePermissionStat
                            ? Colors.greenAccent
                            : Colors.blue,
                      ),
                    ),
                    child: Text(
                      "Grant Storage Access",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color:
                            storagePermissionStat ? Colors.black : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      askPermission(2);
                    },
                  ),
                ),
                // Location Permission
                Container(
                  //width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250.0, 30.0)),
                      backgroundColor: MaterialStateProperty.all(
                        locPermissionStat ? Colors.greenAccent : Colors.blue,
                      ),
                    ),
                    child: Text(
                      "Grant Location Access",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: locPermissionStat ? Colors.black : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      askPermission(3);
                    },
                  ),
                ),
                Spacer(),
              ],
            ),
          ),

          //
          // Page 7 - Create An Account
          !allPermissionState
              ? PageModel(
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Image.asset("assets/images/error_illustrations/3.png"),
                      //Spacer(),
                      SizedBox(height: 20.0),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Grant All Permissions \nTo Continue",
                          style: pageTitleStyle,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "The app depends on the previously listed permissions. You must grant all permissions to start using this app.",
                          style: pageInfoStyle,
                        ),
                      ),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
                )
              : PageModel(
                  widget: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          Image.asset(
                              "assets/images/onboarding_illustrations/1.png"),
                          SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            child: Text(
                              "Create an Account",
                              style: pageTitleStyle,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              "Create an account and start exploring this app.",
                              style: pageInfoStyle,
                            ),
                          ),
                          Spacer(),
                          // Full name Input
                          isLoginForm
                              ? Container()
                              : TextField(
                                  controller: fullnameController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.person,
                                      color: Colors.grey[700],
                                      size: 22.0,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                          // Username Input
                          TextField(
                            controller: usernameController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              suffixIcon: Icon(
                                Icons.link,
                                color: Colors.grey[700],
                                size: 22.0,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          // Username taken
                          isUsernameTaken == true
                              ? Column(
                                  children: [
                                    SizedBox(height: 5.0),
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        "Username is taken",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                  ],
                                )
                              : Container(),
                          // Username doesn't exist
                          isUsernameCorrect == false
                              ? Column(
                                  children: [
                                    SizedBox(height: 5.0),
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        "Username doesn't exist",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                  ],
                                )
                              : Container(),
                          // Password Input
                          TextField(
                            controller: passwordController,
                            maxLines: 1,
                            obscureText: isLoginForm ? true : false,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              suffixIcon: Icon(
                                Ionicons.key,
                                color: Colors.grey[700],
                                size: 22.0,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          // Password is incorrect
                          isPasswordCorrect == false
                              ? Column(
                                  children: [
                                    SizedBox(height: 5.0),
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        "Password is incorrect",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                  ],
                                )
                              : Container(),
                          // Password Hint
                          SizedBox(height: 8.0),
                          Text(
                            "Password should be at least 6 characters long, contains numbers and symbols",
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                          Spacer(),
                          // Create or login giant btn
                          Container(
                            width: double.infinity,
                            child: isLoading
                                ? Container(
                                    child: Center(
                                      child: LoadingAnimationWidget
                                          .staggeredDotsWave(
                                        color: isLoginForm
                                            ? Colors.blueAccent
                                            : Colors.greenAccent,
                                        size: 35.0,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(
                                        Size(250.0, 45.0),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        isLoginForm
                                            ? Colors.blue
                                            : Colors.greenAccent,
                                      ),
                                    ),
                                    child: Text(
                                      isLoginForm ? "Login" : "Create Account",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19.0,
                                        color: isLoginForm
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (isLoginForm == true) {
                                        loginUser(usernameController.text,
                                            passwordController.text);
                                      } else {
                                        createNewUser(
                                            fullnameController.text,
                                            usernameController.text,
                                            passwordController.text);
                                      }
                                    },
                                  ),
                          ),
                          TextButton(
                            onPressed: () {
                              isLoginForm = !isLoginForm;
                              setState(() {});
                            },
                            child: Text(
                              !isLoginForm ? "Login" : "Create a new account",
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: isLoginForm
                                    ? Colors.greenAccent
                                    : Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
