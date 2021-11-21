import 'dart:convert';
import 'dart:math';

import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:newsocial/pages/cryptopage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Random random = Random();
  List colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.grey[200],
    Colors.lightBlue,
    Colors.lightGreenAccent
  ];

  bool isBottomBarVisible = true;
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
    print(homepageFeed.length);
    print(homepageFeed);
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
              imageProvider: NetworkImage(image),
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
                  child: Image.network(
                    cryptoStats[index]["image"],
                    width: 60.0,
                    height: 60.0,
                  ),
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

  //? INIT STATE
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    hideBottomNavBar();
    // Crypto INIT
    getCryptoStats();
    cryptoAppBarImageIndex = random.nextInt(2);
    // HomePage INIT
    startVid("https://v.redd.it/1exrjvwshr081/DASH_1080.mp4");
    getHomePageFeed("imaginaryCharacters", "top", "all");
  }

  //? Dispose
  bool playVideo = false;
  int playVideoIndex = -1;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List pagesAppBarExpanded = [
      20.0,
      20.0,
      20.0,
      isCryptoPageLoadingError == true ? 200.0 : 290.0,
      20.0,
      20.0,
    ];
    List pagesAppbarFlexibleSpace = [
      // Crypto Page
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
    ];
    List pagesBody = [
      SliverToBoxAdapter(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: 200.0,
          child: isFeedLoading == false
              ? TikTokStyleFullPageScroller(
                  contentSize: homepageFeed.length,
                  builder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (homepageFeed[index]["data"][
                                              "url"] // change to thumbnail for vids
                                          .toString()
                                          .endsWith(".jpg") ||
                                      homepageFeed[index]["data"][
                                              "url"] // change to thumbnail for vids
                                          .toString()
                                          .endsWith(".png")) ==
                                  true
                              ? GestureDetector(
                                  onTap: () {
                                    playVideo = true;
                                    playVideoIndex = index;
                                    startVid(homepageFeed[index]["data"]
                                            ["preview"]["reddit_video_preview"]
                                        ["fallback_url"]);
                                    setState(() {});
                                  },
                                  child: (playVideoIndex != index)
                                      ? Image.network(
                                          homepageFeed[index]["data"]["url"],
                                          width: 500.0,
                                        )
                                      : (playVideoIndex == index
                                          ? AspectRatio(
                                              aspectRatio:
                                                  _controller.value.aspectRatio,
                                              child: VideoPlayer(_controller),
                                            )
                                          : Container()))
                              : Image.asset(
                                  "assets/images/error_illustrations/1.png",
                                ),
                          Text(
                            "A",
                            /*homepageFeed[index]["data"]
                                      ["author_fullname"],*/
                          ),
                        ],
                      ),
                    );
                  },
                  //scrollDirection: Axis.vertical,
                )
              : Container(
                  child: const Text("Loding..."),
                ),
        ),
      ),

      // Crypto Page
      CryptoPage.cryptoPage(
        isCryptoPageLoading,
        showCryptoDetail,
        cryptoStats,
        isCryptoPageLoadingError,
        getCryptoStats,
      ),
      // Crypto Page
      CryptoPage.cryptoPage(
        isCryptoPageLoading,
        showCryptoDetail,
        cryptoStats,
        isCryptoPageLoadingError,
        getCryptoStats,
      ),
      // Crypto Page
      CryptoPage.cryptoPage(
        isCryptoPageLoading,
        showCryptoDetail,
        cryptoStats,
        isCryptoPageLoadingError,
        getCryptoStats,
      ),
      // Crypto Page
      CryptoPage.cryptoPage(
        isCryptoPageLoading,
        showCryptoDetail,
        cryptoStats,
        isCryptoPageLoadingError,
        getCryptoStats,
      ),
      // Crypto Page
      CryptoPage.cryptoPage(
        isCryptoPageLoading,
        showCryptoDetail,
        cryptoStats,
        isCryptoPageLoadingError,
        getCryptoStats,
      ),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[200],
      // B O D Y
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: getCryptoStats,
        header: const WaterDropMaterialHeader(
          backgroundColor: Color(0xff6C63FF),
        ),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
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
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Ionicons.person_outline,
                    size: 20.0,
                  ),
                ),
              ],
            ),
            // Body + Content
            pagesBody[curPage],

            /*SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: 200.0,
                child: isFeedLoading == false
                    ? TikTokStyleFullPageScroller(
                        contentSize: homepageFeed.length,
                        builder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            //color: Colors.red,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                (homepageFeed[index]["data"]["thumbnail"]
                                                .toString()
                                                .endsWith(".jpg") ||
                                            homepageFeed[index]["data"]
                                                    ["thumbnail"]
                                                .toString()
                                                .endsWith(".png")) ==
                                        true
                                    ? GestureDetector(
                                        onTap: () {
                                          playVideo = true;
                                          playVideoIndex = index;
                                          startVid(homepageFeed[index]["data"]
                                                      ["preview"]
                                                  ["reddit_video_preview"]
                                              ["fallback_url"]);
                                          setState(() {});
                                        },
                                        child: (playVideoIndex != index)
                                            ? Image.network(
                                                homepageFeed[index]["data"]
                                                    ["thumbnail"],
                                                width: 500.0,
                                              )
                                            : (playVideoIndex == index
                                                ? AspectRatio(
                                                    aspectRatio: _controller
                                                        .value.aspectRatio,
                                                    child: VideoPlayer(
                                                        _controller),
                                                  )
                                                : Container()))
                                    : Image.asset(
                                        "assets/images/error_illustrations/1.png",
                                      ),
                                Text(
                                  "A",
                                  /*homepageFeed[index]["data"]
                                      ["author_fullname"],*/
                                ),
                              ],
                            ),
                          );
                        },
                        //scrollDirection: Axis.vertical,
                      )
                    : Container(
                        child: const Text("Loding..."),
                      ),
              ),
            ),*/

            // Space Below
            const SliverToBoxAdapter(
              child: SizedBox(height: 200.0),
            ),
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
                /// Home
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.planet_outline),
                  selectedColor: Colors.purple,
                ),

                /// Search / Discover
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.compass_outline),
                  selectedColor: Colors.purple,
                ),

                /// Music
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.play_outline),
                  selectedColor: Colors.pink,
                ),

                /// Crypto
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.wallet_outline),
                  selectedColor: Color(0xff6C63FF),
                ),

                /// chat
                DotNavigationBarItem(
                  icon: const Icon(Ionicons.paper_plane_outline),
                  selectedColor: Colors.teal,
                ),

                /// Settings
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
