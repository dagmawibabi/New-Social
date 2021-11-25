import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:newsocial/pages/cryptopage.dart';
import 'package:newsocial/pages/musicplayerpage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

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

  // Function to hide the bottom nav bar on scroll
  void hideBottomNavBar() {
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
  Duration curSongDuration = const Duration(seconds: 0);
  dynamic curSongPosition = "";

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
      /*Playlist(
        audios: musicFilesPlaylist,
      ),
      loopMode: LoopMode.playlist,*/ //loop the full playlist
      Audio.file(songPath),
      showNotification: true,
      notificationSettings: NotificationSettings(
        customPlayPauseAction: (player) {
          pausePlaySong();
        },
        customNextAction: (player) {
          print("next");
        },
      ),
    );
    // Play From Playlist
    //assetsAudioPlayer.playlistPlayAtIndex(musicFiles.indexOf(songPath));

    assetsAudioPlayer.current.listen(
      (playingAudio) {
        curSongDuration = playingAudio!.audio.duration;
        setState(() {});
      },
    );
    assetsAudioPlayer.playlistAudioFinished.listen(
      (Playing playing) {
        isSongPlaying = false;
        assetsAudioPlayer.stop();
        setState(() {});
      },
    );
    curSong = p.withoutExtension(p.basename(songPath));
    isSongPlaying = true;
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
  TextEditingController feedSearch = TextEditingController();
  // Custom Feed
  void feedChoice() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Enter Custom Feed",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: feedSearch,
                ),
                IconButton(
                  onPressed: () {
                    getHomePageFeed(feedSearch.text.trim(), "top", "all");
                    setState(() {});
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
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

  //? ASK PERMISSIONS
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
    // Crypto INIT
    getCryptoStats();
    cryptoAppBarImageIndex = random.nextInt(2);
    // Music INIT
    albumArtImage = getRandom(albumArts);
    // HomePage INIT
    //startVid("https://v.redd.it/1exrjvwshr081/DASH_1080.mp4");
    getHomePageFeed("wholesomememes", "top", "all");
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
      getSongsOnDevice,
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
      SliverList(
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
                          /*border: Border.all(
                            color: Colors.black,
                          ),*/
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
                                          ["url"]
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
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    String shareLink =
                                        homepageFeed[index]["data"]["url"];
                                    Share.share(
                                        'Check this out \n ${shareLink}');
                                  },
                                  icon: Icon(
                                    Icons.share_outlined,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    /*var imageId =
                                        await ImageDownloader.downloadImage(
                                            homepageFeed[index]["data"]
                                                ["title"]);*/
                                  },
                                  icon: Icon(
                                    Ionicons.download_outline,
                                  ),
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
      ),

      // Discover Page
      SliverToBoxAdapter(
        child: Container(),
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
      Color(0xff6C63FF),
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
              Icon(Ionicons.compass_outline),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Search",
                  ),
                ),
              ),
              Icon(Icons.search),
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
                          ? IconButton(
                              onPressed: () {
                                feedChoice();
                              },
                              icon: Icon(Icons.add),
                            )
                          : Container(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Ionicons.person_outline,
                          size: 20.0,
                        ),
                      ),
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
            /*SliverAppBar(
                    backgroundColor: fullScreenMode == true
                        ? Colors.grey[300]!
                        : Colors.grey[200]!,
                    foregroundColor: Colors.black,
                    expandedHeight: pagesAppBarExpanded[curPage],
                    flexibleSpace: pagesAppbarFlexibleSpace[curPage],
                  ),*/
            // Body + Content
            pagesBody[curPage],
            // Space Below
            /*const SliverToBoxAdapter(
              child: SizedBox(height: 200.0),
            ),*/
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
                  selectedColor: Colors.purple,
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
                  selectedColor: Color(0xff6C63FF),
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
