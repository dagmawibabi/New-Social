import 'dart:convert';

import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  List colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.grey[200],
    Colors.lightBlue,
    Colors.lightGreenAccent
  ];
  List cryptoStats = [];

  // State Controllers
  bool loadingCryptoPage = true;
  void getCryptoStats() async {
    var url = Uri.parse(
        "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd");
    var response = await http.get(url);
    var responseJSON = jsonDecode(response.body);
    cryptoStats = responseJSON;
    print(responseJSON);
    loadingCryptoPage = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCryptoStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      /*appBar: AppBar(
        foregroundColor: Colors.black,
        title: Row(
          children: [
            Icon(
              Ionicons.planet_outline,
            ),
            SizedBox(width: 10.0),
            Text(
              "AURORA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                //fontSize: 20.0,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Ionicons.person_outline,
              size: 20.0,
            ),
          ),
        ],
        backgroundColor: Colors.grey[200],
      ),*/
      // B O D Y
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            expandedHeight: 290.0,
            pinned: true,
            stretch: true,
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
                child: Image.asset(
                  "assets/images/appbar_headers/3.png",
                  fit: BoxFit.cover,
                ),
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
          buildBody(loadingCryptoPage, cryptoStats),
        ],
      ),
      // B O T T O M  N A V  B A R
      bottomNavigationBar: DotNavigationBar(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            //offset: Offset(1.0, 1.0),
            //spreadRadius: 0.8,
            blurRadius: 1.0,
          ),
        ],
        paddingR: const EdgeInsets.all(2.0),
        marginR: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
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
      ),
    );
  }
}

Widget buildBody(loading, cryptoStats) => SliverToBoxAdapter(
      child: loading == false
          ? ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: cryptoStats.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text(cryptoStats[index]["symbol"]),
                                      const SizedBox(width: 2.0),
                                      // Crypto price up/down pointer
                                      cryptoStats[index]["current_price"] >
                                                  ((cryptoStats[index]
                                                              ["low_24h"] +
                                                          cryptoStats[index]
                                                              ["high_24h"]) /
                                                      2) ==
                                              true
                                          ? const Icon(Ionicons.arrow_up,
                                              color: Colors.green, size: 12.0)
                                          : const Icon(Ionicons.arrow_down,
                                              color: Colors.red, size: 12.0)
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Crypto Daily High Price
                              Text(
                                cryptoStats[index]["high_24h"].toString(),
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
                                cryptoStats[index]["low_24h"].toString(),
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
                                cryptoStats[index]["current_price"].toString(),
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
                );
              },
            )
          : Container(
              width: 300.0,
              height: 100.0,
              child: Shimmer.fromColors(
                child: Card(
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            color: Colors.blue,
                            child: Text("a"),
                          ),
                          Container(
                            width: 20.0,
                            height: 20.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      Container(width: 20.0, height: 20.0),
                      Container(width: 20.0, height: 20.0),
                    ],
                  ),
                ),
                baseColor: Colors.grey[700]!,
                highlightColor: Colors.white,
              ),
            ),
    );
