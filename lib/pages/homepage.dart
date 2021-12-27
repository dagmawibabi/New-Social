import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:animate_icons/animate_icons.dart';
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
import 'package:marquee/marquee.dart';
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
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
    if (hideBottomNav == true) {
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
      scrollController.addListener(
        () {
          // Show on scroll down
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            setState(() {
              isBottomBarVisible = true;
            });
          }
          // Show on scroll up
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            setState(() {
              isBottomBarVisible = true;
            });
          }
        },
      );
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
              color: containerColor, //Colors.grey[300],
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
                      style: TextStyle(
                        fontSize: 20.0,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      cryptoStats[index]["symbol"].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.bold,
                        color: textColorDim,
                      ),
                    ),
                  ],
                ),
                Divider(color: textColorDimmer),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColorDim,
                                ),
                              ),
                              Text(cryptoDetails[index]["value"],
                                  style: TextStyle(
                                    color: textColorDimmer,
                                  )),
                            ],
                          ),
                          SizedBox(height: 2.0),
                          Divider(
                            color: textColorDimmer,
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
                  style: TextStyle(
                    fontSize: 12.0,
                    color: textColorDimmer,
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
        //nextInPlaylist();
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
              activeColor: iconColor,
              inactiveColor: Colors.grey[600], //Color(0xaa6C63FF),
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
              style: TextStyle(
                color: textColor,
              ),
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

  // Music Bottom Sheet
  void musicListBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: containerColor,
          height: MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            children: [
              // Wave
              Container(
                height: 2.0,
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: lightModeWaveGradient,
                    durations: [35000, 19440, 10800, 6000],
                    heightPercentages: [0.20, 0.23, 0.25, 0.30],
                    blur: const MaskFilter.blur(BlurStyle.solid, 10),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  duration: 1000,
                  waveAmplitude: 2,
                  heightPercentange: 0.1,
                  size: const Size(
                    double.infinity,
                    double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Controlls
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: feedCardsColor,
                  boxShadow: [
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pause/Play and Rewind/Forward
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Repeat Button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.repeat,
                            color: iconColor,
                            size: 24.0,
                          ),
                        ),
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
                              Navigator.pop(context);
                              backInPlaylist();
                            },
                            icon: Icon(
                              Icons.fast_rewind_rounded,
                              color: iconColor,
                              size: 34.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // Pause Play
                        IconButton(
                          icon: Icon(
                            isSongPlaying ? Icons.pause : Icons.play_arrow,
                            color: iconColor,
                            size: 38.0,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            pausePlaySong();
                          },
                        ),
                        const SizedBox(width: 10.0),
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
                              Navigator.pop(context);
                              nextInPlaylist();
                            },
                            icon: Icon(
                              Icons.fast_forward_rounded,
                              color: iconColor,
                              size: 34.0,
                            ),
                          ),
                        ),
                        // Shuffle Button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.shuffle,
                            color: iconColor,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                    // Slider and Music Positions
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Current Song Position and Duration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            songPositionStreamBuilder(),
                            Text(
                              (curSongDuration.inSeconds ~/ 3600)
                                      .toString()
                                      .padLeft(2, '0') +
                                  ":" +
                                  ((curSongDuration.inSeconds ~/ 60).toInt())
                                      .toString()
                                      .padLeft(2, '0') +
                                  ":" +
                                  ((curSongDuration.inSeconds % 60).toInt())
                                      .toString()
                                      .padLeft(2, "0"),
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        // Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: sliderStreamBuilder(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),

              // Indie Songs
              Expanded(
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: musicFiles.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        // Music note icon and Song Titles
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            curSongIndex = index;
                            if ((curSong ==
                                    p.withoutExtension(p.basename(
                                        musicFiles[index].toString()))) ==
                                true) {
                              pausePlaySong();
                            } else {
                              playlistLoader(index);
                            }
                          },
                          // Music note Icon and Song Title
                          child: Container(
                            decoration: BoxDecoration(
                              color: curSong ==
                                      p.withoutExtension(p.basename(
                                          musicFiles[index].toString()))
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              children: [
                                // Music Note Icon
                                Icon(
                                  Icons.music_note_outlined,
                                  size: 18.0,
                                  color: curSong ==
                                          p.withoutExtension(p.basename(
                                              musicFiles[index].toString()))
                                      ? curPlayingSongColor
                                      : textColorDimmer,
                                ),
                                const SizedBox(width: 6.0),
                                // Song Title
                                Expanded(
                                  child: Container(
                                    height: 30.0,
                                    child: Marquee(
                                      text: p.basename(
                                          musicFiles[index].toString()),
                                      blankSpace: 80.0,
                                      velocity: 30.0,
                                      numberOfRounds: 3,
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: curSong ==
                                                p.withoutExtension(p.basename(
                                                    musicFiles[index]
                                                        .toString()))
                                            ? curPlayingSongColor
                                            : textColorDimmer,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: textColorDimmer,
                          indent: 5.0,
                          endIndent: 5.0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
    "sketchPad",
    "illustration",
    "artProgressPics",
    "pixelArt",
    "logoDesign",
    "typography",
    "humansForScale",
    "imaginaryCharacters",
    "imaginaryCityscapes",
    "imaginaryCyberpunk",
    "art",
    "artefactPorn",
    "quotesPorn",
    "aww",
    "movies",
    "earthPorn",
    "food",
    "mildlyInteresting",
    "space",
    "campingAndHiking",
    "100YearsAgo",
    "awwducational",
    "cozyPlaces",
    "programmingHumor",
    "getMotivated",
    "nostalgia",
    "designPorn",
    "cringePics",
    "creepy",
    "historyPorn",
    "verticalWallpapers",
    "militaryPorn",
    "skyPorn",
    "abandonedPorn",
    "noTitle",
    "iTookAPicture",
    "roomPorn",
    "me_IRL"
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
            // Feeling Lucky
            ElevatedButton(
              onPressed: () {
                chosenSubreddit = getRandom(subredditList);
                feedSearch.text = chosenSubreddit;
                chosenSubredditSort = getRandom(feedSortValues);
                //feedSortValue = chosenSubredditSort;
                chosenSubredditTime = getRandom(feedTimeValues);
                //feedTimeValue = chosenSubredditTime;
                getHomePageFeed(
                    chosenSubreddit, chosenSubredditSort, chosenSubredditTime);
                setState(() {});
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shuffle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    "Random",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.cyan, //Color(0xff6C63FF),
                  /*getRandom(Colors
                      .primaries),*/ //  Colors.teal[700], //deepPurple[800],
                ),
              ),
            ),
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

  Map abcdg = {};
  // Filter Content
  dynamic filterContent(dynamic contentObj) {
    //print(contentObj["data"]["is_self"] == true);
    if (contentObj["data"]["is_self"] == true) {
      return Text("TEXT: " + contentObj["data"]["title"].toString());
    } else {
      try {
        _controller = VideoPlayerController.network(contentObj["data"]
            ["preview"]["reddit_video_preview"]["fallback_url"])
          ..initialize().then((_) {
            setState(() {});
          });
        if (contentObj["data"]["preview"]["reddit_video_preview"]
                ["fallback_url"]
            .toString()
            .endsWith(".mp4")) {
          return Container(
            color: Colors.red,
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: 400.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: Image.network(
                    contentObj["data"]["thumbnail"],
                    height: 200.0,
                    width: 300.0,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "VideoViewerPage",
                      arguments: {
                        "video": contentObj["data"]["preview"]
                            ["reddit_video_preview"]["fallback_url"],
                        "thumbnail": contentObj["data"]["thumbnail"],
                      },
                    );
                  },
                  icon: Icon(
                    Icons.play_circle_fill_outlined,
                    size: 34.0,
                  ),
                ),
              ],
            ),
          );
        }
        /*return Text("VIDEO: " +
            contentObj["data"]["preview"]["reddit_video_preview"]
                ["fallback_url"]);*/
      } catch (e) {
        try {
          if (contentObj["data"]["url"].toString().endsWith(".png") ||
              contentObj["data"]["url"].toString().endsWith(".jpg") ||
              contentObj["data"]["url"].toString().endsWith(".gif") ||
              contentObj["data"]["url"].toString().endsWith(".webp") ||
              contentObj["data"]["url"].toString().endsWith(".bmp") ||
              contentObj["data"]["url"].toString().endsWith(".wbmp")) {
            return Image.network(contentObj["data"]["url"]);
          }
        } catch (e) {
          return Text("DONNOW");
        }
      }
      /*if (Map.from((contentObj["data"]["preview"]))
          .containsKey("reddit_video_preview")) {
        return Text("VIDEO: " + contentObj["title"]);
      } else {
        return Text("IMAGE: " + contentObj["title"]);
      }*/
    }
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
        animationDuration: Duration(milliseconds: 200),
        toastDuration: Duration(milliseconds: 1000),
      ).show(context);
    } catch (error) {
      // Success
      CherryToast.error(
        title: "Downloading Failed!",
        titleStyle: TextStyle(fontSize: 16.0),
        autoDismiss: true,
        animationDuration: Duration(milliseconds: 200),
        toastDuration: Duration(milliseconds: 1000),
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

  //! New
  AnimateIconController aIC_feed = AnimateIconController();
  AnimateIconController aIC_discover = AnimateIconController();
  AnimateIconController aIC_musicPlayer = AnimateIconController();
  AnimateIconController aIC_wallet = AnimateIconController();
  AnimateIconController aIC_chat = AnimateIconController();
  AnimateIconController aIC_settings = AnimateIconController();
  late dynamic abc;
  bool isDarkMode = false;
  Color scaffoldBGColor = Colors.grey[200]!;
  Color appBarBGColor = Colors.grey[200]!;
  Color textColor = Colors.black;
  Color textColorDim = Colors.grey[900]!;
  Color textColorDimmer = Colors.grey[900]!;
  Color iconColor = Colors.black;
  Color containerColor = Colors.grey[200]!;
  Color feedCardsColor = Colors.grey[200]!;
  Color feedCardShadow = Colors.grey[400]!;
  Color bottomNavBarColor = Colors.grey[200]!;
  bool hideBottomNav = false;

  //? GENERAL
  // Dark Mode
  void setDarkMode() {
    // Dark Mode Colors
    if (isDarkMode == true) {
      scaffoldBGColor = Colors.grey[900]!;
      appBarBGColor = Colors.grey[900]!;
      textColor = Colors.grey[200]!;
      textColorDim = Colors.grey[400]!;
      textColorDimmer = Colors.grey[500]!;
      iconColor = Colors.grey[200]!;
      containerColor = Colors.grey[900]!;
      feedCardsColor = Colors.grey[900]!;
      feedCardShadow = Colors.grey[800]!;
      bottomNavBarColor = Colors.grey[900]!;
      content_illustrations = [
        "assets/images/content_illustrations/11.png",
        "assets/images/content_illustrations/22.png",
        "assets/images/content_illustrations/33.png",
        "assets/images/content_illustrations/44.png",
        "assets/images/content_illustrations/55.png",
      ];
      cryptoAppBarImages = [
        "assets/images/appbar_headers/11.png",
        "assets/images/appbar_headers/22.png",
        "assets/images/appbar_headers/33.png",
      ];
      empty_illustrations = [
        "assets/images/empty_illustrations/11.png",
        "assets/images/empty_illustrations/22.png",
        "assets/images/empty_illustrations/33.png",
        "assets/images/empty_illustrations/44.png",
        "assets/images/empty_illustrations/55.png",
      ];
      error_illustrations = [
        "assets/images/error_illustrations/33.png",
        "assets/images/empty_illustrations/22.png",
        "assets/images/empty_illustrations/33.png",
      ];
      search_illustrations = [
        "assets/images/search_illustrations/11.png",
        "assets/images/search_illustrations/22.png",
        "assets/images/search_illustrations/33.png",
        "assets/images/search_illustrations/44.png",
        "assets/images/search_illustrations/55.png",
        "assets/images/search_illustrations/66.png",
      ];
    }
    // Light Mode Colors
    else {
      scaffoldBGColor = Colors.grey[200]!;
      appBarBGColor = Colors.grey[200]!;
      textColor = Colors.black;
      textColorDim = Colors.grey[800]!;
      textColorDimmer = Colors.grey[900]!;
      iconColor = Colors.black;
      containerColor = Colors.grey[200]!;
      feedCardsColor = Colors.grey[200]!;
      feedCardShadow = Colors.grey[400]!;
      bottomNavBarColor = Colors.grey[200]!;
      content_illustrations = [
        "assets/images/content_illustrations/1.png",
        "assets/images/content_illustrations/2.png",
        "assets/images/content_illustrations/3.png",
        "assets/images/content_illustrations/4.png",
        "assets/images/content_illustrations/2.png",
      ];
      cryptoAppBarImages = [
        "assets/images/appbar_headers/1.png",
        "assets/images/appbar_headers/2.png",
        "assets/images/appbar_headers/3.png",
      ];
      empty_illustrations = [
        "assets/images/empty_illustrations/1.png",
        "assets/images/empty_illustrations/2.png",
        "assets/images/empty_illustrations/3.png",
        "assets/images/empty_illustrations/4.png",
        "assets/images/empty_illustrations/5.png",
      ];
      error_illustrations = [
        "assets/images/error_illustrations/3.png",
        "assets/images/empty_illustrations/2.png",
        "assets/images/empty_illustrations/3.png",
      ];
      search_illustrations = [
        "assets/images/search_illustrations/1.png",
        "assets/images/search_illustrations/2.png",
        "assets/images/search_illustrations/3.png",
        "assets/images/search_illustrations/4.png",
        "assets/images/search_illustrations/5.png",
        "assets/images/search_illustrations/6.png",
      ];
    }
  }

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
    //hideBottomNavBar();
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
    abc = this;
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
      isSongPlaying == true ? 110.0 : 20.0,
      60.0,
      20.0,
      isCryptoPageLoadingError == true ? 200.0 : 300.0,
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
      /*isFeedLoading == false
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return filterContent(homepageFeed[index]);
                },
                childCount: homepageFeed.length,
              ),
            )
          : SliverToBoxAdapter(
              child: Container(),
            ),*/
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
                            fullScreenMode == true
                                ? index == 0
                                    ? Container(
                                        margin: const EdgeInsets.only(
                                            top: 50.0,
                                            bottom: 10.0,
                                            right: 30.0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.fullscreen_exit,
                                            color: iconColor,
                                          ),
                                          onPressed: () {
                                            setFullscreen();
                                          },
                                        ),
                                      )
                                    : Container()
                                : Container(),
                            // Feed Card
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.all(6.0),
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: feedCardsColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: feedCardShadow,
                                    blurRadius: 4.0,
                                  ),
                                ],
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
                                      color: textColor,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  // Title of content
                                  Text(
                                    homepageFeed[index]["data"]["title"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textColorDim,
                                    ),
                                  ),
                                  // Image of content
                                  Container(
                                    //width: double.infinity,
                                    //height: 300.0,
                                    margin: const EdgeInsets.only(top: 10.0),
                                    decoration: BoxDecoration(
                                      color: containerColor,
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
                                      child: PhotoView(
                                        tightMode: true,
                                        enableRotation: true,
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.grey[200],
                                        ),
                                        imageProvider: NetworkImage(
                                            homepageFeed[index]["data"]["url"]),
                                      ),
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
                                            Icon(
                                              Ionicons.planet_outline,
                                              size: 20.0,
                                              color: iconColor,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6.0),
                                              child: Text(
                                                homepageFeed[index]["data"]
                                                        ["subreddit"]
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: textColor,
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
                                              color: iconColor,
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
                                                                : iconColor,
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 25.0,
                                                      height: 25.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: iconColor,
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
                                                    color: iconColor,
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
                      color: iconColor,
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
                              boxShadow: [
                                BoxShadow(
                                  color: feedCardShadow,
                                  blurRadius: 4.0,
                                ),
                              ],
                              color: feedCardShadow, //Colors.white,
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
                                    color: textColor,
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
                                        color: iconColor,
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
                                                  Duration(milliseconds: 200),
                                              toastDuration:
                                                  Duration(seconds: 1),
                                            ).show(context);
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.copy,
                                        color: iconColor,
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
                              boxShadow: [
                                BoxShadow(
                                  color: feedCardShadow,
                                  blurRadius: 4.0,
                                ),
                              ],
                              color: feedCardsColor, //Colors.white,
                            ),
                            child: Text(
                              meaning,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: textColor.withOpacity(0.7),
                              ),
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
                            color: iconColor,
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
        abc,
        containerColor,
        iconColor,
        textColor,
        textColorDimmer,
        isDarkMode,
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
        feedCardsColor,
        textColor,
      ),

      // Chat Page
      SliverToBoxAdapter(
        child: Container(),
      ),

      // Settings Page
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            children: [
              fullScreenMode == true
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 50.0, bottom: 10.0, right: 0.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.fullscreen_exit,
                            color: iconColor,
                          ),
                          onPressed: () {
                            setFullscreen();
                          },
                        ),
                      ),
                    )
                  : Container(),
              // DarkMode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode == false
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        "Dark Mode",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: Colors.cyan,
                    value: isDarkMode,
                    onChanged: (value) {
                      isDarkMode = value;
                      setDarkMode();
                      setState(() {});
                    },
                  ),
                ],
              ),
              Divider(color: textColorDimmer.withOpacity(0.2)),
              // Hide Bottom Nav Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        hideBottomNav == true
                            ? Icons.highlight_off_rounded
                            : Icons.navigation_outlined,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        "Hide Nav-Bar on Scroll",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: Colors.cyan,
                    value: hideBottomNav,
                    onChanged: (value) {
                      hideBottomNav = value;
                      hideBottomNavBar();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
    List smartRefresherColor = [
      Color(0xff6C63FF),
      Color(0xff6C63FF),
      Colors.lightBlue,
      Colors.green[400],
      Color(0xff6C63FF),
      Colors.cyan[800],
    ];
    List pagesAppBarBottom = [
      // Home Page
      PreferredSize(
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
                            child: Marquee(
                              text: curSong,
                              blankSpace: 40.0,
                              pauseAfterRound: Duration(milliseconds: 1500),
                              velocity: 10.0,
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            /*Text(
                              curSong,
                              maxLines: 1,
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),*/
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
      // Discover Page
      PreferredSize(
        preferredSize: Size.fromHeight(
            isSongPlaying == true ? 120.0 : 68.0), // here the desired height
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: textColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              height: 50.0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
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
                    child: Icon(
                      discoverContent == true
                          ? Ionicons.compass_outline
                          : Icons.menu_book_rounded,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Search Term
                  Expanded(
                    child: TextField(
                      controller: discoverTermController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: textColor,
                        ),
                      ),
                      style: TextStyle(
                        color: textColor,
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
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
            isSongPlaying == true
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
                        Row(
                          children: [
                            Icon(
                              Icons.music_note_outlined,
                              color: iconColor,
                            ),
                            const SizedBox(width: 8.0),
                            SizedBox(
                              width: 180.0,
                              height: 20.0,
                              child: Marquee(
                                text: curSong,
                                blankSpace: 40.0,
                                pauseAfterRound: Duration(milliseconds: 1500),
                                velocity: 10.0,
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                              /*Text(
                            curSong,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),*/
                            ),
                          ],
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
          ],
        ),
      ),
      // Music Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
      // Crypto Page
      PreferredSize(
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
                    Row(
                      children: [
                        Icon(
                          Icons.music_note_outlined,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 180.0,
                          height: 20.0,
                          child: Marquee(
                            text: curSong,
                            blankSpace: 40.0,
                            pauseAfterRound: Duration(milliseconds: 1500),
                            velocity: 10.0,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          /*Text(
                            curSong,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),*/
                        ),
                      ],
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
      // Chat Page
      PreferredSize(
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
                    Row(
                      children: [
                        Icon(
                          Icons.music_note_outlined,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 180.0,
                          height: 20.0,
                          child: Marquee(
                            text: curSong,
                            blankSpace: 40.0,
                            pauseAfterRound: Duration(milliseconds: 1500),
                            velocity: 10.0,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          /*Text(
                            curSong,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),*/
                        ),
                      ],
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
      // Setting Page
      PreferredSize(
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
                    Row(
                      children: [
                        Icon(
                          Icons.music_note_outlined,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 180.0,
                          height: 20.0,
                          child: Marquee(
                            text: curSong,
                            blankSpace: 40.0,
                            pauseAfterRound: Duration(milliseconds: 1500),
                            velocity: 10.0,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          /*Text(
                            curSong,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),*/
                        ),
                      ],
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
    ];
    List pagesAppBarIconTitle = [
      {
        "icon": Ionicons.planet_outline,
        "title": "Aurora",
      },
      {
        "icon": Ionicons.compass_outline,
        "title": "Discover",
      },
      {
        "icon": Ionicons.play_outline,
        "title": "Music",
      },
      {
        "icon": Ionicons.wallet_outline,
        "title": "Wallet",
      },
      {
        "icon": Ionicons.paper_plane_outline,
        "title": "Chat",
      },
      {
        "icon": Ionicons.hardware_chip_outline,
        "title": "Settings",
      },
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: scaffoldBGColor,
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
                    backgroundColor: appBarBGColor,
                    foregroundColor: Colors.black,
                    expandedHeight: pagesAppBarExpanded[curPage],
                    pinned: true,
                    title: Row(
                      children: [
                        Icon(
                          pagesAppBarIconTitle[curPage]["icon"],
                          color: iconColor,
                        ),
                        /*Icon(
                          Ionicons.planet_outline,
                          color: iconColor,
                        ),*/
                        SizedBox(width: 12.0),
                        Text(
                          pagesAppBarIconTitle[curPage]["title"],
                          style: TextStyle(
                            color: textColor,
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
                                    setFullscreen();
                                  },
                                  icon: Icon(
                                    Icons.fullscreen,
                                    color: iconColor,
                                  ),
                                ),
                                // Search Subreddit
                                IconButton(
                                  onPressed: () {
                                    feedChoice();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: iconColor,
                                  ),
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
              backgroundColor: bottomNavBarColor,
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
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              currentIndex: curPage,
              itemPadding: EdgeInsets.all(0.0),
              margin: EdgeInsets.all(0.0),
              onTap: (index) {
                curPage = index;
                setState(() {});
              },
              items: [
                // Home
                DotNavigationBarItem(
                  icon: AnimateIcons(
                    startIcon: Ionicons.planet_outline,
                    endIcon: Ionicons.sparkles_outline,
                    size: 22.0,
                    controller: aIC_feed,
                    onStartIconPress: () {
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      curPage = 0;
                      setState(() {});
                      return true;
                    },
                    onEndIconPress: () {
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      return true;
                    },
                    duration: Duration(milliseconds: 300),
                    startIconColor: iconColor,
                    endIconColor: Color(0x886C63FF),
                    clockwise: false,
                  ),
                  selectedColor: bottomNavBarColor,
                ),
                /* DotNavigationBarItem(
                  icon: const Icon(Ionicons.planet_outline),
                  selectedColor: Color(0xff6C63FF),
                ),*/

                // Search / Discover
                DotNavigationBarItem(
                  icon: AnimateIcons(
                    startIcon: Ionicons.compass_outline,
                    endIcon: Ionicons.compass_outline,
                    size: 24.0,
                    controller: aIC_discover,
                    onStartIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      curPage = 1;
                      setState(() {});
                      return true;
                    },
                    onEndIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      return true;
                    },
                    duration: Duration(milliseconds: 300),
                    startIconColor: iconColor,
                    endIconColor: Colors.purple,
                    clockwise: false,
                  ),
                  selectedColor: bottomNavBarColor,
                ),
                /*DotNavigationBarItem(
                  icon: const Icon(Ionicons.compass_outline),
                  selectedColor: Colors.purple,
                ),*/

                // Music
                DotNavigationBarItem(
                  icon: AnimateIcons(
                    startIcon: Ionicons.play_outline,
                    endIcon: Ionicons.musical_notes_outline,
                    size: 24.0,
                    controller: aIC_musicPlayer,
                    onStartIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      curPage = 2;
                      setState(() {});
                      return true;
                    },
                    onEndIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      return true;
                    },
                    duration: Duration(milliseconds: 300),
                    startIconColor: iconColor,
                    endIconColor: Colors.lightBlue,
                    clockwise: false,
                  ),
                  selectedColor: bottomNavBarColor,
                ),
                /*DotNavigationBarItem(
                  icon: const Icon(Ionicons.play_outline),
                  selectedColor: Colors.lightBlue,
                ),*/

                // Crypto
                DotNavigationBarItem(
                  icon: AnimateIcons(
                    startIcon: Ionicons.wallet_outline,
                    endIcon: Ionicons.cash_outline,
                    size: 24.0,
                    controller: aIC_wallet,
                    onStartIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      curPage = 3;
                      setState(() {});
                      return true;
                    },
                    onEndIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_chat.animateToStart();
                      aIC_settings.animateToStart();
                      return true;
                    },
                    duration: Duration(milliseconds: 300),
                    startIconColor: iconColor,
                    endIconColor: Colors.green[500],
                    clockwise: false,
                  ),
                  selectedColor: bottomNavBarColor,
                ),
                /*DotNavigationBarItem(
                  icon: const Icon(Ionicons.wallet_outline),
                  selectedColor: Colors.green[500],
                ),*/

                // chat
                DotNavigationBarItem(
                  icon: AnimateIcons(
                    startIcon: Ionicons.paper_plane_outline,
                    endIcon: Ionicons.chatbubble_ellipses_outline,
                    size: 24.0,
                    controller: aIC_chat,
                    onStartIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_settings.animateToStart();
                      curPage = 4;
                      setState(() {});
                      return true;
                    },
                    onEndIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_settings.animateToStart();
                      curPage = 4;
                      return true;
                    },
                    duration: Duration(milliseconds: 300),
                    startIconColor: iconColor,
                    endIconColor: Colors.teal,
                    clockwise: false,
                  ),
                  selectedColor: bottomNavBarColor,
                ),
                /*DotNavigationBarItem(
                  icon: const Icon(Ionicons.paper_plane_outline),
                  selectedColor: Colors.teal,
                ),*/

                // Settings
                DotNavigationBarItem(
                  icon: AnimateIcons(
                    startIcon: Ionicons.hardware_chip_outline,
                    endIcon: Ionicons.hardware_chip_outline,
                    size: 24.0,
                    controller: aIC_settings,
                    onStartIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      curPage = 5;
                      setState(() {});
                      return true;
                    },
                    onEndIconPress: () {
                      aIC_feed.animateToStart();
                      aIC_discover.animateToStart();
                      aIC_musicPlayer.animateToStart();
                      aIC_wallet.animateToStart();
                      aIC_chat.animateToStart();
                      return true;
                    },
                    duration: Duration(milliseconds: 300),
                    startIconColor: iconColor,
                    endIconColor: Colors.cyan,
                    clockwise: false,
                  ),
                  selectedColor: bottomNavBarColor,
                ),

                /*DotNavigationBarItem(
                  icon: const Icon(Ionicons.hardware_chip_outline),
                  selectedColor: Colors.teal,
                ),*/
              ],
            )
          : Container(),
    );
  }
}
