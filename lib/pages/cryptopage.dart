import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';

class CryptoPage {
  static IconData cryptoActionIcon = Icons.send;
  static Function cryptoActionFunction = () {};
  static SliverList cryptoPage(
    isCryptoPageLoading,
    showCryptoDetail,
    cryptoStats,
    isCryptoPageLoadingError,
    getCryptoStats,
    getRandom,
    error_illustrations,
    feedCardColor,
    textColor,
    textColorDim,
    textColorDimmer,
    iconColor,
    cardGradient,
  ) {
    return SliverList(
      delegate: isCryptoPageLoading == false
          ? SliverChildBuilderDelegate(
              (context, index) {
                return GestureDetector(
                  onTap: () {
                    showCryptoDetail(context, index);
                  },
                  child: Card(
                    elevation: 0.2,
                    color: feedCardColor, //Colors.grey[200],
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 2.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          index == 0
                              ? Column(
                                  children: [
                                    // Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 80.0),
                                      margin:
                                          const EdgeInsets.only(bottom: 20.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: cardGradient,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Total Balance",
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: textColorDimmer,
                                              ),
                                            ),
                                            const SizedBox(height: 10.0),
                                            Text(
                                              "\$46,423.36",
                                              style: TextStyle(
                                                fontSize: 30.0,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Transaction Buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Send
                                        GestureDetector(
                                          onTap: () {
                                            cryptoActionFunction();
                                          },
                                          child: cryptoTransactionButton(
                                            cryptoActionIcon: cryptoActionIcon,
                                            textColorDimmer: textColor,
                                            iconColor: iconColor,
                                          ),
                                        ),
                                        // Receive
                                        GestureDetector(
                                          onTap: () {
                                            cryptoActionFunction();
                                          },
                                          child: cryptoTransactionButton(
                                            cryptoActionIcon:
                                                Icons.file_download_outlined,
                                            textColorDimmer: textColor,
                                            iconColor: iconColor,
                                          ),
                                        ),
                                        // Swap
                                        GestureDetector(
                                          onTap: () {
                                            cryptoActionFunction();
                                          },
                                          child: cryptoTransactionButton(
                                            cryptoActionIcon: Icons
                                                .wifi_protected_setup_rounded,
                                            textColorDimmer: textColor,
                                            iconColor: iconColor,
                                          ),
                                        ),
                                        // Send
                                        GestureDetector(
                                          onTap: () {
                                            cryptoActionFunction();
                                          },
                                          child: cryptoTransactionButton(
                                            cryptoActionIcon:
                                                Icons.qr_code_scanner_outlined,
                                            textColorDimmer: textColor,
                                            iconColor: iconColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Crypto Image, Name and Symbol
                              Row(
                                children: [
                                  // Crypto Image
                                  Image(
                                      image: CachedNetworkImageProvider(
                                          cryptoStats[index]["image"]),
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
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            letterSpacing: 0.4,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        // Crypto Symbol and price up/down pointer
                                        Row(
                                          children: [
                                            // Crypto Symbol
                                            Text(
                                              cryptoStats[index]["symbol"],
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(width: 2.0),
                                            // Crypto price up/down pointer
                                            cryptoStats[index]
                                                            ["current_price"] >
                                                        ((cryptoStats[index][
                                                                    "low_24h"] +
                                                                cryptoStats[
                                                                        index][
                                                                    "high_24h"]) /
                                                            2) ==
                                                    true
                                                ? const Icon(Ionicons.arrow_up,
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
                                      cryptoStats[index]["current_price"]
                                          .toString(),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 0.3,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
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
                    return const ShimmerCryptoCard();
                  },
                  childCount: 5,
                )
              // Error Fetching
              : SliverChildBuilderDelegate(
                  (context, index) {
                    return Column(
                      children: [
                        Image.asset(
                          getRandom(error_illustrations).toString(),
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
    );
  }
}

class cryptoTransactionButton extends StatelessWidget {
  const cryptoTransactionButton({
    Key? key,
    required this.cryptoActionIcon,
    required this.textColorDimmer,
    required this.iconColor,
  }) : super(key: key);

  final IconData cryptoActionIcon;
  final Color textColorDimmer;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      margin: const EdgeInsets.only(bottom: 40.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Icon(
        cryptoActionIcon,
        color: iconColor,
      ),
    );
  }
}

class ShimmerCryptoCard extends StatelessWidget {
  const ShimmerCryptoCard({
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
