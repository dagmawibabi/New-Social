import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as p;
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class MusicPlayerPage {
  static double forwardRewindSpeed = 3.0;
  static SliverToBoxAdapter musicPlayer(
    BuildContext context,
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
  ) {
    return SliverToBoxAdapter(
      child: gotSongs == false
          // Get Songs Container
          ? Container(
              margin: const EdgeInsets.only(
                  top: 20.0, left: 20.0, right: 20.0, bottom: 150.0),
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              // Get Songs Warning and Button
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 90.0),
                  // No Songs Illustration
                  Image.asset(getRandom(empty_illustrations).toString()),
                  // No Songs Warning
                  const Text(
                    "You have no songs imported!",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // Get Songs Button
                  GestureDetector(
                    onTap: () {
                      getSongsOnDevice();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 12.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.music_note_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            "Get Songs",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Fetch directory Warning
                  const SizedBox(height: 8.0),
                  const SizedBox(
                    width: 300.0,
                    child: Text(
                      "Will fetch songs from your device's Downloads and Music folder",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          // Music Player, controls and Song list
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 100,
                    color: Colors.transparent,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset(albumArtImage),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      /*fullScreenMode == true
                          ? Colors.grey[300]!
                          : Colors.grey[200]!,*/
                      boxShadow: [
                        BoxShadow(
                          color: fullScreenMode == true
                              ? Colors.grey[400]!
                              : Colors.grey[200]!,
                          spreadRadius: 0.5,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    height: MediaQuery.of(context).size.height - 100,
                    child: FlipCard(
                      controller: flipCardController,
                      // Song list
                      back: Container(
                        margin: const EdgeInsets.only(
                            top: 20.0, left: 5.0, right: 5.0, bottom: 50.0),
                        height: MediaQuery.of(context).size.height - 320,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 150.0),
                        decoration: BoxDecoration(
                          color: fullScreenMode == true
                              ? Colors.grey[300]!
                              : Colors.grey[200]!,
                        ),
                        // Indie Songs Button
                        child: ListView.builder(
                          itemCount: musicFiles.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                border: curSong ==
                                        p.withoutExtension(p.basename(
                                            musicFiles[index].toString()))
                                    ? Border.all(color: curPlayingSongColor)
                                    : Border.all(color: Colors.black),
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.music_note_outlined,
                                    color: curSong ==
                                            p.withoutExtension(p.basename(
                                                musicFiles[index].toString()))
                                        ? curPlayingSongColor
                                        : Colors.grey[200],
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: p
                                                .basename(musicFiles[index]
                                                    .toString())
                                                .length <
                                            30
                                        ? Text(
                                            p.basename(
                                                musicFiles[index].toString()),
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: curSong ==
                                                      p.withoutExtension(
                                                          p.basename(
                                                              musicFiles[index]
                                                                  .toString()))
                                                  ? curPlayingSongColor
                                                  : Colors.grey[200],
                                            ),
                                            maxLines: 1,
                                          )
                                        : Container(
                                            height: 30.0,
                                            child: Marquee(
                                              text: p.basename(
                                                  musicFiles[index].toString()),
                                              blankSpace: 80.0,
                                              velocity: 30.0,
                                              numberOfRounds: 3,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: curSong ==
                                                        p.withoutExtension(p
                                                            .basename(musicFiles[
                                                                    index]
                                                                .toString()))
                                                    ? curPlayingSongColor
                                                    : Colors.grey[200],
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  // Choose Song
                                  GestureDetector(
                                    onTap: () {
                                      if ((curSong ==
                                              p.withoutExtension(p.basename(
                                                  musicFiles[index]
                                                      .toString()))) ==
                                          true) {
                                        pausePlaySong();
                                      } else {
                                        loadPlaySong(
                                            musicFiles[index].toString());
                                      }
                                    },
                                    child: Icon(
                                      (curSong ==
                                                  p.withoutExtension(p.basename(
                                                      musicFiles[index]
                                                          .toString())) &&
                                              isSongPlaying)
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: curSong ==
                                              p.withoutExtension(p.basename(
                                                  musicFiles[index].toString()))
                                          ? curPlayingSongColor
                                          : Colors.grey[200],
                                      size: 30.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Music Player and controls
                      front: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent, //Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: fullScreenMode == true
                                  ? Colors.grey[400]!
                                  : Colors.grey[200]!,
                              spreadRadius: 0.5,
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(
                          top: 30.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: (fullScreenMode == true ? 160.0 : 100.0),
                        ),
                        height: MediaQuery.of(context).size.height - 200,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20.0),
                            // Album Art and back
                            FlipCard(
                              // Album Art Back
                              back: Container(
                                height: 350.0,
                                width: 400.0,
                                decoration: BoxDecoration(
                                  color: Colors.transparent, //Colors.grey[200],
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                  //border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[300]!,
                                      blurRadius: 3.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.hardEdge,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 5.0),
                                child: const Center(
                                  child: Text("No Lyrics Found"),
                                ),
                              ),
                              // Album Art + Fullscreen Button
                              front: Container(
                                height: 350.0,
                                width: 400.0,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 5.0),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  children: [
                                    // Album Art Image
                                    Container(
                                      height: 350.0,
                                      width: 400.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        albumArtImage,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Fullscreen Button
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0, vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                changeAlbumArt();
                                              },
                                              icon: const Icon(
                                                Icons.shuffle,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setFullscreen();
                                              },
                                              icon: Icon(
                                                fullScreenMode == true
                                                    ? Icons.fullscreen_exit
                                                    : Icons.fullscreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Wave Animation
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0.0),
                                        child: Container(
                                          height: 20.0,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30.0)),
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: isSongPlaying == true
                                              ? WaveWidget(
                                                  config: CustomConfig(
                                                    gradients:
                                                        lightModeWaveGradient,
                                                    durations: [
                                                      35000,
                                                      19440,
                                                      10800,
                                                      6000
                                                    ],
                                                    heightPercentages: [
                                                      0.20,
                                                      0.23,
                                                      0.25,
                                                      0.30
                                                    ],
                                                    blur: const MaskFilter.blur(
                                                        BlurStyle.solid, 10),
                                                    gradientBegin:
                                                        Alignment.bottomLeft,
                                                    gradientEnd:
                                                        Alignment.topRight,
                                                  ),
                                                  duration: 1000,
                                                  waveAmplitude: 2,
                                                  heightPercentange: 0.1,
                                                  size: const Size(
                                                    double.infinity,
                                                    double.infinity,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Song title + Controls
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0.0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              clipBehavior: Clip.hardEdge,
                              child: Column(
                                children: [
                                  // Song Title : Scroll if title length is greater than 28 xers
                                  Container(
                                    height: 30.0,
                                    width: 300.0,
                                    child: curSong.length < 28 == true
                                        ? Center(
                                            child: Text(
                                              curSong,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Marquee(
                                            text: curSong,
                                            blankSpace: 50.0,
                                            numberOfRounds: 3,
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  // Song Position and Duration
                                  Container(
                                    width: 300.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        StreamBuilder(
                                          stream:
                                              assetsAudioPlayer.currentPosition,
                                          builder: (context, asyncSnapshot) {
                                            final dynamic duration =
                                                asyncSnapshot.data;
                                            return Text(
                                              ((duration.inSeconds / 3600)
                                                          .toInt())
                                                      .toString()
                                                      .padLeft(2, '0') +
                                                  ":" +
                                                  ((duration.inSeconds / 60)
                                                          .toInt())
                                                      .toString()
                                                      .padLeft(2, '0') +
                                                  ":" +
                                                  ((duration.inSeconds % 60)
                                                          .toInt())
                                                      .toString()
                                                      .padLeft(2, "0"),
                                            );
                                          },
                                        ),
                                        Text(
                                          ((curSongDuration.inSeconds / 3600)
                                                      .toInt())
                                                  .toString()
                                                  .padLeft(2, '0') +
                                              ":" +
                                              ((curSongDuration.inSeconds / 60)
                                                      .toInt())
                                                  .toString()
                                                  .padLeft(2, '0') +
                                              ":" +
                                              ((curSongDuration.inSeconds % 60)
                                                      .toInt())
                                                  .toString()
                                                  .padLeft(2, "0"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Slider
                                  StreamBuilder(
                                    stream: assetsAudioPlayer.currentPosition,
                                    builder: (context, asyncSnapshot) {
                                      final dynamic duration =
                                          asyncSnapshot.data;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Slider(
                                          activeColor: Colors.grey[900],
                                          inactiveColor: Colors
                                              .grey[500], //Color(0xaa6C63FF),
                                          value: duration != null
                                              ? duration.inSeconds.toDouble()
                                              : 0.0,
                                          min: 0.0,
                                          max: curSongDuration != null
                                              ? curSongDuration.inSeconds
                                                  .toDouble()
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
                                  ),
                                  // Controlls
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Repeat Button
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.repeat,
                                          size: 26.0,
                                        ),
                                      ),
                                      // Fast Rewind Button
                                      GestureDetector(
                                        onLongPressDown:
                                            (longPressDownDetails) {
                                          assetsAudioPlayer.forwardOrRewind(
                                              -MusicPlayerPage
                                                  .forwardRewindSpeed);
                                        },
                                        onLongPressEnd: (longPressDownDetails) {
                                          assetsAudioPlayer
                                              .forwardOrRewind(0.0);
                                        },
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.fast_rewind_rounded,
                                            size: 36.0,
                                          ),
                                        ),
                                      ),
                                      // Pause and Play Button
                                      IconButton(
                                        onPressed: () {
                                          pausePlaySong();
                                        },
                                        icon: Icon(
                                          isSongPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 36.0,
                                        ),
                                      ),
                                      // Fast Forward Button
                                      GestureDetector(
                                        onLongPressDown:
                                            (longPressDownDetails) {
                                          assetsAudioPlayer.forwardOrRewind(
                                              MusicPlayerPage
                                                  .forwardRewindSpeed);
                                        },
                                        onLongPressEnd: (longPressDownDetails) {
                                          assetsAudioPlayer
                                              .forwardOrRewind(0.0);
                                        },
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.fast_forward_rounded,
                                            size: 36.0,
                                          ),
                                        ),
                                      ),
                                      // Shuffle Button
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.shuffle,
                                          size: 26.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Click to flip
                                  fullScreenMode == true
                                      ? Container()
                                      : Container(
                                          width: 300.0,
                                          padding:
                                              const EdgeInsets.only(top: 30.0),
                                          child: const Text(
                                            "Click here to see list of songs",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
