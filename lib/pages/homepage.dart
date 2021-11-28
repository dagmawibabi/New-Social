import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:newsocial/pages/cryptopage.dart';
import 'package:newsocial/pages/musicplayerpage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user_profile_avatar/user_profile_avatar.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import 'package:cherry_toast/cherry_toast.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // General
  Random random = Random();
  List colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.grey[200],
    Colors.lightBlue,
    Colors.lightGreenAccent
  ];
  bool fullScreenMode = false;
  bool isBottomBarVisible = true;
  // Illustrations
  List empty_illustrations = [
    "assets/images/empty_illustrations/1.png",
    "assets/images/empty_illustrations/2.png",
    "assets/images/empty_illustrations/3.png",
    "assets/images/empty_illustrations/4.png",
    "assets/images/empty_illustrations/5.png",
  ];
  List error_illustrations = [
    "assets/images/error_illustrations/3.png",
    "assets/images/empty_illustrations/2.png",
    "assets/images/empty_illustrations/3.png",
  ];
  List content_illustrations = [
    "assets/images/content_illustrations/1.png",
    "assets/images/content_illustrations/2.png",
    "assets/images/content_illustrations/3.png",
    "assets/images/content_illustrations/4.png",
    "assets/images/content_illustrations/2.png",
  ];
  List search_illustrations = [
    "assets/images/search_illustrations/1.png",
    "assets/images/search_illustrations/2.png",
    "assets/images/search_illustrations/3.png",
    "assets/images/search_illustrations/4.png",
    "assets/images/search_illustrations/5.png",
    "assets/images/search_illustrations/6.png",
  ];

  // Function to hide the bottom nav bar on scroll
  void hideBottomNavBar() {
    if (curPage == 0 || curPage == 3) {
      scrollController.addListener(
        () {
          // Hide on scroll down
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (isBottomBarVisible == true) {
              setState(() {
                isBottomBarVisible = false;
              });
            }
          }
          // Show on scroll up
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            if (isBottomBarVisible == false) {
              setState(() {
                isBottomBarVisible = true;
              });
            }
          }
        },
      );
    } else {
      scrollController.addListener(() {
        // Show on scroll up and down
        if (scrollController.position.userScrollDirection ==
                ScrollDirection.forward ||
            scrollController.position.userScrollDirection ==
                ScrollDirection.reverse) {
          setState(() {
            isBottomBarVisible = true;
          });
        }
      });
    }
  }

  // State Controllers
  int curPage = 0;

  //? HOME PAGE
  // Home Page Variables
  late VideoPlayerController _controller;
  bool isFeedLoading = true;
  List homepageFeed = [];
  // Home Page Functions
  // https://www.reddit.com/r/askscience/top/.json?sort=top
  // https://www.reddit.com/r/todayilearned/top.json?limit=10
  /*
      timeframe = 'month' #hour, day, week, month, year, all
      listing = 'top' # controversial, best, hot, new, random, rising, top
      https://www.reddit.com/r/{subreddit}/{listing}.json?limit={limit}&t={timeframe} 
  */
  void getHomePageFeed(subreddit, sort, time) async {
    isFeedLoading = true;
    setState(() {});
    var url = Uri.parse("https://www.reddit.com/r/" +
        subreddit +
        "/" +
        sort +
        ".json?t=" +
        time +
        "&limit=100");
    var response = await http.get(url);
    var responseJSON = jsonDecode(response.body);
    homepageFeed = responseJSON["data"]["children"];
    //print(responseJSON["data"]["children"][1]["data"]["author_fullname"]);
    isFeedLoading = false;
    setState(() {});
  }

  //? CRYPTO PAGE
  //? Crypto Page Variables
  bool isCryptoPageLoading = true;
  bool isCryptoPageLoadingError = false;
  int cryptoAppBarImageIndex = 0;
  RefreshController refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  List cryptoStats = [];
  List cryptoAppBarImages = [
    "assets/images/appbar_headers/1.png",
    "assets/images/appbar_headers/2.png",
    "assets/images/appbar_headers/3.png",
  ];

  //? Crypto Page Functions
  // Function to fetch crypto price data
  void getCryptoStats() async {
    isCryptoPageLoading = true;
    isCryptoPageLoadingError = false;
    setState(() {});
    var url = Uri.parse(
        "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd");
    try {
      var response = await http.get(url);
      var responseJSON = jsonDecode(response.body);
      cryptoStats = responseJSON;
      isCryptoPageLoading = false;
      isCryptoPageLoadingError = false;
    } catch (e) {
      isCryptoPageLoadingError = true;
    }
    refreshController.loadComplete();
    refreshController.refreshCompleted();
    setState(() {});
  }

  // View Image Alert Dialog
  void viewImageAlertDialog(image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: SizedBox(
            height: MediaQuery.of(context).size.height - 400,
            width: MediaQuery.of(context).size.width - 50,
            child: PhotoView(
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              customSize: const Size(200.0, 200.0),
              imageProvider:
                  CachedNetworkImageProvider(image), /*NetworkImage(image),*/
            ),
          ),
        );
      },
    );
  }

  // Crypto Detail Alert Dialog
  void showCryptoDetail(context, index) {
    List cryptoDetails = [
      {
        "title": "Current Price",
        "value": "\$" + cryptoStats[index]["current_price"].toString()
      },
      {
        "title": "Low Price (24hr)",
        "value": "\$" + cryptoStats[index]["low_24h"].toString(),
      },
      {
        "title": "High Price (24hr)",
        "value": "\$" + cryptoStats[index]["high_24h"].toString(),
      },
      {
        "title": "Price Change (24h)",
        "value": "\$" + cryptoStats[index]["price_change_24h"].toString(),
      },
      {
        "title": "Price Change % (24h)",
        "value":
            cryptoStats[index]["price_change_percentage_24h"].toString() + "%",
      },
      {
        "title": "All Time Low (ATL)",
        "value": "\$" + cryptoStats[index]["atl"].toString(),
      },
      {
        "title": "All Time Low Date",
        "value": cryptoStats[index]["atl_date"].toString().substring(0, 10),
      },
      {
        "title": "All Time High (ATH)",
        "value": "\$" + cryptoStats[index]["ath"].toString(),
      },
      {
        "title": "All Time High Date",
        "value": cryptoStats[index]["ath_date"].toString().substring(0, 10),
      },
      {
        "title": "Market Capital",
        "value": "\$" + cryptoStats[index]["market_cap"].toString(),
      },
      {
        "title": "Total Volume",
        "value": "\$" + cryptoStats[index]["total_volume"].toString(),
      },
      {
        "title": "Total Supply",
        "value": "\$" + cryptoStats[index]["total_supply"].toString(),
      },
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 25.0),
          contentPadding: const EdgeInsets.all(0.0),
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            height: 520.0,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Crypto Image
                GestureDetector(
                    onTap: () {
                      viewImageAlertDialog(cryptoStats[index]["image"]);
                    },
                    child: SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: Image(
                        image: CachedNetworkImageProvider(
                            cryptoStats[index]["image"]),
                      ),
                    ) /*Image.network(
                    cryptoStats[index]["image"],
                    width: 60.0,
                    height: 60.0,
                  ),*/
                    ),
                const SizedBox(height: 10.0),
                Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cryptoStats[index]["id"].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20.0,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cryptoStats[index]["symbol"].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black),
                const SizedBox(height: 4.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 280.0,
                  child: ListView.builder(
                    primary: false,
                    itemCount: cryptoDetails.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cryptoDetails[index]["title"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                cryptoDetails[index]["value"],
                              ),
                            ],
                          ),
                          SizedBox(height: 2.0),
                          Divider(
                            color: Colors.grey[400],
                            thickness: 0.4,
                            indent: 10.0,
                            endIndent: 10.0,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  "Last Updated\n" +
                      cryptoStats[index]["last_updated"]
                          .toString()
                          .substring(11, 19) +
                      "  •  " +
                      cryptoStats[index]["last_updated"]
                          .toString()
                          .substring(0, 10),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    /*showAboutDialog(
      context: context,
      applicationIcon: Image.network(
        cryptoStats[index]["image"],
        width: 60.0,
        height: 60.0,
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10.0),
            Text(
              cryptoStats[index]["id"].toString().toUpperCase(),
              style: const TextStyle(
                fontSize: 20.0,
                letterSpacing: 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Low Price (24hr)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("\$" + cryptoStats[index]["low_24h"].toString()),
              ],
            ),
          ],
        ),
      ],
    );*/
  }

  //!
  void startVid(video) {
    _controller = VideoPlayerController.network(video)
      ..addListener(() => setState(() {}))
      ..initialize().then((_) {
        _controller.play();
      });
  }

  //? Music Page Variables
  bool musicInitState = true;
  Duration curSongDuration = const Duration(seconds: 0);
  dynamic curSongPosition = "";
  List playlist = [];
  List<List<Color>> lightModeWaveGradient = [
    [Colors.red, Color(0xEEF44336)],
    [Colors.lightBlueAccent, Colors.blue],
    [Colors.lightGreenAccent, Colors.green],
    [Colors.yellow, Color(0x55FFEB3B)]
  ];
  Color curPlayingSongColor = Colors.lightBlue;
  FlipCardController flipCardController = FlipCardController();
  List musicFiles = [];
  List<Audio> musicFilesPlaylist = [];
  bool gotSongs = false;
  String curSong = "No Song Playing...";
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  bool isSongPlaying = false;
  int curSongIndex = 0;
  dynamic albumArtImage = "";
  List albumArts = [
    "assets/images/album_arts/albumArt2.png",
    "assets/images/album_arts/albumArt3.png",
    "assets/images/album_arts/albumArt8.png",
    "assets/images/album_arts/albumArt9.png",
    "assets/images/album_arts/albumArt10.png",
    "assets/images/album_arts/albumArt11.png",
    "assets/images/album_arts/albumArt12.png",
    "assets/images/album_arts/albumArt13.png",
    "assets/images/album_arts/albumArt14.png",
    "assets/images/album_arts/albumArt15.png",
    "assets/images/album_arts/albumArt16.png",
    "assets/images/album_arts/albumArt18.png",
    "assets/images/album_arts/albumArt19.png",
    "assets/images/album_arts/albumArt20.png",
    "assets/images/album_arts/albumArt21.png",
    "assets/images/album_arts/albumArt22.png",
    "assets/images/album_arts/albumArt23.png",
    "assets/images/album_arts/albumArt24.png",
    "assets/images/album_arts/albumArt25.png",
    "assets/images/album_arts/albumArt26.png",
    "assets/images/album_arts/albumArt29.png",
    "assets/images/album_arts/albumArt31.png",
    "assets/images/album_arts/albumArt32.png",
    "assets/images/album_arts/albumArt33.png",
    "assets/images/album_arts/albumArt34.png",
    "assets/images/album_arts/albumArt35.png",
    "assets/images/album_arts/albumArt36.png",
    "assets/images/album_arts/albumArt37.png",
    "assets/images/album_arts/albumArt38.png",
    "assets/images/album_arts/albumArt39.png",
    "assets/images/album_arts/albumArt50.png",
    "assets/images/album_arts/albumArt51.png",
    "assets/images/album_arts/albumArt52.png",
    "assets/images/album_arts/albumArt53.png",
    "assets/images/album_arts/albumArt54.png",
    "assets/images/album_arts/albumArt55.png",
    "assets/images/album_arts/albumArt57.png",
    "assets/images/album_arts/albumArt58.png",
    "assets/images/album_arts/albumArt59.png",
    "assets/images/album_arts/albumArt60.png",
    "assets/images/album_arts/albumArt61.png",
    "assets/images/album_arts/albumArt62.png",
    "assets/images/album_arts/albumArt63.png",
    "assets/images/album_arts/albumArt64.png",
  ];

  //? Music Page Functions
  // Init Playlist
  void playlistLoader(curSongChoice) {
    loadPlaySong(playlist[curSongChoice]);
  }

  // Next in playlist
  void nextInPlaylist() {
    curSongIndex++;
    if (curSongIndex > playlist.length - 1) {
      curSongIndex = 0;
    }
    playlistLoader(curSongIndex);
  }

  // Back in playlist
  void backInPlaylist() {
    curSongIndex--;
    if (curSongIndex < 0) {
      curSongIndex = playlist.length - 1;
    }
    playlistLoader(curSongIndex);
  }

  // Function to get songs from device
  void getSongsOnDevice() async {
    askPermissions();
    musicFiles = [];
    dynamic files =
        Directory('/storage/emulated/0/Music').listSync(recursive: false);
    for (FileSystemEntity file in files) {
      if (file.path.endsWith(".mp3") == true ||
          file.path.endsWith(".m4a") == true) {
        musicFiles.add(file.path);
        musicFilesPlaylist.add(Audio(file.path));
      }
    }
    files =
        Directory('/storage/emulated/0/Download').listSync(recursive: false);
    for (FileSystemEntity file in files) {
      if (file.path.endsWith(".mp3") == true ||
          file.path.endsWith(".m4a") == true) {
        musicFiles.add(file.path);
        musicFilesPlaylist.add(Audio(file.path));
      }
    }
    // Init Playlist
    playlist = musicFiles;
    playlistLoader(curSongIndex);
    assetsAudioPlayer.pause();
    isSongPlaying = false;
    //
    gotSongs = true;
    refreshController.loadComplete();
    refreshController.refreshCompleted();
    setState(() {});
  }

  // Change Album Art
  void changeAlbumArt() {
    albumArtImage = getRandom(albumArts);
    setState(() {});
  }

  // Play Songs
  void loadPlaySong(songPath) async {
    assetsAudioPlayer.stop();
    // Play From Path
    await assetsAudioPlayer.open(
      Audio.file(songPath),
      showNotification: true,
      autoStart: musicInitState == true ? false : true,
      notificationSettings: NotificationSettings(
        customPlayPauseAction: (player) {
          pausePlaySong();
        },
        customNextAction: (player) {
          print("next");
        },
      ),
    );
    // Get song duration and current position
    assetsAudioPlayer.current.listen(
      (playingAudio) {
        curSongDuration = playingAudio!.audio.duration;
        setState(() {});
      },
    );
    // Know when song ends playing
    assetsAudioPlayer.playlistAudioFinished.listen(
      (Playing playing) {
        isSongPlaying = false;
        assetsAudioPlayer.stop();
        setState(() {});
      },
    );
    curSong = p.withoutExtension(p.basename(songPath));
    isSongPlaying = musicInitState == true ? false : true;
    musicInitState = false;
    curPlayingSongColor = getRandom(Colors.accents);
    lightModeWaveGradient = [
      [getRandom(Colors.accents), getRandom(Colors.accents)],
      [getRandom(Colors.accents), getRandom(Colors.accents)],
      [getRandom(Colors.accents), getRandom(Colors.accents)],
      [getRandom(Colors.accents), getRandom(Colors.accents)],
    ];
    changeAlbumArt();
    setState(() {});
  }

  // Pause Songs
  void pausePlaySong() {
    if (curSong != "No Song Playing...") {
      if (isSongPlaying == true) {
        assetsAudioPlayer.pause();
      } else {
        assetsAudioPlayer.play();
      }
      isSongPlaying = !isSongPlaying;
    }
    setState(() {});
  }

  // Music Seeker Stream Builder
  Widget sliderStreamBuilder() {
    try {
      return StreamBuilder(
        stream: assetsAudioPlayer.currentPosition,
        builder: (context, asyncSnapshot) {
          final dynamic duration = asyncSnapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: fullScreenMode == true ? 0.0 : 15.0),
            child: Slider(
              activeColor: Colors.grey[900],
              inactiveColor: Colors.grey[500], //Color(0xaa6C63FF),
              value: duration != null ? duration.inSeconds.toDouble() : 0.0,
              min: 0.0,
              max: curSongDuration != null
                  ? curSongDuration.inSeconds.toDouble()
                  : 100.0,
              onChanged: (value) {
                assetsAudioPlayer.seek(
                  Duration(
                    seconds: value.toInt(),
                  ),
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      return Container();
    }
  }

  // Stream Builder
  Widget songPositionStreamBuilder() {
    try {
      return StreamBuilder(
        stream: assetsAudioPlayer.currentPosition,
        builder: (context, asyncSnapshot) {
          final dynamic duration = asyncSnapshot.data;
          try {
            return Text(
              ((duration.inSeconds / 3600).toInt()).toString().padLeft(2, '0') +
                  ":" +
                  ((duration.inSeconds / 60).toInt())
                      .toString()
                      .padLeft(2, '0') +
                  ":" +
                  ((duration.inSeconds % 60).toInt())
                      .toString()
                      .padLeft(2, "0"),
            );
          } catch (e) {
            return Text(
              ("00" + ":" + "00" + ":" + "00"),
            );
          }
        },
      );
    } catch (e) {
      return Container();
    }
  }

  //? Home Page
  List subredditList = [
    "wholesomeMemes",
    "pics",
    "meme",
    "whitePeopleTwitter",
    "funny",
    "damnThatsInteresting",
    "cats",
    "dataIsBeautiful",
    "comics",
    "madeMeSmile",
    "humansForScale",
    "imaginaryCharacters",
    "imaginaryCityscapes",
    "imaginaryCyberpunk",
    "art",
    "artefactPorn",
    "quotesPorn",
  ];
  TextEditingController feedSearch = TextEditingController();
  dynamic feedTimeValue = 1;
  dynamic feedSortValue = 1;
  List feedTimeValues = ["hour", "day", "week", "month", "year", "all"];
  List feedSortValues = ["new", "hot", "rising", "controversial", "top"];
  String chosenSubreddit = "";
  String chosenSubredditTime = "";
  String chosenSubredditSort = "";
  // Custom Feed
  void feedChoice() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 15.0),
          title: Container(
            child: Text(
              "Enter A Subreddit To Browse",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Container(
            height: 160.0,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Input box
                TextField(
                  controller: feedSearch,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Subreddit Name",
                    labelStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Time and Sort
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Time: "),
                      const SizedBox(width: 8.0),
                      DropdownButton(
                        value: feedTimeValue,
                        onChanged: (choice) {
                          feedTimeValue = choice;
                          Navigator.pop(context);
                          feedChoice();
                        },
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text("Hour"),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("Day"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Week"),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text("Month"),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text("Year"),
                          ),
                          DropdownMenuItem(
                            value: 6,
                            child: Text("All"),
                          ),
                        ],
                      ),
                      const SizedBox(width: 30.0),
                      Text("Sort: "),
                      const SizedBox(width: 8.0),
                      DropdownButton(
                        value: feedSortValue,
                        onChanged: (choice) {
                          feedSortValue = choice;
                          Navigator.pop(context);
                          feedChoice();
                        },
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text("New"),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("Hot"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Rising"),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text("Controversial"),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text("Top"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Search Button
            ElevatedButton(
              onPressed: () {
                chosenSubreddit = feedSearch.text.trim();
                chosenSubredditSort = feedSortValues[feedSortValue - 1];
                chosenSubredditTime = feedTimeValues[feedTimeValue - 1];
                getHomePageFeed(
                    chosenSubreddit, chosenSubredditSort, chosenSubredditTime);

                /*getHomePageFeed(
                    feedSearch.text.trim(),
                    feedSortValues[feedSortValue - 1],
                    feedTimeValues[feedTimeValue - 1]);*/
                setState(() {});
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color(0xff6C63FF),
                  /*getRandom(Colors
                      .primaries),*/ //  Colors.teal[700], //deepPurple[800],
                ),
              ),
            ),
            // Back Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Back",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.grey[900],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // viewFeedImages
  void viewFeedImages(image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200]!.withOpacity(0.9),
          contentPadding: const EdgeInsets.all(2.0),
          content: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
            child: PhotoView(
              customSize: Size(MediaQuery.of(context).size.width - 50,
                  MediaQuery.of(context).size.height / 2),
              imageProvider: NetworkImage(image),
              backgroundDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }

  // Download Image
  bool downloadingImage = false;
  int downloadingImageIndex = -1;
  bool downloadingImageDone = false;
  void downloadImage(image) async {
    downloadingImage = true;
    downloadingImageDone = false;
    setState(() {});
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(
        image,
        destination: AndroidDestinationType.directoryDownloads
          ..subDirectory(image.toString().substring(18)),
      );
      if (imageId == null) {
        return;
      }

      // Below is a method of obtaining saved image information.
      var fileName = await ImageDownloader.findName(imageId);
      var path = await ImageDownloader.findPath(imageId);
      var size = await ImageDownloader.findByteSize(imageId);
      var mimeType = await ImageDownloader.findMimeType(imageId);
      // Success
      CherryToast.success(
        title: "Downloaded Successfully!",
        titleStyle: TextStyle(fontSize: 16.0),
        autoDismiss: true,
        animationDuration: Duration(milliseconds: 800),
      ).show(context);
    } catch (error) {
      // Success
      CherryToast.error(
        title: "Downloading Failed!",
        titleStyle: TextStyle(fontSize: 16.0),
        autoDismiss: true,
        animationDuration: Duration(milliseconds: 800),
      ).show(context);
    }
    downloadingImage = false;
    downloadingImageDone = true;
    setState(() {});
  }

  // refresh Feed
  void getHomePageFeedRefresh() {
    getHomePageFeed(chosenSubreddit, chosenSubredditSort, chosenSubredditTime);
    refreshController.loadComplete();
    refreshController.refreshCompleted();
    setState(() {});
  }

  // Profile
  void showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(40.0),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.22,
            width: MediaQuery.of(context).size.width - 100,
            child: Column(
              children: [
                // Profile Pic
                WidgetCircularAnimator(
                  size: 140.0,
                  innerColor: Colors.purpleAccent, // getRandom(Colors.accents),
                  outerColor: Colors.purpleAccent, // getRandom(Colors.accents),
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900],
                      //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Image.network(
                        "https://i.pinimg.com/564x/4d/37/19/4d37191ca552a28308a1bd1b047402f1.jpg",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                // Username
                Text(
                  "Aurora User0",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //? Discvover Page
  // Discover Page Variables
  bool discoverContent = true;
  bool isDiscoverContentLoading = false;
  TextEditingController discoverTermController = TextEditingController();
  Map dictionary = {};
  dynamic meaning = null;
  String searchedTerm = "";
  bool showMeaning = false;
  // Discover Page Functions
  // Get Disctionary Dataset
  void getDictionaryJSON() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/datasets/dictionary_alpha_arrays.json");
    List jsonResult = json.decode(data);
    dictionary = jsonResult[0];
    for (int i = 1; i < jsonResult.length; i++) {
      dictionary.addAll(jsonResult[i]);
    }
  }

  // Search meaning of word
  void searchOfflineDictionary(searchedWord) {
    // Look up meaning
    meaning = dictionary[searchedWord.toString()];
    // Handle errors
    if ((searchedWord.toString() == "") || searchedWord.toString() == null) {
      searchedTerm = "Empty Search";
      meaning = "Please type a word to search for it's meaning!";
    }
    if (meaning == null) {
      meaning = "Was not found!";
    }
    showMeaning = true;
    setState(() {});
  }

  // Discover ContentSearch
  List discoverFeed = [];
  bool isDiscoverLoading = true;
  void getDiscoverContent(subreddit, sort, time) async {
    isDiscoverLoading = false;
    isDiscoverContentLoading = true;
    setState(() {});
    var url = Uri.parse("https://www.reddit.com/r/" +
        subreddit +
        "/" +
        sort +
        ".json?t=" +
        time +
        "&limit=100");
    var response = await http.get(url);
    var responseJSON = jsonDecode(response.body);
    List discoverFeedUnfiltered = responseJSON["data"]["children"];
    for (int i = 0; i < discoverFeedUnfiltered.length; i++) {
      if ((discoverFeedUnfiltered[i]["data"]["url"]
                      .toString()
                      .endsWith(".jpg") ==
                  true ||
              discoverFeedUnfiltered[i]["data"]["url"]
                  .toString()
                  .endsWith(".png")) ==
          true) {
        discoverFeed.add(discoverFeedUnfiltered[i]);
      }
    }
    //print(responseJSON["data"]["children"][1]["data"]["author_fullname"]);
    isDiscoverLoading = false;
    isDiscoverContentLoading = false;
    setState(() {});
  }

  //? GENERAL
  // Fullscreen Mode
  void setFullscreen() {
    fullScreenMode = !fullScreenMode;
    if (fullScreenMode == true) {
      isBottomBarVisible = false;
    } else {
      isBottomBarVisible = true;
    }
    // Light Mode Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Colors.grey[200],
        statusBarIconBrightness: Brightness.light,
      ),
    );
    setState(() {});
  }

  // Get Random item from a list
  dynamic getRandom(list) {
    return list[random.nextInt(list.length)];
  }

  //? PERMISSIONS
  // Check PERMISSIONS
  void checkPermissions() async {
    PermissionStatus storagePermissionStatus = await Permission.storage.status;
    if (storagePermissionStatus.isGranted == false) {
      gotSongs = false;
      setState(() {});
      //await Permission.storage.request();
    } else {
      getSongsOnDevice();
      gotSongs = true;
      setState(() {});
    }
  }

  // Ask PERMISSIONS
  void askPermissions() async {
    // Ask Storage Permissions
    PermissionStatus storagePermissionStatus = await Permission.storage.status;
    if (storagePermissionStatus.isGranted == false) {
      await Permission.storage.request();
    }
  }

  //? INIT STATE
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hideBottomNavBar();
    // HomePage INIT
    chosenSubreddit = getRandom(subredditList);
    chosenSubredditSort = getRandom(feedSortValues);
    chosenSubredditTime = getRandom(feedTimeValues);
    getHomePageFeed(chosenSubreddit, chosenSubredditSort, chosenSubredditTime);
    // Discover INIT
    getDictionaryJSON();
    // Music Player INIT
    checkPermissions();
    albumArtImage = getRandom(albumArts);
    // Crypto INIT
    getCryptoStats();
    cryptoAppBarImageIndex = random.nextInt(2);
  }

  //? Dispose
  bool playVideo = false;
  int playVideoIndex = -1;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
    assetsAudioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List pageOnRefresh = [
      getHomePageFeedRefresh,
      getSongsOnDevice,
      getSongsOnDevice,
      getCryptoStats,
      getSongsOnDevice,
      getSongsOnDevice,
    ];
    List pagesAppBarExpanded = [
      20.0,
      60.0,
      20.0,
      isCryptoPageLoadingError == true ? 200.0 : 290.0,
      20.0,
      20.0,
    ];
    List pagesAppbarFlexibleSpace = [
      // Home Page
      FlexibleSpaceBar(),
      // Discover Page
      FlexibleSpaceBar(),
      // Music Player Page
      FlexibleSpaceBar(),
      // Crypto Page
      FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: isCryptoPageLoadingError == false
              ? Image.asset(
                  cryptoAppBarImages[cryptoAppBarImageIndex],
                  fit: BoxFit.cover,
                )
              : Container(),
        ),
      ),
      // Chat Page
      FlexibleSpaceBar(),
      // Settings Page
      FlexibleSpaceBar(),
    ];
    List pagesBody = [
      // Home Page
      isFeedLoading == false
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return (homepageFeed[index]["data"]["url"]
                                      .toString()
                                      .endsWith(".jpg") ==
                                  true ||
                              homepageFeed[index]["data"]["url"]
                                  .toString()
                                  .endsWith(".png")) ==
                          true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.all(6.0),
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[400]!,
                                    blurRadius: 4.0,
                                  ),
                                ],
                                color: Colors.grey[200],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Author of content
                                  Text(
                                    homepageFeed[index]["data"]["author"]
                                        .toString()
                                        .toUpperCase(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  // Title of content
                                  Text(
                                    homepageFeed[index]["data"]["title"],
                                    textAlign: TextAlign.left,
                                  ),
                                  // Image of content
                                  Container(
                                    margin: const EdgeInsets.only(top: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          "contentViewerPage",
                                          arguments: {
                                            "image": homepageFeed[index]["data"]
                                                ["url"],
                                            "shareLink": homepageFeed[index]
                                                ["data"]["url"],
                                            "downloadingImage":
                                                downloadingImage,
                                            "downloadingImageIndex":
                                                downloadingImageIndex,
                                            "downloadingImageDone":
                                                downloadingImageDone,
                                            "index": index,
                                            "downloadImage": downloadImage,
                                          },
                                        );
                                        /*viewFeedImages(
                                        homepageFeed[index]["data"]["url"]);*/
                                      },
                                      child: Image.network(
                                          homepageFeed[index]["data"]["url"]),
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  // Subreddit title, Share and Download Buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Subreddit title
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 6.0),
                                        child: Row(
                                          children: [
                                            Icon(Ionicons.planet_outline,
                                                size: 20.0),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6.0),
                                              child: Text(
                                                homepageFeed[index]["data"]
                                                        ["subreddit"]
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  //fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Share and Download Buttons
                                      Row(
                                        children: [
                                          // Share Button
                                          IconButton(
                                            onPressed: () {
                                              String shareLink =
                                                  homepageFeed[index]["data"]
                                                      ["url"];
                                              Share.share(
                                                  'Check this out @ Aurora \n ${shareLink}');
                                            },
                                            icon: Icon(
                                              Icons.share_outlined,
                                            ),
                                          ),
                                          // Download Button
                                          downloadingImageIndex == index
                                              ? (downloadingImage == false
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        downloadingImageIndex =
                                                            index;
                                                        downloadImage(
                                                            homepageFeed[index]
                                                                    ["data"]
                                                                ["url"]);
                                                      },
                                                      icon: Icon(
                                                        downloadingImageDone ==
                                                                true
                                                            ? Icons.done
                                                            : Ionicons
                                                                .download_outline,
                                                        color:
                                                            downloadingImageDone ==
                                                                    true
                                                                ? Colors.green
                                                                : Colors.black,
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 25.0,
                                                      height: 25.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.grey[900],
                                                      ),
                                                    ))
                                              : IconButton(
                                                  onPressed: () async {
                                                    downloadingImageIndex =
                                                        index;
                                                    downloadImage(
                                                        homepageFeed[index]
                                                            ["data"]["url"]);
                                                  },
                                                  icon: Icon(
                                                    Ionicons.download_outline,
                                                  ),
                                                )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container();
                },
                childCount: homepageFeed.length,
              ),
            )
          : SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height - 150.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100.0),
                    Image.asset(
                      getRandom(content_illustrations),
                    ),
                    const SizedBox(height: 40.0),
                    CircularProgressIndicator(
                      color: Colors.grey[900],
                    ),
                  ],
                ),
              ),
            ),

      // Discover Page
      isDiscoverLoading == true
          ? SliverToBoxAdapter(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Searched Term
                    showMeaning == true
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 8.0),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Searched Term
                                Text(
                                  searchedTerm,
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Share and Copy Button
                                Row(
                                  children: [
                                    // Share Button
                                    IconButton(
                                      onPressed: () {
                                        Share.share(
                                            '> ${searchedTerm.toUpperCase()} \n\n${meaning} \n\n* Defined By Aurora!');
                                      },
                                      icon: Icon(
                                        Icons.share_outlined,
                                      ),
                                    ),
                                    // Copy Button
                                    IconButton(
                                      onPressed: () {
                                        String sharedWord = "> " +
                                            searchedTerm.toUpperCase() +
                                            "\n\n" +
                                            meaning +
                                            "\n\n" +
                                            "* Defined by Aurora!";
                                        Clipboard.setData(
                                          ClipboardData(text: "sharedWord"),
                                        ).then(
                                          (_) {
                                            CherryToast.success(
                                              title: "Copied to clipboard",
                                              autoDismiss: true,
                                              animationDuration:
                                                  Duration(milliseconds: 800),
                                            ).show(context);
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.copy,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    // Searched Term Meaning
                    showMeaning == true
                        ? Container(
                            padding: const EdgeInsets.all(15.0),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              meaning,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          )
                        : Center(
                            child: Image.asset(
                              getRandom(search_illustrations),
                            ),
                          ),
                    const SizedBox(height: 200.0),
                  ],
                ),
              ),
            )
          : isDiscoverContentLoading == false
              ? SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: GridView.count(
                      primary: false,
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: List.generate(
                        discoverFeed.length,
                        (index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "contentViewerPage",
                                arguments: {
                                  "image": discoverFeed[index]["data"]["url"],
                                  "shareLink": discoverFeed[index]["data"]
                                      ["url"],
                                  "downloadingImage": false,
                                  "downloadingImageIndex": index,
                                  "downloadingImageDone": false,
                                  "index": index,
                                  "downloadImage": downloadImage,
                                },
                              );
                            },
                            child: Container(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Image.network(
                                    discoverFeed[index]["data"]["url"]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 300.0,
                    child: Column(
                      children: [
                        Image.asset(
                          getRandom(search_illustrations),
                        ),
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

      // Music Page
      MusicPlayerPage.musicPlayer(
        context,
        flipCardController,
        gotSongs,
        musicFiles,
        lightModeWaveGradient,
        getRandom,
        empty_illustrations,
        changeAlbumArt,
        curSong,
        curPlayingSongColor,
        pausePlaySong,
        loadPlaySong,
        isSongPlaying,
        getSongsOnDevice,
        albumArtImage,
        setFullscreen,
        fullScreenMode,
        curSongDuration,
        assetsAudioPlayer,
        songPositionStreamBuilder,
        sliderStreamBuilder,
        curSongIndex,
        nextInPlaylist,
        backInPlaylist,
        playlistLoader,
      ),

      // Crypto Page
      CryptoPage.cryptoPage(
        isCryptoPageLoading,
        showCryptoDetail,
        cryptoStats,
        isCryptoPageLoadingError,
        getCryptoStats,
        getRandom,
        error_illustrations,
      ),

      // Chat Page
      SliverToBoxAdapter(
        child: Container(),
      ),

      // Settings Page
      SliverToBoxAdapter(
        child: Container(),
      ),
    ];
    List smartRefresherColor = [
      Color(0xff6C63FF),
      Color(0xff6C63FF),
      Colors.lightBlue,
      Colors.green[400],
      Color(0xff6C63FF),
      Color(0xff6C63FF),
    ];
    List pagesAppBarBottom = [
      // Home Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
      // Discover Page
      PreferredSize(
        preferredSize: Size.fromHeight(68.0), // here the desired height
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            children: [
              // Content or Dictionary
              GestureDetector(
                onTap: () {
                  discoverContent = !discoverContent;
                  if (discoverContent == true) {
                    showMeaning = false;
                  }
                  setState(() {});
                },
                child: Icon(discoverContent == true
                    ? Ionicons.compass_outline
                    : Icons.menu_book_rounded),
              ),
              const SizedBox(width: 10.0),
              // Search Term
              Expanded(
                child: TextField(
                  controller: discoverTermController,
                  decoration: InputDecoration(
                    hintText: "Search",
                  ),
                ),
              ),
              // Search Button
              GestureDetector(
                onTap: () {
                  if (discoverContent == false) {
                    searchedTerm =
                        discoverTermController.text.toString().trim();
                    searchOfflineDictionary(searchedTerm);
                  } else {
                    getDiscoverContent(
                        discoverTermController.text.toString().trim(),
                        "top",
                        "all");
                  }
                },
                child: Icon(
                  Icons.search,
                ),
              ),
            ],
          ),
        ),
      ),
      // Music Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
      // Crypto Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
      // Chat Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
      // Setting Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[200],
      // B O D Y
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: pageOnRefresh[curPage],
        header: WaterDropMaterialHeader(
          backgroundColor: smartRefresherColor[curPage],
        ),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // App Bar
            fullScreenMode == false
                ? SliverAppBar(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    expandedHeight: pagesAppBarExpanded[curPage],
                    pinned: true,
                    title: Row(
                      children: const [
                        Icon(
                          Ionicons.planet_outline,
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          "AURORA",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    flexibleSpace: pagesAppbarFlexibleSpace[curPage],
                    bottom: pagesAppBarBottom[curPage],
                    actions: [
                      curPage == 0
                          ? Row(
                              children: [
                                // Random Feed
                                IconButton(
                                  onPressed: () {
                                    chosenSubreddit = getRandom(subredditList);
                                    chosenSubredditSort =
                                        getRandom(feedSortValues);
                                    chosenSubredditTime =
                                        getRandom(feedTimeValues);
                                    getHomePageFeed(
                                        getRandom(subredditList),
                                        chosenSubredditSort,
                                        chosenSubredditTime);
                                  },
                                  icon: Icon(Icons.shuffle),
                                ),
                                // Search Subreddit
                                IconButton(
                                  onPressed: () {
                                    feedChoice();
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            )
                          : Container(),
                      // Profile
                      Container(
                        width: 45.0,
                        height: 45.0,
                        margin: const EdgeInsets.only(right: 10.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: UserProfileAvatar(
                            avatarUrl:
                                'https://i.pinimg.com/564x/4d/37/19/4d37191ca552a28308a1bd1b047402f1.jpg',
                            onAvatarTap: () {
                              showProfileDialog();
                            },
                            notificationCount: 4,
                            notificationBubbleTextStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            avatarSplashColor: smartRefresherColor[0],
                            radius: 20,
                            isActivityIndicatorSmall: false,
                            avatarBorderData: AvatarBorderData(
                              borderColor: Colors.white,
                              borderWidth: 1.0,
                            ),
                          ),
                        ),
                      )

                      /*IconButton(
                        onPressed: () {
                          showProfileDialog();
                        },
                        icon: const Icon(
                          Ionicons.person_outline,
                          size: 20.0,
                        ),
                      ),*/
                    ],
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      color: fullScreenMode == true
                          ? Colors.grey[300]!
                          : Colors.grey[200]!,
                      //height: pagesAppBarExpanded[curPage] + 78.5,
                    ),
                  ),

            // Body + Content
            pagesBody[curPage],
          ],
        ),
      ),
      // B O T T O M  N A V  B A R
      bottomNavigationBar: isBottomBarVisible == true
          ? DotNavigationBar(
              backgroundColor: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500]!,
                  //offset: Offset(1.0, 1.0),
                  //spreadRadius: 0.8,
                  blurRadius: 1.0,
                ),
              ],
              paddingR: const EdgeInsets.all(2.0),
              marginR:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              currentIndex: curPage,
              onTap: (index) {
                curPage = index;
                setState(() {});
              },
              items: [
                // Home
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.planet_outline),
                  selectedColor: Color(0xff6C63FF),
                ),

                // Search / Discover
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.compass_outline),
                  selectedColor: Colors.purple,
                ),

                // Music
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.play_outline),
                  selectedColor: Colors.lightBlue,
                ),

                // Crypto
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.wallet_outline),
                  selectedColor: Colors.green[500],
                ),

                // chat
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.paper_plane_outline),
                  selectedColor: Colors.teal,
                ),

                // Settings
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.hardware_chip_outline),
                  selectedColor: Colors.teal,
                ),
              ],
            )
          : Container(),
    );
  }
}
