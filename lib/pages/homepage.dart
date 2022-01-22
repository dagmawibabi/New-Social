import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:internet_speed_test/callbacks_enum.dart';
import 'package:internet_speed_test/internet_speed_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:marquee/marquee.dart';
import 'package:newsocial/pages/cryptopage.dart';
import 'package:newsocial/pages/musicplayerpage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
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
  List chat_illustrations = [
    "assets/images/chat_illustrations/01.png",
    "assets/images/chat_illustrations/2.png",
    "assets/images/chat_illustrations/7.png",
    "assets/images/chat_illustrations/8.png",
    "assets/images/chat_illustrations/9.png",
    "assets/images/chat_illustrations/10.png",
    "assets/images/chat_illustrations/12.png",
    "assets/images/chat_illustrations/13.png",
    "assets/images/chat_illustrations/14.png",
    "assets/images/chat_illustrations/15.png",
    "assets/images/chat_illustrations/16.png",
    "assets/images/chat_illustrations/17.png",
    "assets/images/chat_illustrations/18.png",
  ];

  // Function to hide the bottom nav bar on scroll
  void hideBottomNavBar() {
    if (hideBottomNav == true || fullScreenOnScroll == true) {
      scrollController.addListener(
        () {
          // Hide on scroll down
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (isBottomBarVisible == true) {
              setState(() {
                if (hideBottomNav == true) {
                  isBottomBarVisible = false;
                }
                if (fullScreenOnScroll == true) {
                  isBottomBarVisible = false;
                  fullScreenMode = true;
                }
              });
            }
          }
          // Show on scroll up
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            if (isBottomBarVisible == false) {
              setState(() {
                if (hideBottomNav == true) {
                  isBottomBarVisible = true;
                }
                if (fullScreenOnScroll == true) {
                  isBottomBarVisible = true;
                  fullScreenMode = false;
                }
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
              if (hideBottomNav == true) {
                isBottomBarVisible = true;
              }
              if (fullScreenOnScroll == true) {
                isBottomBarVisible = true;
                fullScreenMode = false;
              }
            });
          }
          // Show on scroll up
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            setState(() {
              if (hideBottomNav == true) {
                isBottomBarVisible = true;
              }
              if (fullScreenOnScroll == true) {
                isBottomBarVisible = true;
                fullScreenMode = false;
              }
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
    //getWeather();
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
    //await askPermissions();
    musicFiles = [];
    dynamic files =
        Directory('/storage/emulated/0/Music').listSync(recursive: true);
    for (FileSystemEntity file in files) {
      if (file.path.endsWith(".mp3") == true ||
          file.path.endsWith(".m4a") == true) {
        musicFiles.add(file.path);
        musicFilesPlaylist.add(Audio(file.path));
      }
    }
    files = Directory('/storage/emulated/0/Download').listSync(recursive: true);
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

  // Repeat Songgs
  bool repeatSong = false;
  void repeatSongsMode() {
    repeatSong = !repeatSong;
    if (repeatSong == true) {
      assetsAudioPlayer.setLoopMode(LoopMode.single);
    } else {
      assetsAudioPlayer.setLoopMode(LoopMode.none);
    }
    setState(() {});
  }

  // Play Songs
  void loadPlaySong(songPath) async {
    //assetsAudioPlayer.stop();
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
        if (repeatSong == false) {
          nextInPlaylist();
        }
        //nextInPlaylist();
        /*isSongPlaying = false;
        assetsAudioPlayer.stop();
        setState(() {});*/
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

  bool marqueeMusicTitle = true;
  // Music Bottom Sheet
  void musicListBottomSheet(context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            image: DecorationImage(
              image: ExactAssetImage(albumArtImage),
              fit: BoxFit.cover,
              opacity: 0.3,
              filterQuality: FilterQuality.high,
              colorFilter: ColorFilter.srgbToLinearGamma(),
            ),
            color: modalBottomSheetColor,
          ),
          clipBehavior: Clip.hardEdge,
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              child: Column(
                children: [
                  // Wave
                  reduceAnimations == false
                      ? Container(
                          height: 3.0,
                          child: WaveWidget(
                            config: CustomConfig(
                              gradients: lightModeWaveGradient,
                              durations: [35000, 19440, 10800, 6000],
                              heightPercentages: [0.20, 0.23, 0.25, 0.30],
                              blur: const MaskFilter.blur(BlurStyle.solid, 10),
                              gradientBegin: Alignment.bottomLeft,
                              gradientEnd: Alignment.topRight,
                            ),
                            duration: 10,
                            waveAmplitude: 4,
                            heightPercentange: 0.1,
                            size: const Size(
                              double.infinity,
                              double.infinity,
                            ),
                          ),
                        )
                      : Container(
                          height: 3.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),

                  // Controlls
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 30.0),
                    decoration: BoxDecoration(
                      //color: modalBottomSheetColor.withOpacity(0.9),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
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
                                size: 35.0,
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
                                SizedBox(
                                  height: 16.0,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: songPositionStreamBuilder(),
                                  ),
                                ),
                                Text(
                                  (curSongDuration.inSeconds ~/ 3600)
                                          .toString()
                                          .padLeft(2, '0') +
                                      ":" +
                                      ((curSongDuration.inSeconds ~/ 60)
                                              .toInt())
                                          .toString()
                                          .padLeft(2, '0') +
                                      ":" +
                                      ((curSongDuration.inSeconds % 60).toInt())
                                          .toString()
                                          .padLeft(2, "0"),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                            // Slider
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: sliderStreamBuilder(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Wave
                  reduceAnimations == false
                      ? Container(
                          height: 3.0,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: WaveWidget(
                            config: CustomConfig(
                              gradients: lightModeWaveGradient,
                              durations: [35000, 19440, 10800, 6000],
                              heightPercentages: [0.20, 0.23, 0.25, 0.30],
                              blur: const MaskFilter.blur(BlurStyle.solid, 10),
                              gradientBegin: Alignment.bottomLeft,
                              gradientEnd: Alignment.topRight,
                            ),
                            duration: 10,
                            waveAmplitude: 0.1,
                            heightPercentange: 0.1,
                            size: const Size(
                              double.infinity,
                              double.infinity,
                            ),
                          ),
                        )
                      : Container(
                          height: 3.0,
                        ),

                  // Indie Songs
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(0.0),
                        ),
                        //color: modalBottomSheetColor.withOpacity(0.8),
                        color: Colors.transparent,
                      ),
                      child: Container(
                        child: ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: musicFiles.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                index == 0
                                    ? const SizedBox(height: 20.0)
                                    : Container(),
                                // Music note icon and Song Titles
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    curSongIndex = index;
                                    if ((curSong ==
                                            p.withoutExtension(p.basename(
                                                musicFiles[index]
                                                    .toString()))) ==
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.0)),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0, vertical: 5.0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 2.0),
                                    child: Row(
                                      children: [
                                        // Music Note Icon
                                        Icon(
                                          Icons.music_note_outlined,
                                          size: 18.0,
                                          color: curSong ==
                                                  p.withoutExtension(p.basename(
                                                      musicFiles[index]
                                                          .toString()))
                                              ? curPlayingSongColor
                                              : textColorDimmer,
                                        ),
                                        const SizedBox(width: 6.0),
                                        // Song Title
                                        Expanded(
                                          child: Container(
                                            height: 30.0,
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: marqueeMusicTitle == false
                                                ? Text(
                                                    p.basename(musicFiles[index]
                                                        .toString()),
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: curSong ==
                                                              p.withoutExtension(
                                                                  p.basename(musicFiles[
                                                                          index]
                                                                      .toString()))
                                                          ? curPlayingSongColor
                                                          : textColorDimmer,
                                                    ),
                                                  )
                                                : Marquee(
                                                    text: p.basename(
                                                        musicFiles[index]
                                                            .toString()),
                                                    blankSpace: 80.0,
                                                    velocity: 5.0,
                                                    numberOfRounds: 3,
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: curSong ==
                                                              p.withoutExtension(
                                                                  p.basename(musicFiles[
                                                                          index]
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
                                  height: 0.25,
                                  color: textColorDimmer.withOpacity(0.2),
                                  indent: 5.0,
                                  endIndent: 5.0,
                                ),
                                index == musicFiles.length - 1
                                    ? const SizedBox(height: 50.0)
                                    : Container(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  // Weather Details
  void weatherDetails() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                "https:" +
                    weatherData["current"]["condition"]["icon"].toString(),
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            color: modalBottomSheetColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 100.0,
              sigmaY: 100.0,
              tileMode: TileMode.mirror,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status
                Column(
                  children: [
                    // Weather Image
                    SizedBox(
                      width: 100.0,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CachedNetworkImage(
                          imageUrl: "https:" +
                              weatherData["current"]["condition"]["icon"]
                                  .toString(),
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        weatherData["current"]["condition"]["text"],
                        maxLines: 1,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Temp
                Text(
                  useMetricMesurementSystem == true
                      ? weatherData["current"]["temp_c"].toString() + "°C"
                      : weatherData["current"]["temp_f"].toString() + "°F",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 5.0),
                    Container(
                      width: 97.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "💨",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            useMetricMesurementSystem == true
                                ? weatherData["current"]["wind_kph"]
                                        .toString() +
                                    " kph \n"
                                : weatherData["current"]["wind_mph"]
                                        .toString() +
                                    " mph \n",
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Wind Speed",
                            style: TextStyle(
                              color: textColorDimmer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 97.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "💦",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 28.0,
                            ),
                          ),
                          const SizedBox(height: 14.0),
                          Text(
                            weatherData["current"]["humidity"].toString() +
                                "% \n",
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Humidity",
                            style: TextStyle(
                              color: textColorDimmer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 97.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "☁",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            weatherData["current"]["cloud"].toString() + "% \n",
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Cloud Cover",
                            style: TextStyle(
                              color: textColorDimmer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 97.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "🍃",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            useMetricMesurementSystem == true
                                ? weatherData["current"]["pressure_mb"]
                                        .toString() +
                                    " mb \n"
                                : weatherData["current"]["pressure_in"]
                                        .toString() +
                                    " in \n",
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Pressure",
                            style: TextStyle(
                              color: textColorDimmer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5.0),
                  ],
                ),
                // Location
                Column(
                  children: [
                    Text(
                      "Latitude: " +
                          weatherData["location"]["lat"].toString() +
                          ", Longitude: " +
                          weatherData["location"]["lon"].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColorDimmer,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        getWeather();
                        Navigator.pop(context);
                        weatherDetails();
                      },
                      child: Text(
                        weatherData["location"]["name"] +
                            ", " +
                            weatherData["location"]["country"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColorDimmer,
                        ),
                      ),
                    ),
                    // Space
                    const SizedBox(height: 10.0),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Weather
  bool gotWeather = false;
  dynamic weatherData = "";
  bool useMetricMesurementSystem = true;
  void getWeather() async {
    loc.Location location = await loc.Location();
    if (await Permission.location.status.isGranted == true) {
      locationData = await location.getLocation();
    } else {
      await Permission.location.request();
    }
    String latitude = locationData.latitude.toString();
    String longitude = locationData.longitude.toString();
    var url = Uri.parse(
        "http://api.weatherapi.com/v1/current.json?key=58a9b304b5ed4f82a0e135231220901&q=" +
            latitude +
            "," +
            longitude +
            "&aqi=yes");
    var response = await http.get(url);
    var responseJSON = jsonDecode(response.body);
    weatherData = responseJSON;
    gotWeather = true;
    setState(() {});
  }

  // Location
  late loc.LocationData locationData;
  void getCurrentLocation() async {
    loc.Location location = await new loc.Location();
    if (await Permission.location.status.isGranted == true) {
      locationData = await location.getLocation();
    } else {
      await Permission.location.request();
    }
  }

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
                    labelText: "Subreddit Name (noSpaces)",
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
    downloadingImage = false;
    downloadingImageDone = false;
    if (await Permission.storage.isGranted == true) {
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
    } else {
      await Permission.storage.request();
    }
    //downloadingImageIndex = -1;
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

  //? Chat Page
  int chatAppBarImageIndex = 0;
  List users = [
    {
      "username": "Bill Gates",
      "dp":
          "https://i.pinimg.com/564x/6e/b9/34/6eb9348adb10b42ce591b83b3c803f27.jpg",
      "online": false,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Elon Musk",
      "dp":
          "https://i.pinimg.com/564x/73/6c/81/736c81cb4c0a4a3f21130ed70d0b0182.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Jesus Christ",
      "dp":
          "https://i.pinimg.com/564x/b4/ad/d4/b4add4267d4578208b4faee8d399c664.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Babi Dagmawi",
      "dp":
          "https://i.pinimg.com/564x/26/c8/81/26c881f5ff55a8baf6eaa74e3166d382.jpg",
      "online": false,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Dagmawi Babi",
      "dp":
          "https://i.pinimg.com/564x/f1/6a/81/f16a8191c6e42ea15a014cbf6e411130.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Bill Gates",
      "dp":
          "https://i.pinimg.com/564x/6e/b9/34/6eb9348adb10b42ce591b83b3c803f27.jpg",
      "online": false,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Elon Musk",
      "dp":
          "https://i.pinimg.com/564x/73/6c/81/736c81cb4c0a4a3f21130ed70d0b0182.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Jesus Christ",
      "dp":
          "https://i.pinimg.com/564x/b4/ad/d4/b4add4267d4578208b4faee8d399c664.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Babi Dagmawi",
      "dp":
          "https://i.pinimg.com/564x/26/c8/81/26c881f5ff55a8baf6eaa74e3166d382.jpg",
      "online": false,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Dagmawi Babi",
      "dp":
          "https://i.pinimg.com/564x/f1/6a/81/f16a8191c6e42ea15a014cbf6e411130.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Bill Gates",
      "dp":
          "https://i.pinimg.com/564x/6e/b9/34/6eb9348adb10b42ce591b83b3c803f27.jpg",
      "online": false,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Elon Musk",
      "dp":
          "https://i.pinimg.com/564x/73/6c/81/736c81cb4c0a4a3f21130ed70d0b0182.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Jesus Christ",
      "dp":
          "https://i.pinimg.com/564x/b4/ad/d4/b4add4267d4578208b4faee8d399c664.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Babi Dagmawi",
      "dp":
          "https://i.pinimg.com/564x/26/c8/81/26c881f5ff55a8baf6eaa74e3166d382.jpg",
      "online": false,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
    {
      "username": "Dagmawi Babi",
      "dp":
          "https://i.pinimg.com/564x/f1/6a/81/f16a8191c6e42ea15a014cbf6e411130.jpg",
      "online": true,
      "chat": [
        {
          "content": "This app Rocks",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": false,
        },
        {
          "content": "So much man!",
          "date": "Dec 27",
          "time": "14:18",
          "fromMe": true,
        },
        {
          "content": "I'm happy bruh",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": false,
        },
        {
          "content": "I'm happy for you too!",
          "date": "Dec 27",
          "time": "14:19",
          "fromMe": true,
        },
      ],
    },
  ];
  List userText = [];
  int userIndex = 0;

  //! New
  bool grantedStorage = false;
  bool grantedLocation = false;
  AnimateIconController aIC_feed = AnimateIconController();
  AnimateIconController aIC_discover = AnimateIconController();
  AnimateIconController aIC_musicPlayer = AnimateIconController();
  AnimateIconController aIC_wallet = AnimateIconController();
  AnimateIconController aIC_chat = AnimateIconController();
  AnimateIconController aIC_settings = AnimateIconController();
  late dynamic abc;
  bool isDarkMode = false;
  static Color scaffoldBGColor = Colors.grey[200]!;
  static Color appBarBGColor = Colors.grey[200]!;
  static Color textColor = Colors.black;
  static Color textColorDim = Colors.grey[900]!;
  static Color textColorDimmer = Colors.grey[900]!;
  static Color iconColor = Colors.black;
  static Color containerColor = Colors.grey[200]!;
  static Color feedCardsColor = Colors.grey[200]!;
  static Color feedCardShadow = Colors.grey[400]!;
  static Color bottomNavBarColor = Colors.grey[200]!;
  static Color modalBottomSheetColor = Colors.grey[200]!;
  static Color selectedTabColor = Colors.deepPurple;
  static List<Color> cardGradient = [
    Color(0xffb3ffab),
    Color(0xff12fff7),
  ];
  bool hideBottomNav = false;

  //? Settings
  bool isNavBarFloating = true;
  bool fullScreenOnScroll = false;
  List presetThemes = [
    {
      "primaryColor": Colors.red,
      "lightTheme": {
        "iconColor": Colors.red,
        "textColor": Colors.red,
        "textColorDim": Colors.red[300]!,
        "textColorDimmer": Colors.red[100]!,
      },
      "darkTheme": {
        "iconColor": Colors.red,
        "textColor": Colors.red,
        "textColorDim": Colors.red[300]!,
        "textColorDimmer": Colors.red[100]!,
      }
    },
  ];
  bool reduceAnimations = false;
  int themeEditorOptionIndex = 0;
  List themeEditorOptions = [
    {
      "icon": Icons.bubble_chart,
      "title": "Icons",
      "color": iconColor,
    },
    {
      "icon": Icons.border_top,
      "title": "App Bar",
      "color": appBarBGColor,
    },
    {
      "icon": Icons.border_all,
      "title": "Scaffold",
      "color": scaffoldBGColor,
    },
    {
      "icon": Icons.center_focus_weak,
      "title": "Containers",
      "color": containerColor,
    },
    {
      "icon": Icons.api,
      "title": "Feed Cards",
      "color": feedCardsColor,
    },
    {
      "icon": Icons.create,
      "title": "Primary Text",
      "color": textColor,
    },
    {
      "icon": Icons.create_outlined,
      "title": "Secondary Text",
      "color": textColorDim
    },
    {
      "icon": Icons.brush_outlined,
      "title": "Tirtiary Text",
      "color": textColorDimmer,
    },
    {
      "icon": Icons.call_to_action,
      "title": "Modal Bottom Sheet",
      "color": modalBottomSheetColor,
    },
    {
      "icon": Icons.call_to_action_outlined,
      "title": "Bottom Navigation Bar",
      "color": bottomNavBarColor,
    },
  ];
  void themeEditor() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          color: modalBottomSheetColor,
          //height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            children: [
              Text(
                "Theme Editor",
                style: TextStyle(
                  color: textColor,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40.0),
              Expanded(
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: themeEditorOptions.length,
                  itemBuilder: (context, index) {
                    // Individual Options
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            themeEditorOptionIndex = index;
                            Navigator.of(context).pop();
                            themeEditorColorPicker(true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon and Option Title
                              Row(
                                children: [
                                  // Option Icon
                                  Icon(
                                    themeEditorOptions[index]["icon"],
                                    color: iconColor,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  // Option Title
                                  Text(
                                    themeEditorOptions[index]["title"],
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Current Color
                              Container(
                                width: 25.0,
                                height: 25.0,
                                margin: const EdgeInsets.only(right: 5.0),
                                decoration: BoxDecoration(
                                  color: themeEditorOptions[index]["color"],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: feedCardShadow,
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: textColorDimmer.withOpacity(0.2)),
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

  void themeEditorColorPicker(bool fromThemeEditor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: containerColor,
          title: Text(
            "Pick a color and it's opacity!",
            style: TextStyle(
              color: textColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: containerColor,
              onColorChanged: (color) {
                themeEditorOptions[themeEditorOptionIndex]["color"] = color;
                switch (themeEditorOptionIndex) {
                  case 0:
                    iconColor = color;
                    break;
                  case 1:
                    appBarBGColor = color;
                    break;
                  case 2:
                    scaffoldBGColor = color;
                    break;
                  case 3:
                    containerColor = color;
                    break;
                  case 4:
                    feedCardsColor = color;
                    break;
                  case 5:
                    textColor = color;
                    break;
                  case 6:
                    textColorDim = color;
                    break;
                  case 7:
                    textColorDimmer = color;
                    break;
                  case 8:
                    modalBottomSheetColor = color;
                    break;
                  case 9:
                    bottomNavBarColor = color;
                    break;
                }
                setState(() {});
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
                fromThemeEditor == true ? themeEditor() : () {};
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color(0xff6C63FF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool isSpeedTesting = false;
  double downloadRate = 0.0;
  dynamic downloadUnit = "Mb/s";
  double uploadRate = 0.0;
  dynamic uploadUnit = "Mb/s";
  final internetSpeedTest = InternetSpeedTest();
  void connectionSpeedTest(int choice) async {
    isSpeedTesting = true;
    setState(() {});
    // Download Test
    if (choice == 1) {
      internetSpeedTest.startDownloadTesting(
        onDone: (double transferRate, SpeedUnit unit) {
          downloadRate = transferRate;
          downloadUnit = unit == SpeedUnit.Kbps ? "Kb/s" : "Mb/s";
          setState(() {});
        },
        onProgress: (double percent, double transferRate, SpeedUnit unit) {
          downloadRate = transferRate;
          downloadUnit = unit == SpeedUnit.Kbps ? "Kb/s" : "Mb/s";
          setState(() {});
        },
        onError: (String errorMessage, String speedTestError) {
          print('the download error rate $speedTestError');
        },
      );
    }
    // Upload Test
    else {
      internetSpeedTest.startUploadTesting(
        onDone: (double transferRate, SpeedUnit unit) {
          uploadRate = transferRate;
          uploadUnit = unit == SpeedUnit.Kbps ? "Kb/s" : "Mb/s";
          setState(() {});
        },
        onProgress: (double percent, double transferRate, SpeedUnit unit) {
          uploadRate = transferRate;
          uploadUnit = unit == SpeedUnit.Kbps ? "Kb/s" : "Mb/s";
          setState(() {});
        },
        onError: (String errorMessage, String speedTestError) {
          print('error uploading');
        },
      );
    }
  }

  //? GENERAL
  bool enableFlexibleSpace = true;

  Future<bool> backButton() async {
    if (curPage == 6) {
      curPage = 4;
      isBottomBarVisible = true;
      setState(() {});
    } else if (curPage == 7) {
      curPage = 0;
      setState(() {});
    } else {
      print("here");
    }
    return false;
  }

  // Sample Future Function Placeholder
  Future<void> sampleFuture() async {
    await Future.delayed(Duration(seconds: 3));
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

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
      modalBottomSheetColor = Colors.grey[900]!;
      cardGradient = [
        Color(0x11C85C5C),
        Color(0x112F86A6),
        Color(0x11C85C5C),
      ];
      themeEditorOptions = [
        {
          "icon": Icons.bubble_chart,
          "title": "Icons",
          "color": iconColor,
        },
        {
          "icon": Icons.border_top,
          "title": "App Bar",
          "color": appBarBGColor,
        },
        {
          "icon": Icons.border_all,
          "title": "Scaffold",
          "color": scaffoldBGColor,
        },
        {
          "icon": Icons.center_focus_weak,
          "title": "Containers",
          "color": containerColor,
        },
        {
          "icon": Icons.api,
          "title": "Feed Cards",
          "color": feedCardsColor,
        },
        {
          "icon": Icons.create,
          "title": "Primary Text",
          "color": textColor,
        },
        {
          "icon": Icons.create_outlined,
          "title": "Secondary Text",
          "color": textColorDim
        },
        {
          "icon": Icons.brush_outlined,
          "title": "Tirtiary Text",
          "color": textColorDimmer,
        },
        {
          "icon": Icons.call_to_action,
          "title": "Modal Bottom Sheet",
          "color": modalBottomSheetColor,
        },
        {
          "icon": Icons.call_to_action_outlined,
          "title": "Bottom Navigation Bar",
          "color": bottomNavBarColor,
        },
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
      modalBottomSheetColor = Colors.grey[200]!;
      cardGradient = [
        Color(0xffb3ffab),
        Color(0xff12fff7),
      ];
      themeEditorOptions = [
        {
          "icon": Icons.bubble_chart,
          "title": "Icons",
          "color": iconColor,
        },
        {
          "icon": Icons.border_top,
          "title": "App Bar",
          "color": appBarBGColor,
        },
        {
          "icon": Icons.border_all,
          "title": "Scaffold",
          "color": scaffoldBGColor,
        },
        {
          "icon": Icons.center_focus_weak,
          "title": "Containers",
          "color": containerColor,
        },
        {
          "icon": Icons.api,
          "title": "Feed Cards",
          "color": feedCardsColor,
        },
        {
          "icon": Icons.create,
          "title": "Primary Text",
          "color": textColor,
        },
        {
          "icon": Icons.create_outlined,
          "title": "Secondary Text",
          "color": textColorDim
        },
        {
          "icon": Icons.brush_outlined,
          "title": "Tirtiary Text",
          "color": textColorDimmer,
        },
        {
          "icon": Icons.call_to_action,
          "title": "Modal Bottom Sheet",
          "color": modalBottomSheetColor,
        },
        {
          "icon": Icons.call_to_action_outlined,
          "title": "Bottom Navigation Bar",
          "color": bottomNavBarColor,
        },
      ];
    }
  }

  // Fullscreen Mode
  void setFullscreen() {
    fullScreenMode = !fullScreenMode;
    fullScreenModeMP = false;
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

  // Fullscreen Mode for music player
  bool fullScreenModeMP = false;
  void setFullscreenMusicPlayer() {
    fullScreenModeMP = !fullScreenModeMP;
    if (fullScreenModeMP == true) {
      isBottomBarVisible = false;
    } else {
      isBottomBarVisible = true;
    }
    // Light Mode Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Colors.grey[200],
        statusBarIconBrightness:
            isDarkMode == true ? Brightness.dark : Brightness.light,
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
  Future<void> askPermissions() async {
    // Ask Storage Permissions
    PermissionStatus storagePermissionStatus = await Permission.storage.status;
    if (storagePermissionStatus.isGranted == false) {
      await Permission.storage.request();
      getSongsOnDevice();
    } else {
      getSongsOnDevice();
    }
    // Ask Location Permissions
    PermissionStatus locationPermissionStatus =
        await Permission.location.status;
    if (locationPermissionStatus.isGranted == false) {
      await Permission.location.request();
      getWeather();
    } else {
      getWeather();
    }
    // Ask Camera Permissions
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    if (cameraPermissionStatus.isGranted == false) {
      await Permission.camera.request();
    }
  }

  //?Cache Memory
  dynamic cacheMemorySize = 0;
  void getCacheMemorySize() async {
    var appTempDir = await getTemporaryDirectory();
    var appTempDirStats = await appTempDir.stat();
    cacheMemorySize = appTempDirStats.size;
    setState(() {});
  }

  // Check Enabled Permissions
  void checkAllPermissionStatus() async {
    if (await Permission.storage.status.isGranted == true) {
      grantedStorage = true;
    } else {
      grantedStorage = false;
    }
    if (await Permission.location.status.isGranted == true) {
      grantedLocation = true;
    } else {
      grantedLocation = false;
    }
    setState(() {});
  }

  //? INIT STATE
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //hideBottomNavBar();
    // Weather
    askPermissions();
    //getWeather();
    // HomePage INIT
    chosenSubreddit = getRandom(subredditList);
    chosenSubredditSort = getRandom(feedSortValues);
    chosenSubredditTime = getRandom(feedTimeValues);
    getHomePageFeed(chosenSubreddit, chosenSubredditSort, chosenSubredditTime);
    // Discover INIT
    getDictionaryJSON();
    // Music Player INIT
    //checkPermissions();
    //askPermissions();
    albumArtImage = getRandom(albumArts);
    // Crypto INIT
    getCryptoStats();
    cryptoAppBarImageIndex = random.nextInt(2);
    chatAppBarImageIndex = random.nextInt(chat_illustrations.length - 1);
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
    print(curPage);
    TabController tabBarController = TabController(length: 2, vsync: this);
    List extensionApps = [
      {
        "icon": Icons.menu_book_outlined,
        "title": "Reader",
        "subtitle": "PDF Reader",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.qr_code_scanner_rounded,
        "title": "QR Scanner",
        "subtitle": "QR Code Scanner",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.flash_on,
        "title": "Flash Light",
        "subtitle": "Light",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.assistant_outlined,
        "title": "AI Assistant",
        "subtitle": "Personal Assistant",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.menu_book_outlined,
        "title": "Reader",
        "subtitle": "PDF Reader",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.qr_code_scanner_rounded,
        "title": "QR Scanner",
        "subtitle": "QR Code Scanner",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.flash_on,
        "title": "Flash Light",
        "subtitle": "Light",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.assistant_outlined,
        "title": "AI Assistant",
        "subtitle": "Personal Assistant",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.menu_book_outlined,
        "title": "Reader",
        "subtitle": "PDF Reader",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.qr_code_scanner_rounded,
        "title": "QR Scanner",
        "subtitle": "QR Code Scanner",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.flash_on,
        "title": "Flash Light",
        "subtitle": "Light",
        "app": "qrScannerPage",
      },
      {
        "icon": Icons.assistant_outlined,
        "title": "AI Assistant",
        "subtitle": "Personal Assistant",
        "app": "qrScannerPage",
      },
    ];
    List pageOnRefresh = [
      getHomePageFeedRefresh,
      sampleFuture,
      getSongsOnDevice,
      getCryptoStats,
      sampleFuture,
      sampleFuture,
      sampleFuture,
      sampleFuture,
    ];
    List pagesAppBarExpanded = [
      isSongPlaying == true ? 210.0 : 200.0,
      60.0,
      20.0,
      isCryptoPageLoadingError == true ? 200.0 : 0.0, //300.0,
      280.0,
      20.0,
      20.0,
      isSongPlaying == true ? 210.0 : 200.0,
    ];
    List pagesAppbarFlexibleSpace = [
      // Home Page
      FlexibleSpaceBar(
        background: (gotWeather == true)
            ? GestureDetector(
                onTap: () {
                  weatherDetails();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  margin: const EdgeInsets.only(bottom: 30.0, top: 120.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 60.0,
                            child: CachedNetworkImage(
                                imageUrl: "https:" +
                                    weatherData["current"]["condition"]["icon"]
                                        .toString()),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    weatherData["current"]["condition"]["text"],
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ), /*
                                const SizedBox(height: 10.0),
                                Text(
                                  weatherData["location"]["name"] +
                                      "\n" +
                                      weatherData["location"]["country"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColorDimmer,
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              useMetricMesurementSystem == true
                                  ? weatherData["current"]["temp_c"]
                                          .toString() +
                                      "°C"
                                  : weatherData["current"]["temp_f"]
                                          .toString() +
                                      "°F",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 19.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.only(top: 100.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: textColor,
                  ),
                ),
              ),
      ),
      // Discover Page
      FlexibleSpaceBar(),
      // Music Player Page
      FlexibleSpaceBar(),
      // Crypto Page
      FlexibleSpaceBar(
          /*background: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: isCryptoPageLoadingError == false
              ? Image.asset(
                  cryptoAppBarImages[cryptoAppBarImageIndex],
                  fit: BoxFit.cover,
                )
              : Container(),
        ),*/
          ),
      // Chat Page
      FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Image.asset(
            chat_illustrations[chatAppBarImageIndex],
            fit: BoxFit.contain,
          ),
        ),
      ),
      // Settings Page
      FlexibleSpaceBar(),
      // DMs Page
      FlexibleSpaceBar(),
      // Home Page
      FlexibleSpaceBar(
        background: (gotWeather == true)
            ? GestureDetector(
                onTap: () {
                  weatherDetails();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  margin: const EdgeInsets.only(bottom: 30.0, top: 120.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 60.0,
                            child: CachedNetworkImage(
                                imageUrl: "https:" +
                                    weatherData["current"]["condition"]["icon"]
                                        .toString()),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    weatherData["current"]["condition"]["text"],
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ), /*
                                const SizedBox(height: 10.0),
                                Text(
                                  weatherData["location"]["name"] +
                                      "\n" +
                                      weatherData["location"]["country"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColorDimmer,
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              useMetricMesurementSystem == true
                                  ? weatherData["current"]["temp_c"]
                                          .toString() +
                                      "°C"
                                  : weatherData["current"]["temp_f"]
                                          .toString() +
                                      "°F",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 19.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.only(top: 100.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: textColor,
                  ),
                ),
              ),
      ),
    ];
    List pagesBody = [
      // Home Page
      isFeedLoading == false
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    children: [
                      (homepageFeed[index]["data"]["url"]
                                          .toString()
                                          .endsWith(".jpg") ==
                                      true ||
                                  homepageFeed[index]["data"]["url"]
                                          .toString()
                                          .endsWith(".png") ==
                                      true ||
                                  homepageFeed[index]["data"]["url"]
                                          .toString()
                                          .endsWith(".gif") ==
                                      true) ==
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
                                GestureDetector(
                                  onLongPress: () {
                                    themeEditorOptionIndex = 4;
                                    themeEditorColorPicker(false);
                                  },
                                  child: Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Author of content
                                        GestureDetector(
                                          onLongPress: () {
                                            themeEditorOptionIndex = 5;
                                            themeEditorColorPicker(false);
                                          },
                                          child: Text(
                                            homepageFeed[index]["data"]
                                                    ["author"]
                                                .toString()
                                                .toUpperCase(),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        // Title of content
                                        GestureDetector(
                                          onLongPress: () {
                                            themeEditorOptionIndex = 6;
                                            themeEditorColorPicker(false);
                                          },
                                          child: Text(
                                            homepageFeed[index]["data"]
                                                ["title"],
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textColorDim,
                                            ),
                                          ),
                                        ),
                                        // Image of content
                                        Container(
                                          //width: double.infinity,
                                          //height: 300.0,
                                          margin:
                                              const EdgeInsets.only(top: 10.0),
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
                                                  "image": homepageFeed[index]
                                                      ["data"]["url"],
                                                  "shareLink":
                                                      homepageFeed[index]
                                                          ["data"]["url"],
                                                  "downloadingImage":
                                                      downloadingImage,
                                                  "downloadingImageIndex":
                                                      downloadingImageIndex,
                                                  "downloadingImageDone":
                                                      downloadingImageDone,
                                                  "index": index,
                                                  "downloadImage":
                                                      downloadImage,
                                                },
                                              );
                                              /*viewFeedImages(
                                                homepageFeed[index]["data"]["url"]);*/
                                            },
                                            child: PhotoView(
                                              tightMode: true,
                                              enableRotation: true,
                                              backgroundDecoration:
                                                  BoxDecoration(
                                                color: Colors.grey[200],
                                              ),
                                              imageProvider: NetworkImage(
                                                  homepageFeed[index]["data"]
                                                      ["url"]),
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
                                              padding: const EdgeInsets.only(
                                                  left: 6.0),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onLongPress: () {
                                                      themeEditorOptionIndex =
                                                          0;
                                                      themeEditorColorPicker(
                                                          false);
                                                    },
                                                    child: Icon(
                                                      Ionicons.planet_outline,
                                                      size: 20.0,
                                                      color: iconColor,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6.0),
                                                    child: Text(
                                                      homepageFeed[index]
                                                                  ["data"]
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
                                                GestureDetector(
                                                  onLongPress: () {
                                                    themeEditorOptionIndex = 0;
                                                    themeEditorColorPicker(
                                                        false);
                                                  },
                                                  child: IconButton(
                                                    onPressed: () {
                                                      String shareLink =
                                                          homepageFeed[index]
                                                              ["data"]["url"];
                                                      Share.share(
                                                          'Check this out @ Aurora \n ${shareLink}');
                                                    },
                                                    icon: Icon(
                                                      Icons.share_outlined,
                                                      color: iconColor,
                                                    ),
                                                  ),
                                                ),
                                                // Download Button
                                                downloadingImageIndex == index
                                                    ? (downloadingImage == false
                                                        ? GestureDetector(
                                                            onLongPress: () {
                                                              themeEditorOptionIndex =
                                                                  0;
                                                              themeEditorColorPicker(
                                                                  false);
                                                            },
                                                            child: IconButton(
                                                              onPressed:
                                                                  () async {
                                                                downloadingImageIndex =
                                                                    index;
                                                                downloadImage(
                                                                    homepageFeed[index]
                                                                            [
                                                                            "data"]
                                                                        [
                                                                        "url"]);
                                                              },
                                                              icon: Icon(
                                                                downloadingImageDone ==
                                                                        true
                                                                    ? Icons.done
                                                                    : Ionicons
                                                                        .download_outline,
                                                                color: downloadingImageDone ==
                                                                        true
                                                                    ? Colors
                                                                        .green
                                                                    : iconColor,
                                                              ),
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
                                                              homepageFeed[
                                                                          index]
                                                                      ["data"]
                                                                  ["url"]);
                                                        },
                                                        icon: Icon(
                                                          Ionicons
                                                              .download_outline,
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
                                ),
                              ],
                            )
                          : Container()
                    ],
                  );
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
                    const SizedBox(height: 50.0),
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
        fullScreenModeMP,
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
        marqueeMusicTitle,
        scaffoldBGColor,
        askPermissions,
        reduceAnimations,
        repeatSong,
        repeatSongsMode,
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
        textColorDim,
        textColorDimmer,
        iconColor,
        cardGradient,
      ),

      // Chat Page
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  userIndex = index;
                  userText = users[index]["chat"];
                  curPage = 6;
                  isBottomBarVisible = false;
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // DP and Status
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 35.0,
                                height: 35.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[900],
                                  //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Image.network(
                                    users[index]["dp"],
                                  ),
                                ),
                              ),
                              Container(
                                width: 6.0,
                                height: 6.0,
                                margin: const EdgeInsets.only(right: 2.5),
                                decoration: BoxDecoration(
                                  //shape: BoxShape.circle,
                                  color: users[index]["online"] == true
                                      ? Colors.lightGreenAccent
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12.0),
                          // Username and text preview
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                users[index]["username"],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "abcd eftg sbkdak adad ...",
                                style: TextStyle(
                                  color: textColorDimmer.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          // OnlineOffline
                        ],
                      ),
                      Column(
                        children: [
                          // Seen Icon
                          Icon(
                            Ionicons.checkmark,
                            color: iconColor.withOpacity(0.9),
                            size: 19.0,
                          ),
                          const SizedBox(height: 5.0),
                          // Date
                          Text(
                            "Dec 27",
                            style: TextStyle(
                              color: textColorDimmer.withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(
                  color: textColorDimmer.withOpacity(0.3),
                ),
              ),
              index == users.length - 1
                  ? const SizedBox(height: 200.0)
                  : Container(),
            ],
          );
        }, childCount: users.length),
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
              // Theme
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Row(
                  children: [
                    Text(
                      "Theme",
                      style: TextStyle(
                        color: textColorDimmer.withOpacity(0.3),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // DarkMode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dark Mode",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            "Changes to a darker theme",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
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
              // Theme Editor
              ExpansionTile(
                childrenPadding: const EdgeInsets.all(0.0),
                tilePadding: const EdgeInsets.all(0.0),
                leading: Icon(
                  Icons.format_paint_outlined,
                  color: iconColor,
                ),
                subtitle: Text(
                  "Customize the theme of the app",
                  style: TextStyle(
                    color: textColorDimmer,
                    fontSize: 12.0,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                title: Text(
                  "Theme Editor",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    themeEditor();
                  },
                  child: Icon(
                    Icons.brush,
                    color: iconColor,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: scaffoldBGColor,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.red;
                                  textColor = Colors.red;
                                  textColorDim = Colors.red[300]!;
                                  textColorDimmer = Colors.red[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.deepPurple;
                                  textColor = Colors.deepPurple;
                                  textColorDim = Colors.deepPurple[300]!;
                                  textColorDimmer = Colors.deepPurple[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.lime;
                                  textColor = Colors.lime;
                                  textColorDim = Colors.lime[300]!;
                                  textColorDimmer = Colors.lime[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.lime,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.cyan;
                                  textColor = Colors.cyan;
                                  textColorDim = Colors.cyan[300]!;
                                  textColorDimmer = Colors.cyan[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.cyan,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.amber;
                                  textColor = Colors.amber;
                                  textColorDim = Colors.amber[300]!;
                                  textColorDimmer = Colors.amber[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.indigo;
                                  textColor = Colors.indigo;
                                  textColorDim = Colors.indigo[300]!;
                                  textColorDimmer = Colors.indigo[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.green;
                                  textColor = Colors.green;
                                  textColorDim = Colors.green[300]!;
                                  textColorDimmer = Colors.green[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.yellow;
                                  textColor = Colors.yellow;
                                  textColorDim = Colors.yellow[300]!;
                                  textColorDimmer = Colors.yellow[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.teal;
                                  textColor = Colors.teal;
                                  textColorDim = Colors.teal[300]!;
                                  textColorDimmer = Colors.teal[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.lightBlue;
                                  textColor = Colors.lightBlue;
                                  textColorDim = Colors.lightBlue[300]!;
                                  textColorDimmer = Colors.lightBlue[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.purple;
                                  textColor = Colors.purple;
                                  textColorDim = Colors.purple[300]!;
                                  textColorDimmer = Colors.purple[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.white;
                                  textColor = Colors.white;
                                  textColorDim = Colors.white60;
                                  textColorDimmer = Colors.white38;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.deepOrange;
                                  textColor = Colors.deepOrange;
                                  textColorDim = Colors.deepOrange[300]!;
                                  textColorDimmer = Colors.deepOrange[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.pink;
                                  textColor = Colors.pink;
                                  textColorDim = Colors.pink[300]!;
                                  textColorDimmer = Colors.pink[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.blue;
                                  textColor = Colors.blue;
                                  textColorDim = Colors.blue[300]!;
                                  textColorDimmer = Colors.blue[100]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.black;
                                  textColor = Colors.black;
                                  textColorDim = Colors.black54;
                                  textColorDimmer = Colors.black38;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.greenAccent;
                                  textColor = Colors.greenAccent;
                                  textColorDim = Colors.greenAccent[400]!;
                                  textColorDimmer = Colors.greenAccent[700]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  iconColor = Colors.yellowAccent;
                                  textColor = Colors.yellowAccent;
                                  textColorDim = Colors.yellowAccent[400]!;
                                  textColorDimmer = Colors.yellowAccent[700]!;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
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
              //Divider(color: textColorDimmer.withOpacity(0.2)),
              // Weather
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Row(
                  children: [
                    Text(
                      "Weather",
                      style: TextStyle(
                        color: textColorDimmer.withOpacity(0.3),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Enable Metric System
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        useMetricMesurementSystem == true
                            ? Ionicons.thermometer_outline
                            : Icons.device_thermostat_outlined,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Use the Metric Mesurement System",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            "Uses °Centigrade, Meter, Kilograms...",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: useMetricMesurementSystem,
                    onChanged: (value) {
                      useMetricMesurementSystem = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
              //Divider(color: textColorDimmer.withOpacity(0.2)),
              // Microinteractions
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                child: Row(
                  children: [
                    Text(
                      "Microinteractions",
                      style: TextStyle(
                        color: textColorDimmer.withOpacity(0.3),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Enable App Bar Images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        enableFlexibleSpace == false
                            ? Icons.image_not_supported_outlined
                            : Icons.image_outlined,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "App Bar Images",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            "Removes illustrations from the app bar",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: enableFlexibleSpace,
                    onChanged: (value) {
                      enableFlexibleSpace = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
              Divider(color: textColorDimmer.withOpacity(0.2)),
              // Reduce Animations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        reduceAnimations == false
                            ? Icons.blur_on_rounded
                            : Icons.blur_off_rounded,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reduce Animations",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            "Stops waving and particle animations",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: reduceAnimations,
                    onChanged: (value) {
                      reduceAnimations = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
              Divider(color: textColorDimmer.withOpacity(0.2)),
              // Scroll Music Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        marqueeMusicTitle == false
                            ? Icons.music_off_outlined
                            : Icons.music_note_outlined,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Marquee Music Title",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            "Enables/Disables music titles from scrolling",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: marqueeMusicTitle,
                    onChanged: (value) {
                      marqueeMusicTitle = value;
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hide Nav-Bar On Scroll",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          SizedBox(
                            width: 250.0,
                            child: Text(
                              "Hides the bottom navigation bar when scrolling",
                              style: TextStyle(
                                color: textColorDimmer,
                                fontSize: 12.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: hideBottomNav,
                    onChanged: (value) {
                      hideBottomNav = value;
                      hideBottomNavBar();
                      setState(() {});
                    },
                  ),
                ],
              ),
              Divider(color: textColorDimmer.withOpacity(0.2)),
              // Enter fulscreen mode on scroll
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        fullScreenOnScroll == true
                            ? Icons.fullscreen_exit_outlined
                            : Icons.fullscreen,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter Fullscreen Mode On Scroll",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          SizedBox(
                            width: 250.0,
                            child: Text(
                              "Enters into a submersive mode when scrolling",
                              style: TextStyle(
                                color: textColorDimmer,
                                fontSize: 12.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: fullScreenOnScroll,
                    onChanged: (value) {
                      hideBottomNav = value == true ? true : hideBottomNav;
                      fullScreenOnScroll = value;
                      hideBottomNavBar();
                      setState(() {});
                    },
                  ),
                ],
              ),
              Divider(color: textColorDimmer.withOpacity(0.2)),
              // Scroll Music Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isNavBarFloating == false
                            ? Icons.call_to_action
                            : Icons.call_to_action_outlined,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Floating Nav-Bar",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            "Sticks/Floats the bottom navigation bar",
                            style: TextStyle(
                              color: textColorDimmer,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: iconColor,
                    inactiveThumbColor: iconColor.withOpacity(0.2),
                    value: isNavBarFloating,
                    onChanged: (value) {
                      isNavBarFloating = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
              Divider(color: textColorDimmer.withOpacity(0.2)),
              //Divider(color: textColorDimmer.withOpacity(0.2)),
              const SizedBox(height: 150.0),
              // App Version and Speed Tester
              GestureDetector(
                onLongPress: () {
                  isSpeedTesting = !isSpeedTesting;
                  getCacheMemorySize();
                  checkAllPermissionStatus();
                  setState(() {});
                },
                child: isSpeedTesting == false
                    ? Text(
                        "Aurora V1.0.0",
                        style: TextStyle(
                          color: textColorDimmer,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        margin: const EdgeInsets.only(bottom: 15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: feedCardShadow.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Title
                            GestureDetector(
                              onLongPress: () {
                                isSpeedTesting = !isSpeedTesting;
                                setState(() {});
                              },
                              child: Text(
                                "Debug Options",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            // Memory
                            Container(
                              width: 210.0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 15.0),
                              margin: const EdgeInsets.only(bottom: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: feedCardShadow.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onLongPress: () {
                                      isSpeedTesting = !isSpeedTesting;
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Cache Memory",
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.orangeAccent
                                            : Colors.deepOrange[800],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  // Clear Cache
                                  GestureDetector(
                                    onTap: () async {
                                      getCacheMemorySize();
                                      cacheMemorySize = 0;
                                      await DefaultCacheManager().emptyCache();
                                      var appDir =
                                          (await getTemporaryDirectory()).path;
                                      new Directory(appDir)
                                          .delete(recursive: true);
                                      setState(() {});
                                    },
                                    child: Text(
                                      "(" +
                                          cacheMemorySize.toString() +
                                          " mb)\nClear Cache Memory",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.lightBlueAccent
                                            : Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                ],
                              ),
                            ),
                            // Permission Test
                            Container(
                              width: 210.0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 15.0),
                              margin: const EdgeInsets.only(bottom: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: feedCardShadow.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onLongPress: () {
                                      isSpeedTesting = !isSpeedTesting;
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Permissions",
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.orangeAccent
                                            : Colors.deepOrange[800],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  // Storage Permissions
                                  GestureDetector(
                                    onTap: () async {
                                      await Permission.storage.request();
                                      checkAllPermissionStatus();
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Storage Access" +
                                          (grantedStorage == true
                                              ? " ✔"
                                              : " ❌"),
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.lightBlueAccent
                                            : Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  // Location Permissions
                                  GestureDetector(
                                    onTap: () async {
                                      await Permission.location.request();
                                      checkAllPermissionStatus();
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Location Access" +
                                          (grantedLocation == true
                                              ? " ✔"
                                              : " ❌"),
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.lightBlueAccent
                                            : Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Network Test
                            Container(
                              width: 210.0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 15.0),
                              margin: const EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: feedCardShadow.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onLongPress: () {
                                      isSpeedTesting = !isSpeedTesting;
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Network Speed Test",
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.orangeAccent
                                            : Colors.deepOrange[800],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),

                                  // Upload Test
                                  GestureDetector(
                                    onTap: () {
                                      connectionSpeedTest(2);
                                    },
                                    child: Text(
                                      "Upload Speed - " +
                                          uploadRate.toString() +
                                          " " +
                                          uploadUnit,
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.lightBlueAccent
                                            : Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  // Download Test
                                  GestureDetector(
                                    onTap: () {
                                      connectionSpeedTest(1);
                                    },
                                    child: Text(
                                      "Download Speed - " +
                                          downloadRate.toString() +
                                          " " +
                                          downloadUnit,
                                      style: TextStyle(
                                        color: isDarkMode == true
                                            ? Colors.lightBlueAccent
                                            : Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 300.0),
            ],
          ),
        ),
      ),

      // DMs
      SliverToBoxAdapter(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.89,
          color: scaffoldBGColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text list
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: scaffoldBGColor,
                child: ListView.builder(
                  primary: true,
                  shrinkWrap: true,
                  itemCount: users[userIndex]["chat"].length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 55.0,
                      color: scaffoldBGColor,
                      child: Row(
                        mainAxisAlignment:
                            users[userIndex]["chat"][index]["fromMe"] == true
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          // Content and Time
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 4.0),
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: users[userIndex]["chat"]
                                          [index]["fromMe"] ==
                                      true
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  users[userIndex]["chat"][index]["content"],
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  users[userIndex]["chat"][index]["time"],
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: textColorDimmer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Input Box
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attachment,
                          color: textColorDim,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          "Abcd dsdiug iagdi...",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: textColorDim,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Ionicons.paper_plane,
                      color: textColorDim,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Shop
      SliverToBoxAdapter(
        child: Container(
          height: 500.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              childAspectRatio: 1 / 1.2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 12,
            ),
            itemCount: extensionApps.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, extensionApps[index]["app"]);
                },
                child: Container(
                  width: 110.0,
                  height: 130.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 4.0),
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: feedCardsColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[800]!,
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        extensionApps[index]["icon"],
                        size: 40.0,
                        color: iconColor,
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        width: 100.0,
                        height: 28.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            extensionApps[index]["title"],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100.0,
                        height: 20.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            extensionApps[index]["subtitle"],
                            maxLines: 1,
                            style: TextStyle(
                              color: textColorDimmer,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
    List smartRefresherColor = [
      Color(0xff6C63FF),
      Colors.deepOrangeAccent,
      Colors.lightBlue,
      Color(0xff01bb1f),
      Color(0xff0078ff),
      Colors.cyan[400],
      Colors.cyan[400],
      Color(0xff6C63FF),
    ];
    List pagesAppBarBottom = [
      // Home Page
      PreferredSize(
        preferredSize: Size.fromHeight(
            isSongPlaying == true ? 50.0 : 50.0), // here the desired height
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
            : Container(
                child: TabBar(
                  controller: tabBarController,
                  indicatorColor: containerColor,
                  onTap: (value) {
                    curPage = value;
                    if (value != 0) {
                      curPage = 7;
                    }
                    setState(() {});
                  },
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.home_outlined,
                        color: curPage == 0 ? selectedTabColor : iconColor,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.shop_two_outlined,
                        color: curPage == 7 ? selectedTabColor : iconColor,
                      ),
                    ),
                  ],
                ),
              ),
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
      // DM Page
      PreferredSize(
        preferredSize: Size.fromHeight(0.0), // here the desired height
        child: Container(),
      ),
      // Shop Page
      PreferredSize(
        preferredSize: Size.fromHeight(
            isSongPlaying == true ? 50.0 : 50.0), // here the desired height
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
            : Container(
                child: TabBar(
                  controller: tabBarController,
                  indicatorColor: containerColor,
                  onTap: (value) {
                    curPage = value;
                    if (value != 0) {
                      curPage = 7;
                    }
                    setState(() {});
                  },
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.home_outlined,
                        color: curPage == 0 ? selectedTabColor : iconColor,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.shop_two_outlined,
                        color: curPage == 7 ? selectedTabColor : iconColor,
                      ),
                    ),
                  ],
                ),
              ),
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
      {
        "icon": Ionicons.chatbubble_ellipses_outline,
        "title": users[userIndex]["username"],
      },
      {
        "icon": Ionicons.storefront_outline,
        "title": "Store",
      },
    ];
    return WillPopScope(
      onWillPop: backButton,
      child: Scaffold(
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
            physics: BouncingScrollPhysics(),
            controller: scrollController,
            slivers: [
              // App Bar
              fullScreenMode == false
                  ? fullScreenModeMP == false
                      ? SliverAppBar(
                          backgroundColor: appBarBGColor,
                          foregroundColor: Colors.black,
                          expandedHeight: enableFlexibleSpace == true
                              ? pagesAppBarExpanded[curPage]
                              : 0.0,
                          pinned: true,
                          title: GestureDetector(
                            onDoubleTap: () {
                              themeEditorOptionIndex = 1;
                              themeEditorColorPicker(false);
                            },
                            child: Row(
                              children: [
                                curPage == 6
                                    ? IconButton(
                                        onPressed: () {
                                          curPage = 4;
                                          isBottomBarVisible = true;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                        ),
                                      )
                                    : GestureDetector(
                                        onLongPress: () {
                                          themeEditorOptionIndex = 0;
                                          themeEditorColorPicker(false);
                                        },
                                        child: Icon(
                                          pagesAppBarIconTitle[curPage]["icon"],
                                          color: iconColor,
                                        ),
                                      ),
                                SizedBox(width: 12.0),
                                GestureDetector(
                                  onLongPress: () {
                                    themeEditorOptionIndex = 5;
                                    themeEditorColorPicker(false);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        pagesAppBarIconTitle[curPage]["title"],
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      curPage == 6
                                          ? Container(
                                              width: 6.0,
                                              height: 6.0,
                                              margin: const EdgeInsets.only(
                                                  left: 5.0, top: 5.0),
                                              decoration: BoxDecoration(
                                                //shape: BoxShape.circle,
                                                color: users[userIndex]
                                                            ["online"] ==
                                                        true
                                                    ? Colors.lightGreenAccent
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          flexibleSpace: enableFlexibleSpace == true
                              ? pagesAppbarFlexibleSpace[curPage]
                              : GestureDetector(
                                  onLongPress: () {
                                    themeEditorOptionIndex = 1;
                                    themeEditorColorPicker(false);
                                  },
                                  child: FlexibleSpaceBar()),
                          bottom: pagesAppBarBottom[curPage],
                          actions: [
                            curPage == 0
                                ? Row(
                                    children: [
                                      // Search Subreddit
                                      IconButton(
                                        onPressed: () {
                                          feedChoice();
                                        },
                                        icon: Icon(
                                          Icons.search,
                                          color: iconColor,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            curPage == 6
                                ? Container(
                                    width: 35.0,
                                    height: 35.0,
                                    margin: const EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[900],
                                      //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Image.network(
                                        users[userIndex]["dp"],
                                      ),
                                    ),
                                  )
                                :
                                // Fullscreen and Profile
                                Row(
                                    children: [
                                      // Fullscreen
                                      IconButton(
                                        onPressed: () {
                                          if (curPage == 2) {
                                            setFullscreenMusicPlayer();
                                          } else {
                                            setFullscreen();
                                          }
                                        },
                                        icon: Icon(
                                          fullScreenModeMP == false
                                              ? Icons.fullscreen
                                              : Icons.fullscreen_exit,
                                          color: iconColor,
                                        ),
                                      ),
                                      // Profile
                                      Container(
                                        width: 45.0,
                                        height: 45.0,
                                        margin:
                                            const EdgeInsets.only(right: 10.0),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: UserProfileAvatar(
                                            avatarUrl:
                                                'https://i.pinimg.com/564x/4d/37/19/4d37191ca552a28308a1bd1b047402f1.jpg',
                                            onAvatarTap: () {
                                              showProfileDialog();
                                            },
                                            notificationCount: 4,
                                            notificationBubbleTextStyle:
                                                TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            avatarSplashColor:
                                                smartRefresherColor[0],
                                            radius: 20,
                                            isActivityIndicatorSmall: false,
                                            avatarBorderData: AvatarBorderData(
                                              borderColor: Colors.white,
                                              borderWidth: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        )
                      : SliverToBoxAdapter(
                          child: Container(
                            height: 99.0,
                            color: containerColor,
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 55.0, bottom: 4.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.fullscreen_exit,
                                  color: iconColor.withOpacity(0.2),
                                ),
                                onPressed: () {
                                  setFullscreenMusicPlayer();
                                },
                              ),
                            ),
                          ),
                        )
                  : SliverToBoxAdapter(
                      child: Container(
                        color: fullScreenMode == true
                            ? Colors.grey[300]!
                            : Colors.grey[200]!,
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
                enableFloatingNavBar: isNavBarFloating,
                backgroundColor: bottomNavBarColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[500]!,
                    //offset: Offset(1.0, 1.0),
                    //spreadRadius: 0.8,
                    blurRadius: 1.0,
                  ),
                ],
                paddingR: const EdgeInsets.all(0.0),
                marginR: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                currentIndex: curPage,
                itemPadding: EdgeInsets.all(0.0),
                margin: EdgeInsets.symmetric(
                    horizontal: isNavBarFloating == false ? 20.0 : 0.0),
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
                      endIconColor: Color(0xff6C63FF),
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
                      endIconColor: Colors.deepOrangeAccent,
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
                      endIconColor: Color(0xff01bb1f),
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
                      endIconColor: Color(0xff229Aff),
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
      ),
    );
  }
}
