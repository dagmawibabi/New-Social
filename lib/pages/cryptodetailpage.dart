import 'package:cached_network_image/cached_network_image.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class CryptoDetailPage extends StatefulWidget {
  const CryptoDetailPage({Key? key}) : super(key: key);

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage> {
  void downloadImage(image) async {
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
  }

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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: scaffoldBGColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          //padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "contentViewerPage",
                    arguments: {
                      "image": cryptoStats[index]["image"],
                      "shareLink": cryptoStats[index]["image"],
                      "downloadingImage": false,
                      "downloadingImageIndex": 0,
                      "downloadingImageDone": false,
                      "index": 0,
                      "downloadImage": downloadImage,
                    },
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: cryptoStats[index]["image"],
                  width: 130.0,
                ),
              ),
              SizedBox(height: 10.0),
              // Name
              Text(
                cryptoStats[index]["name"],
                style: TextStyle(
                  color: textColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Symbol
              Text(
                cryptoStats[index]["symbol"],
                style: TextStyle(
                  color: textColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.0),
              // Current
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
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
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["current_price"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
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
                          "High (24hr)",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["high_24h"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Low (24hr)",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["low_24h"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price Change (24h)",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["price_change_24h"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price Change Percentage (24h)",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["price_change_percentage_24h"]
                              .toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
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
                          "Market Cap",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["market_cap"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Volume",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["total_volume"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Max Supply",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["max_supply"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
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
                          "All Time Hight (ATH)",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["ath"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ATH Time",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["ath_date"]
                              .toString()
                              .substring(11, 19),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ATH Date",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["ath_date"]
                              .toString()
                              .substring(0, 10),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ATH Change",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["ath_change_percentage"]
                                  .toString() +
                              "%",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: containerColor,
                  boxShadow: [
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: feedCardShadow,
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
                          "All Time Low (ATL)",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["atl"].toString(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ATL Time",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["atl_date"]
                              .toString()
                              .substring(11, 19),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ATL Date",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["atl_date"]
                              .toString()
                              .substring(0, 10),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ATL Change",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cryptoStats[index]["atl_change_percentage"]
                                  .toString() +
                              "%",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              // Currency
              Text(
                "Currency - USD (\$)",
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
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
                      color: textColorDimmer,
                      fontSize: 10.0,
                    ),
                  ),
                  Text(
                    "Last Updated",
                    style: TextStyle(
                      color: textColorDimmer,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
