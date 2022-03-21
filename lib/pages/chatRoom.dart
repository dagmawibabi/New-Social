import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:marquee/marquee.dart';
import 'package:newsocial/pages/musicplayerpage.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  //! API URL
  String apiURL =
      "http://dagmawibabi.com/aurora/api"; //"http://dagmawibabi.com/aurora/api";
  TextEditingController messageController = TextEditingController();
  // Get Global Chat Messages
  bool initGlobalChat = false;
  List fetchedChat = [];
  List globalChat = [];
  bool gettingGlobalChat = false;
  void getGlobalChat() async {
    initGlobalChat = false;
    Timer.periodic(
      Duration(seconds: 1),
      (value) async {
        dynamic url = Uri.parse(apiURL + "/receiveGlobalMessage");
        dynamic chats = await http.get(url);
        //print(chats.body);
        fetchedChat = [];
        fetchedChat = jsonDecode(chats.body);
        // initial state
        if (initGlobalChat == true) {
          globalChat = [];
          globalChat = jsonDecode(chats.body);
          gettingGlobalChat = true;
        } else {
          if (globalChat.length != fetchedChat.length) {
            // if new message is received
            globalChat = [];
            globalChat = jsonDecode(chats.body);
            /*chatScrollController.animateTo(
              chatScrollController.position.maxScrollExtent + 100,
              duration: Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
            );*/
            setState(() {});
          }
        }
        gettingGlobalChat = false;
      },
    );
  }

  // Send to Global Chat
  String masterUser = "";
  final ScrollController chatScrollController = ScrollController();
  void sendGlobalChat(message) async {
    dynamic url = Uri.parse(apiURL +
        "/sendGlobalMessage/" +
        masterUser.toString() +
        "/" +
        message.toString());
    await http.get(url);
    //chatScrollController.jumpTo(chatScrollController.position.maxScrollExtent);
    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent + 100,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Edit Global Message
  final focus = FocusNode();
  bool isEditing = false;
  void editGlobalMessage(message, time, newMessage) async {
    dynamic url = Uri.parse(apiURL +
        "/updateGlobalMessage/" +
        masterUser.toString() +
        "/" +
        message.toString() +
        "/" +
        time.toString() +
        "/" +
        newMessage.toString());
    await http.get(url);
    selectedIndex = -1;
    selectedMessage = "";
    selectedTime = "";
    isDeleting = false;
    isEditing = false;
    messageController.clear();
    globalChat = [];
  }

  // Delete Global Message
  bool isDeleting = false;
  int selectedIndex = -1;
  String selectedMessage = "";
  String selectedTime = "";
  void deleteGlobalMessage(message, time) async {
    print("in container delete function");
    dynamic url = Uri.parse(apiURL +
        "/deleteGlobalMessage/" +
        masterUser.toString() +
        "/" +
        message.toString() +
        "/" +
        time.toString());
    await http.get(url);
    selectedIndex = -1;
    selectedMessage = "";
    selectedTime = "";
    isDeleting = false;
  }

  // Random
  Random random = new Random();
  dynamic getRandom(List lists) {
    int randomIndex = random.nextInt(lists.length - 1);
    return lists[randomIndex];
  }

  // Check if it's just emoji
  String characterList =
      "abcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()-_=+{[}]|\\:;\"\'<,>.?/~`";
  bool isEmojiOnly(String message) {
    for (String chars in message.characters) {
      if (characterList.characters.contains(chars) == true) {
        return false;
      }
    }
    return true;
  }

  //! Controls
  bool firstCall = true;
  dynamic curUser = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)!.settings.arguments;

    if (firstCall == true) {
      globalChat = receivedData["globalChat"];
      curUser = receivedData["curUser"];
      getGlobalChat();
      firstCall = false;
    }

    bool isDarkMode = receivedData["isDarkMode"];
    bool isSongPlaying = receivedData["isSongPlaying"];
    bool marqueeMusicTitle = receivedData["marqueeMusicTitle"];

    dynamic albumArtImage = receivedData["albumArtImage"];
    List albumArts = receivedData["albumArts"];

    masterUser = receivedData["masterUser"];

    Color iconColor = receivedData["iconColor"];
    Color textColor = receivedData["textColor"];
    Color containerColor = receivedData["containerColor"];
    Color feedCardShadow = receivedData["feedCardShadow"];
    Color textColorDim = receivedData["textColorDim"];
    Color textColorDimmer = receivedData["textColorDimmer"];
    Color scaffoldBGColor = receivedData["scaffoldBGColor"];

    String curSong = receivedData["curSong"];
    dynamic assetsAudioPlayer = receivedData["assetsAudioPlayer"];
    Function pausePlaySong = receivedData["pausePlaySong"];
    Function nextInPlaylist = receivedData["nextInPlaylist"];
    Function backInPlaylist = receivedData["backInPlaylist"];
    Function musicListBottomSheet = receivedData["musicListBottomSheet"];

    String appBarTitle = receivedData["appBarTitle"];
    return Scaffold(
      backgroundColor: scaffoldBGColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: iconColor,
        ),
        backgroundColor: containerColor,
        elevation: 0.0,
        title: Text(
          appBarTitle,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
              isSongPlaying == true ? 50.0 : 0.0), // here the desired height
          child: isSongPlaying == true
              ? Container(
                  decoration: BoxDecoration(
                    color: containerColor,
                    border: Border.all(
                      color: feedCardShadow.withOpacity(0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          musicListBottomSheet(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note_outlined,
                              color: iconColor,
                            ),
                            const SizedBox(width: 8.0),
                            SizedBox(
                              width: 180.0,
                              height: 20.0,
                              child: marqueeMusicTitle == true
                                  ? Marquee(
                                      text: curSong,
                                      blankSpace: 40.0,
                                      pauseAfterRound:
                                          Duration(milliseconds: 1500),
                                      velocity: 10.0,
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    )
                                  : Text(
                                      curSong,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // Rewind
                          GestureDetector(
                            onLongPressDown: (longPressDownDetails) {
                              assetsAudioPlayer.forwardOrRewind(
                                  -MusicPlayerPage.forwardRewindSpeed);
                            },
                            onLongPressEnd: (longPressDownDetails) {
                              assetsAudioPlayer.forwardOrRewind(0.0);
                            },
                            child: IconButton(
                              onPressed: () {
                                backInPlaylist();
                              },
                              icon: Icon(
                                Icons.fast_rewind_rounded,
                                color: iconColor,
                              ),
                            ),
                          ),
                          // Pause Play
                          IconButton(
                            onPressed: () {
                              pausePlaySong();
                            },
                            icon: Icon(
                              isSongPlaying ? Icons.pause : Icons.play_arrow,
                              color: iconColor,
                            ),
                          ),
                          // Forward
                          GestureDetector(
                            onLongPressDown: (longPressDownDetails) {
                              assetsAudioPlayer.forwardOrRewind(
                                  MusicPlayerPage.forwardRewindSpeed);
                            },
                            onLongPressEnd: (longPressDownDetails) {
                              assetsAudioPlayer.forwardOrRewind(0.0);
                            },
                            child: IconButton(
                              onPressed: () {
                                nextInPlaylist();
                              },
                              icon: Icon(
                                Icons.fast_forward_rounded,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
        ),
        actions: [
          (selectedIndex != -1)
              ? Row(
                  children: [
                    // Cancel Btn
                    IconButton(
                      onPressed: () {
                        isDeleting = false;
                        isEditing = false;
                        selectedIndex = -1;
                        selectedMessage = "";
                        selectedTime = "";
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.remove,
                        color: iconColor,
                      ),
                    ),
                    // Edit Btn
                    Padding(
                      padding: const EdgeInsets.only(right: 0.0),
                      child: IconButton(
                        onPressed: () {
                          isEditing = true;
                          messageController.clear();
                          messageController.text = selectedMessage;
                          FocusScope.of(context).requestFocus(focus);
                        },
                        icon: Icon(
                          Ionicons.pencil_sharp,
                          color: iconColor,
                        ),
                      ),
                    ),
                    // Delete Btn
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                        onPressed: () {
                          isDeleting = true;
                          setState(() {});
                          deleteGlobalMessage(
                            selectedMessage,
                            selectedTime,
                          );
                        },
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
      body: ListView(
        reverse: true,
        children: [
          Column(
            children: [
              // Message List
              Container(
                height: MediaQuery.of(context).size.height - 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (albumArts.indexOf(albumArtImage) == -1
                        ? NetworkImage(albumArtImage) as ImageProvider
                        : ExactAssetImage(albumArtImage)),
                    opacity: 0.3,
                    fit: BoxFit.cover,
                    colorFilter: isDarkMode == true
                        ? ColorFilter.srgbToLinearGamma()
                        : ColorFilter.mode(
                            scaffoldBGColor,
                            BlendMode.dst,
                          ),
                  ),
                ),
                //color: Colors.grey,
                child: gettingGlobalChat == false
                    ? ListView.builder(
                        controller: chatScrollController,
                        shrinkWrap: true,
                        itemCount: globalChat.length,
                        itemBuilder: (context, index) {
                          return Container(
                            //color: Colors.red,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 1.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  globalChat[index]["sender"] == masterUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                // Profile Pic -- Other Users
                                globalChat[index]["sender"] != masterUser
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            "contentViewerPage",
                                            arguments: {
                                              "image": globalChat[index]
                                                          ["dp"] !=
                                                      ""
                                                  ? globalChat[index]["dp"]
                                                  : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg",
                                              "shareLink": globalChat[index]
                                                          ["dp"] !=
                                                      ""
                                                  ? globalChat[index]["dp"]
                                                  : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg",
                                              "downloadingImage": false,
                                              "downloadingImageIndex": 0,
                                              "downloadingImageDone": false,
                                              "index": index,
                                              "downloadImage": false,
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              topRight: isEmojiOnly(
                                                          globalChat[index]
                                                              ["sender"]) ==
                                                      true
                                                  ? Radius.circular(0.0)
                                                  : Radius.circular(0.0),
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                            ),
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 1.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: Image.network(globalChat[
                                                        index]["dp"] !=
                                                    ""
                                                ? globalChat[index]["dp"]
                                                : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg"),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                // Message Container
                                GestureDetector(
                                  onTap: () {
                                    selectedIndex = -1;
                                    selectedMessage = "";
                                    selectedTime = "";
                                    setState(() {});
                                  },
                                  onLongPress: () {
                                    if (globalChat[index]["sender"] ==
                                        masterUser) {
                                      selectedIndex = index;
                                      selectedMessage =
                                          globalChat[index]["message"];
                                      selectedTime = globalChat[index]["time"];

                                      setState(() {});
                                    }
                                  },
                                  child: isEmojiOnly(
                                              globalChat[index]["message"]) ==
                                          true
                                      // Emoji Only
                                      ? Container(
                                          constraints: BoxConstraints(
                                              maxWidth: 250.0, minWidth: 80.0),
                                          margin: const EdgeInsets.only(
                                              bottom: 3.0,
                                              left: 1.5,
                                              right: 1.5),
                                          decoration: BoxDecoration(
                                            color: index == selectedIndex
                                                ? (isDeleting == true
                                                    ? (isDarkMode == true
                                                        ? Colors.red[900]!
                                                        : Colors.redAccent)
                                                    : (isEditing == true
                                                        ? (isDarkMode
                                                            ? Colors.teal
                                                            : Colors.tealAccent)
                                                        : (isDarkMode
                                                            ? Colors.blue[800]!
                                                            : Colors
                                                                .lightBlueAccent)))
                                                : containerColor
                                                    .withOpacity(0.0),
                                            border: Border.all(
                                                color: (index == selectedIndex)
                                                    ? textColorDimmer
                                                        .withOpacity(0.5)
                                                    : Colors.transparent),
                                            borderRadius: globalChat[index]
                                                        ["sender"] ==
                                                    masterUser
                                                ? BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20.0),
                                                    //topRight: Radius.circular(20.0),
                                                    bottomLeft:
                                                        Radius.circular(20.0),
                                                    bottomRight:
                                                        Radius.circular(20.0),
                                                  )
                                                : BorderRadius.only(
                                                    //topLeft: Radius.circular(20.0),
                                                    topRight:
                                                        Radius.circular(20.0),
                                                    bottomLeft:
                                                        Radius.circular(20.0),
                                                    bottomRight:
                                                        Radius.circular(20.0),
                                                  ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                globalChat[index]["sender"] ==
                                                        masterUser
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              // Sender
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                        vertical: 5.0),
                                                decoration: BoxDecoration(
                                                  color: index == selectedIndex
                                                      ? (isDeleting == true
                                                          ? (isDarkMode
                                                              ? Colors.red[900]!
                                                              : Colors
                                                                  .redAccent)
                                                          : (isEditing == true
                                                              ? (isDarkMode
                                                                  ? Colors.teal
                                                                  : Colors
                                                                      .tealAccent)
                                                              : (isDarkMode
                                                                  ? Colors.blue[
                                                                      800]!
                                                                  : Colors
                                                                      .lightBlueAccent)))
                                                      : containerColor
                                                          .withOpacity(0.96),
                                                  border: Border.all(
                                                      color: (selectedIndex ==
                                                              index)
                                                          ? Colors.transparent
                                                          : textColorDimmer
                                                              .withOpacity(
                                                                  0.5)),
                                                  borderRadius: globalChat[
                                                                  index]
                                                              ["sender"] ==
                                                          masterUser
                                                      ? BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20.0),
                                                          //topRight: Radius.circular(20.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20.0),
                                                        )
                                                      : BorderRadius.only(
                                                          //topLeft: Radius.circular(20.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  20.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20.0),
                                                        ),
                                                ),
                                                child: Text(
                                                  globalChat[index]["sender"],
                                                  textAlign: globalChat[index]
                                                              ["sender"] ==
                                                          masterUser
                                                      ? TextAlign.right
                                                      : TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              // Content
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0,
                                                    bottom: 20.0,
                                                    right: 10.0,
                                                    left: 10.0),
                                                constraints: BoxConstraints(
                                                    maxWidth: 250.0,
                                                    minWidth: 80.0),
                                                margin: const EdgeInsets.only(
                                                    bottom: 3.0,
                                                    left: 1.5,
                                                    right: 1.5),
                                                child: (selectedIndex == index)
                                                    ? SelectableText(
                                                        isEditing == true
                                                            ? messageController
                                                                .text
                                                            : globalChat[index]
                                                                ["message"],
                                                        style: TextStyle(
                                                          fontSize: 50.0,
                                                          color: textColor,
                                                        ),
                                                      )
                                                    : Text(
                                                        globalChat[index]
                                                            ["message"],
                                                        textAlign: globalChat[
                                                                        index][
                                                                    "sender"] ==
                                                                masterUser
                                                            ? TextAlign.right
                                                            : TextAlign.left,
                                                        style: TextStyle(
                                                          fontSize: 50.0,
                                                          color: textColor,
                                                        ),
                                                      ),
                                              ),
                                              // Time
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                        vertical: 5.0),
                                                child: Text(
                                                  globalChat[index]["time"],
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: isDarkMode
                                                        ? textColor
                                                        : textColorDimmer
                                                            .withOpacity(1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )

                                      // Normal Texts
                                      : Container(
                                          constraints: BoxConstraints(
                                              maxWidth: 250.0, minWidth: 80.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0, vertical: 5.0),
                                          margin: const EdgeInsets.only(
                                              bottom: 3.0,
                                              left: 1.5,
                                              right: 1.5),
                                          decoration: BoxDecoration(
                                            color: index == selectedIndex
                                                ? (isDeleting == true
                                                    ? (isDarkMode
                                                        ? Colors.red[900]!
                                                        : Colors.redAccent)
                                                    : (isEditing == true
                                                        ? (isDarkMode
                                                            ? Colors.teal[800]!
                                                            : Colors.tealAccent)
                                                        : (isDarkMode
                                                            ? Colors.blue[800]!
                                                            : Colors
                                                                .lightBlueAccent)))
                                                : containerColor
                                                    .withOpacity(0.96),
                                            border: Border.all(
                                                color: textColorDimmer
                                                    .withOpacity(0.5)),
                                            borderRadius: globalChat[index]
                                                        ["sender"] ==
                                                    masterUser
                                                ? BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20.0),
                                                    //topRight: Radius.circular(20.0),
                                                    bottomLeft:
                                                        Radius.circular(20.0),
                                                    bottomRight:
                                                        Radius.circular(20.0),
                                                  )
                                                : BorderRadius.only(
                                                    //topLeft: Radius.circular(20.0),
                                                    topRight:
                                                        Radius.circular(20.0),
                                                    bottomLeft:
                                                        Radius.circular(20.0),
                                                    bottomRight:
                                                        Radius.circular(20.0),
                                                  ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                globalChat[index]["sender"] ==
                                                        masterUser
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              // Sender
                                              Text(
                                                globalChat[index]["sender"],
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              SizedBox(height: 2.0),
                                              // Message Content
                                              (selectedIndex == index)
                                                  ? SelectableText(
                                                      isEditing == true
                                                          ? messageController
                                                              .text
                                                          : globalChat[index]
                                                              ["message"],
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: textColor,
                                                      ),
                                                    )
                                                  : Text(
                                                      globalChat[index]
                                                          ["message"],
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: textColor,
                                                      ),
                                                      softWrap: true,
                                                    ),
                                              SizedBox(height: 2.0),
                                              // Time
                                              Text(
                                                globalChat[index]["time"],
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  color:
                                                      (selectedIndex == index)
                                                          ? textColor
                                                          : textColorDimmer
                                                              .withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                                // Profile Pic -- Master User
                                globalChat[index]["sender"] == masterUser
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            "contentViewerPage",
                                            arguments: {
                                              "image": curUser["dp"] != ""
                                                  ? curUser["dp"]
                                                  : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg",
                                              "shareLink": curUser["dp"] != ""
                                                  ? curUser["dp"]
                                                  : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg",
                                              "downloadingImage": false,
                                              "downloadingImageIndex": 0,
                                              "downloadingImageDone": false,
                                              "index": index,
                                              "downloadImage": false,
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: isEmojiOnly(
                                                          globalChat[index]
                                                              ["message"]) ==
                                                      true
                                                  ? Radius.circular(0.0)
                                                  : Radius.circular(0.0),
                                              topRight: Radius.circular(20.0),
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                            ),
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 1.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: Image.network(curUser[
                                                        "dp"] !=
                                                    ""
                                                ? curUser["dp"]
                                                : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg"),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Container(
                          width: 50.0,
                          height: 50.0,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: CircularProgressIndicator(
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
              ),
              // Input Box Attach and Send
              Container(
                margin: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.attach_file,
                        color: iconColor,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: textColorDimmer,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: TextField(
                          focusNode: focus,
                          controller: messageController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          minLines: 1,
                          maxLines: 25,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            hintText: "message",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: textColorDimmer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (isEditing == true) {
                          editGlobalMessage(selectedMessage, selectedTime,
                              messageController.text);
                        } else {
                          sendGlobalChat(messageController.text);
                          messageController.clear();
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
