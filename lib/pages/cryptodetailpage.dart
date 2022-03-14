import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CryptoDetailPage extends StatefulWidget {
  const CryptoDetailPage({Key? key}) : super(key: key);

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage> {
  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)!.settings.arguments;
    dynamic cryptoStats = receivedData["cryptoStats"];
    int index = receivedData["index"];
    dynamic containerColor = receivedData["containerColor"];
    dynamic feedCardShadow = receivedData["feedCardShadow"];
    dynamic scaffoldBGColor = receivedData["scaffoldBGColor"];
    dynamic iconColor = receivedData["iconColor"];
    dynamic textColor = receivedData["textColor"];
    dynamic textColorDim = receivedData["textColorDim"];
    dynamic textColorDimmer = receivedData["textColorDimmer"];
    return Scaffold(
      backgroundColor: scaffoldBGColor,
      body: Container(
        width: double.infinity,
        //padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: cryptoStats[index]["image"],
              width: 150.0,
            ),
            SizedBox(height: 10.0),
            // Name
            Text(
              cryptoStats[index]["name"],
              style: TextStyle(
                color: Colors.black,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Symbol
            Text(
              cryptoStats[index]["symbol"],
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.0),
            // Current
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: containerColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Current Price",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["current_price"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            // 24 Hrs
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: containerColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "high_24h",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["high_24h"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "low_24h",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["low_24h"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "price_change_24h",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["price_change_24h"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "price_change_percentage_24h",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["price_change_percentage_24h"]
                            .toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            // Market
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: containerColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "market_cap",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["market_cap"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "total_volume",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["total_volume"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "max_supply",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["max_supply"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            // Ath
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: containerColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ath",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["ath"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ath_time",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["ath_date"]
                            .toString()
                            .substring(11, 19),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ath_date",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["ath_date"]
                            .toString()
                            .substring(0, 10),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ath_change_percentage",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["ath_change_percentage"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            // ATL
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: containerColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "atl",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["atl"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "atl_time",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["atl_date"]
                            .toString()
                            .substring(11, 19),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "atl_date",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["atl_date"]
                            .toString()
                            .substring(0, 10),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "atl_change_percentage",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        cryptoStats[index]["atl_change_percentage"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            // Update time
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cryptoStats[index]["last_updated"]
                          .toString()
                          .substring(11, 19) +
                      " • " +
                      cryptoStats[index]["last_updated"]
                          .toString()
                          .substring(0, 10),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.0,
                  ),
                ),
                Text(
                  "Last Updated",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
