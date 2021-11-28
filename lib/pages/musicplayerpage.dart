import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as p;
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class MusicPlayerPage {
  static double forwardRewindSpeed = 5.0;
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
    songPositionStreamBuilder,
    sliderStreamBuilder,
    curSongIndex,
    nextInPlaylist,
    backInPlaylist,
    playlistLoader,
  ) {
    return SliverToBoxAdapter(
      child: gotSongs == false
          // Get Songs Container
          ? Container(
              margin: const EdgeInsets.only(
                  top: 20.0, left: 20.0, right: 20.0, bottom: 150.0),
              height: MediaQuery.of(context).size.height - 300,
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
              height: fullScreenMode == false
                  ? MediaQuery.of(context).size.height - 100
                  : MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  // Background image
                  Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new ExactAssetImage(albumArtImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: fullScreenMode == false
                        ? MediaQuery.of(context).size.height - 100
                        : MediaQuery.of(context).size.height,
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: new Container(
                        decoration: new BoxDecoration(
                            color: Colors.white.withOpacity(0.0)),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: (fullScreenMode == false ? 0.0 : 30.0)),
                    height: MediaQuery.of(context).size.height - 0,
                    color: fullScreenMode == false
                        ? Colors.grey[200]
                        : Colors.transparent,
                    child: FlipCard(
                      controller: flipCardController,
                      // Song list
                      back: Container(
                        margin: EdgeInsets.only(
                          top: 10.0,
                          left: 0.0,
                          right: 0.0,
                          bottom: fullScreenMode == true ? 0.0 : 50.0,
                        ),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                          top: fullScreenMode == true ? 10.0 : 0.0,
                          left: fullScreenMode == true ? 0.0 : 10.0,
                          right: fullScreenMode == true ? 0.0 : 10.0,
                          bottom: fullScreenMode == true ? 10.0 : 100.0,
                        ),
                        decoration: BoxDecoration(
                          color: fullScreenMode == true
                              ? Colors.transparent // Colors.grey[300]!
                              : Colors.grey[200]!,
                        ),
                        // Indie Songs Button
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height -
                                  (fullScreenMode == true ? 130 : 320),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: musicFiles.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
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
                                      /*curSongIndex = index;
                                      if ((curSong ==
                                              p.withoutExtension(p.basename(
                                                  musicFiles[index]
                                                      .toString()))) ==
                                          true) {
                                        pausePlaySong();
                                        //playlistLoader(curSongIndex);
                                      } else {
                                        loadPlaySong(musicFiles[curSongIndex]
                                            .toString());
                                        /*playlistLoader(curSongIndex);*/
                                        /*loadPlaySong(
                                            musicFiles[index].toString());*/
                                      }*/
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: curSong ==
                                                    p.withoutExtension(
                                                        p.basename(
                                                            musicFiles[index]
                                                                .toString()))
                                                ? (fullScreenMode == true
                                                    ? Colors.black
                                                        .withOpacity(0.8)
                                                    : Colors.grey[800]!
                                                        .withOpacity(0.9))
                                                : Colors
                                                    .transparent, // Colors.grey[900],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    fullScreenMode == true
                                                        ? 5.0
                                                        : 15.0)),
                                            /*border: curSong ==
                                                    p.withoutExtension(p.basename(
                                                        musicFiles[index]
                                                            .toString()))
                                                ? Border.all(
                                                    color: curPlayingSongColor)
                                                : Border.all(color: Colors.black),*/
                                          ),
                                          /*margin:
                                              const EdgeInsets.only(bottom: 8.0),*/
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 15.0),
                                          child: Row(
                                            children: [
                                              // Music Note Icon
                                              Icon(
                                                Icons.music_note_outlined,
                                                color: curSong ==
                                                        p.withoutExtension(p
                                                            .basename(musicFiles[
                                                                    index]
                                                                .toString()))
                                                    ? curPlayingSongColor
                                                    : Colors.grey[900],
                                              ),
                                              const SizedBox(width: 10.0),
                                              // Music Title
                                              Expanded(
                                                child: p
                                                            .basename(
                                                                musicFiles[
                                                                        index]
                                                                    .toString())
                                                            .length <
                                                        30
                                                    ? Text(
                                                        p.basename(
                                                            musicFiles[index]
                                                                .toString()),
                                                        style: TextStyle(
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: curSong ==
                                                                  p.withoutExtension(
                                                                      p.basename(
                                                                          musicFiles[index]
                                                                              .toString()))
                                                              ? curPlayingSongColor
                                                              : Colors
                                                                  .grey[900],
                                                        ),
                                                        maxLines: 1,
                                                      )
                                                    : Container(
                                                        height: 30.0,
                                                        child: Marquee(
                                                          text: p.basename(
                                                              musicFiles[index]
                                                                  .toString()),
                                                          blankSpace: 80.0,
                                                          velocity: 30.0,
                                                          numberOfRounds: 3,
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: curSong ==
                                                                    p.withoutExtension(p.basename(
                                                                        musicFiles[index]
                                                                            .toString()))
                                                                ? curPlayingSongColor
                                                                : Colors
                                                                    .grey[900],
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              // Choose Song
                                              Icon(
                                                (curSong ==
                                                            p.withoutExtension(p
                                                                .basename(musicFiles[
                                                                        index]
                                                                    .toString())) &&
                                                        isSongPlaying)
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: curSong ==
                                                        p.withoutExtension(p
                                                            .basename(musicFiles[
                                                                    index]
                                                                .toString()))
                                                    ? curPlayingSongColor
                                                    : Colors.grey[900],
                                                size: 30.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey[600],
                                          thickness: 0.2,
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Click to flip
                            fullScreenMode == true
                                ? Container()
                                : Container(
                                    width: 300.0,
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: const Text(
                                      "Click here to see music player controls",
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
                      // Music Player and controls
                      front: Container(
                        decoration: BoxDecoration(
                          color: fullScreenMode == true
                              ? Colors.white.withOpacity(
                                  fullScreenMode == true ? 0.0 : 0.4)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: fullScreenMode == true
                                  ? Colors.grey[700]!.withOpacity(
                                      fullScreenMode == true ? 0.0 : 0.3)
                                  : Colors.grey[200]!,
                              spreadRadius: 2,
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(
                          top: fullScreenMode == true ? 50.0 : 30.0,
                          left: fullScreenMode == true ? 0.0 : 20.0,
                          right: fullScreenMode == true ? 0.0 : 20.0,
                          bottom:
                              30.0, /*(fullScreenMode == true ? 160.0 : 100.0), --> mini player*/
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
                                height: fullScreenMode == true ? 400.0 : 350.0,
                                width: 400.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200]!.withOpacity(0.4),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 100.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        fullScreenMode == true ? 16.0 : 18.0,
                                    vertical: 5.0),
                                clipBehavior: Clip.hardEdge,
                                child: const Center(
                                  child: Text("No Lyrics Found"),
                                ),
                              ),
                              // Album Art + Fullscreen Button
                              front: Container(
                                height: fullScreenMode == true ? 400.0 : 350.0,
                                width: 400.0,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 100.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        fullScreenMode == true ? 16.0 : 18.0,
                                    vertical: 5.0),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  children: [
                                    // Album Art Image
                                    Container(
                                      height: fullScreenMode == true
                                          ? 400.0
                                          : 350.0,
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
                                          height: fullScreenMode == true
                                              ? 360.0
                                              : 30.0,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0.0)),
                                            color: Colors.transparent,
                                          ),
                                          padding: EdgeInsets.only(
                                              top: fullScreenMode == true
                                                  ? 350.0
                                                  : 20.0),
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
                                                  waveAmplitude:
                                                      fullScreenMode == true
                                                          ? 4
                                                          : 2,
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
                                color: Colors
                                    .transparent, // grey[200]!.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical:
                                      fullScreenMode == true ? 30.0 : 0.0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              clipBehavior: Clip.hardEdge,
                              height: 250.0,
                              width: MediaQuery.of(context).size.width,
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
                                              style: TextStyle(
                                                fontSize: fullScreenMode == true
                                                    ? 23.0
                                                    : 20.0,
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
                                    width: MediaQuery.of(context).size.width -
                                        (fullScreenMode == true ? 50.0 : 100.0),
                                    //height: 30.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        songPositionStreamBuilder(),
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
                                  sliderStreamBuilder(),
                                  fullScreenMode == true
                                      ? SizedBox(height: 20.0)
                                      : SizedBox(height: 0.0),
                                  // Controlls
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Repeat Button
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.repeat,
                                          size: fullScreenMode == true
                                              ? 30.0
                                              : 26.0,
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
                                          onPressed: () {
                                            backInPlaylist();
                                          },
                                          icon: Icon(
                                            Icons.fast_rewind_rounded,
                                            size: fullScreenMode == true
                                                ? 40.0
                                                : 36.0,
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
                                          size: fullScreenMode == true
                                              ? 40.0
                                              : 36.0,
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
                                          onPressed: () {
                                            nextInPlaylist();
                                            print("heeeeeeeerrreee2");
                                          },
                                          icon: Icon(
                                            Icons.fast_forward_rounded,
                                            size: fullScreenMode == true
                                                ? 40.0
                                                : 36.0,
                                          ),
                                        ),
                                      ),
                                      // Shuffle Button
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.shuffle,
                                          size: fullScreenMode == true
                                              ? 30.0
                                              : 26.0,
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
                                            "Click here to see your list of songs",
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
