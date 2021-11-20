import 'dart:convert';

import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.grey[200],
    Colors.lightBlue,
    Colors.lightGreenAccent
  ];
  List cryptoStats = [];

  ScrollController scrollController = ScrollController();
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
  bool isCryptoPageLoading = true;
  bool isCryptoPageLoadingError = false;
  int curPage = 0;
  List pages = [
    // Page 1
    PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 5, //colors.length,
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.lightBlue, //colors[index],
        );
      },
    ),
  ];

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCryptoStats();
    hideBottomNavBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[200],
      // B O D Y
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            expandedHeight: isCryptoPageLoadingError == true ? 200.0 : 290.0,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: isCryptoPageLoadingError == false
                    ? Image.asset(
                        "assets/images/appbar_headers/3.png",
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            ),
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
          SliverList(
            delegate: isCryptoPageLoading == false
                ? SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showCryptoDetail(context, index);
                        },
                        child: Card(
                          elevation: 0.2,
                          color: Colors.grey[200],
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 2.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Crypto Image, Name and Symbol
                                Row(
                                  children: [
                                    // Crypto Image
                                    Image.network(cryptoStats[index]["image"],
                                        width: 36.0),
                                    const SizedBox(width: 12.0),
                                    // Crypto Name, Symbol and price up/down pointer
                                    SizedBox(
                                      width: 100.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Crypto Name
                                          Text(
                                            cryptoStats[index]["id"]
                                                .toString()
                                                .toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              letterSpacing: 0.4,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Crypto Symbol and price up/down pointer
                                          Row(
                                            children: [
                                              // Crypto Symbol
                                              Text(
                                                  cryptoStats[index]["symbol"]),
                                              const SizedBox(width: 2.0),
                                              // Crypto price up/down pointer
                                              cryptoStats[index][
                                                              "current_price"] >
                                                          ((cryptoStats[index][
                                                                      "low_24h"] +
                                                                  cryptoStats[
                                                                          index]
                                                                      [
                                                                      "high_24h"]) /
                                                              2) ==
                                                      true
                                                  ? const Icon(
                                                      Ionicons.arrow_up,
                                                      color: Colors.green,
                                                      size: 12.0)
                                                  : const Icon(
                                                      Ionicons.arrow_down,
                                                      color: Colors.red,
                                                      size: 12.0)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Crypto Daily High and Low Price
                                SizedBox(
                                  width: 100.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Crypto Daily High Price
                                      Text(
                                        cryptoStats[index]["high_24h"]
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          letterSpacing: 0.3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Crypto Daily Low Price
                                      Text(
                                        cryptoStats[index]["low_24h"]
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          letterSpacing: 0.3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Crypto Current Price
                                SizedBox(
                                  width: 100.0,
                                  child: Text(
                                    "\$" +
                                        cryptoStats[index]["current_price"]
                                            .toString(),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      letterSpacing: 0.3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: cryptoStats.length,
                  )
                : (isCryptoPageLoadingError == false
                    ? SliverChildBuilderDelegate(
                        (context, index) {
                          return const shimmerCryptoCard();
                        },
                        childCount: 5,
                      )
                    : SliverChildBuilderDelegate(
                        (context, index) {
                          return Column(
                            children: [
                              Image.asset(
                                "assets/images/appbar_headers/5.png",
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 6.0),
                                  const Text(
                                    "Error Fetching Content",
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 22.0,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      getCryptoStats();
                                    },
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 20.0,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                        childCount: 1,
                      )),
          ),
          // Space Below
          const SliverToBoxAdapter(
            child: SizedBox(height: 200.0),
          ),
        ],
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
              currentIndex: 3, //curPage,
              onTap: (index) {
                curPage = index;
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
                  selectedColor: Colors.green,
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

// ignore: camel_case_types
class shimmerCryptoCard extends StatelessWidget {
  const shimmerCryptoCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.2,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Crypto Image, name and symbol
            Row(
              children: [
                // Crypto Image
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[600]!,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                // Crypto name and symbol
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crypto Name
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(
                        width: 100.0,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Text(""),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    // Crypto Symbol
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[500]!,
                      child: Container(
                        width: 50.0,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Text(""),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Crypto high and low price
            Column(
              children: [
                // Crypto high price
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.green[200]!, //Colors.grey[200]!,
                  child: Container(
                    width: 60.0,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Text(""),
                  ),
                ),
                const SizedBox(height: 2.0),
                // Crypto low price
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.pink[200]!, //Colors.grey[200]!,
                  child: Container(
                    width: 60.0,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Text(""),
                  ),
                ),
              ],
            ),
            // Crypto current price
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                width: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Text(""),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
