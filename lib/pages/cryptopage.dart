import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';

class CryptoPage {
  static SliverList cryptoPage(
    isCryptoPageLoading,
    showCryptoDetail,
    cryptoStats,
    isCryptoPageLoadingError,
    getCryptoStats,
    getRandom,
    error_illustrations,
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
