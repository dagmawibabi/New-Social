import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({Key? key}) : super(key: key);

  @override
  _VideoViewerPageState createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  VideoPlayerController _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');

  void getVideo(dynamic video) {
    //VideoPlayerController.network(receivedData["video"]);
    _controller = VideoPlayerController.network(video)
      ..initialize().then(
        (_) {
          setState(() {});
        },
      );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(),
      body: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  receivedData["thumbnail"],
                ),
                Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      size: 70.0,
                    ),
                    onPressed: () {
                      getVideo(receivedData["video"]);
                    },
                  ),
                ),
              ],
            ),
      /*_controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Container(),*/
    );
  }
}
