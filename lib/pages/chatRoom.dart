import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:newsocial/pages/musicplayerpage.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController messageController = TextEditingController();
  // Get Global Chat Messages
  bool initGlobalChat = false;
  List fetchedChat = [];
  List globalChat = [];
  bool gettingGlobalChat = true;
  void getGlobalChat() async {
    initGlobalChat = false;
    Timer.periodic(
      Duration(seconds: 1),
      (value) async {
        dynamic url = Uri.parse(
            "https://glacial-everglades-59975.herokuapp.com/api/receiveGlobalMessage");
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
    dynamic url = Uri.parse(
        "https://glacial-everglades-59975.herokuapp.com/api/sendGlobalMessage/" +
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGlobalChat();
  }

  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)!.settings.arguments;
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
                                          //height: 50.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              //topRight: Radius.circular(20.0),
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                            ),
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 1.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.network(globalChat[index]
                                                      ["dp"] !=
                                                  ""
                                              ? globalChat[index]["dp"]
                                              : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg"),
                                        ),
                                      )
                                    : Container(),
                                // Message Container
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 250.0, minWidth: 80.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 5.0),
                                  margin: const EdgeInsets.only(
                                      bottom: 3.0, left: 1.5, right: 1.5),
                                  decoration: BoxDecoration(
                                    color: containerColor.withOpacity(0.96),
                                    border: Border.all(
                                        color:
                                            textColorDimmer.withOpacity(0.5)),
                                    borderRadius: globalChat[index]["sender"] ==
                                            masterUser
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            //topRight: Radius.circular(20.0),
                                            bottomLeft: Radius.circular(20.0),
                                            bottomRight: Radius.circular(20.0),
                                          )
                                        : BorderRadius.only(
                                            //topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                            bottomLeft: Radius.circular(20.0),
                                            bottomRight: Radius.circular(20.0),
                                          ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: globalChat[index]
                                                ["sender"] ==
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
                                      // Message Content
                                      /*Text(
                                        //globalChat[index]["message"],
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: textColor,
                                        ),
                                        softWrap: true,

                                      ),*/
                                      SelectableText(
                                        globalChat[index]["message"],
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: textColor,
                                        ),
                                      ),
                                      SizedBox(height: 2.0),
                                      // Time
                                      Text(
                                        globalChat[index]["time"],
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          color:
                                              textColorDimmer.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
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
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              //topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                            ),
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 1.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.network(globalChat[index]
                                                      ["dp"] !=
                                                  ""
                                              ? globalChat[index]["dp"]
                                              : "https://i.pinimg.com/564x/86/4d/3f/864d3f2beebcd48f4cf57052031de4a0.jpg"),
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
                          controller: messageController,
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
                        sendGlobalChat(messageController.text);
                        messageController.clear();
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
