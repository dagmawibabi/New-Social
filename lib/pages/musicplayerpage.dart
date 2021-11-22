import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as p;

class MusicPlayerPage {
  static SliverToBoxAdapter musicPlayer(
      BuildContext context,
      gotSongs,
      musicFiles,
      curSong,
      pausePlaySong,
      loadPlaySong,
      isSongPlaying,
      getSongsOnDevice,
      albumArtImage,
      setFullscreen,
      fullScreenMode) {
    return SliverToBoxAdapter(
      child: FlipCard(
        back: gotSongs == true
            // Song list
            ? Container(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 150.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                ),
                // Indie Songs Button
                child: ListView.builder(
                  itemCount: musicFiles.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        border: curSong ==
                                p.withoutExtension(
                                    p.basename(musicFiles[index].toString()))
                            ? Border.all(color: Colors.lightBlue)
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
                                    p.withoutExtension(p
                                        .basename(musicFiles[index].toString()))
                                ? Colors.lightBlue
                                : Colors.grey[200],
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: p
                                        .basename(musicFiles[index].toString())
                                        .length <
                                    30
                                ? Text(
                                    p.basename(musicFiles[index].toString()),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: curSong ==
                                              p.withoutExtension(p.basename(
                                                  musicFiles[index].toString()))
                                          ? Colors.lightBlue
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
                                                p.withoutExtension(p.basename(
                                                    musicFiles[index]
                                                        .toString()))
                                            ? Colors.lightBlue
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
                                          musicFiles[index].toString()))) ==
                                  true) {
                                pausePlaySong();
                              } else {
                                loadPlaySong(musicFiles[index].toString());
                              }
                            },
                            child: Icon(
                              (curSong ==
                                          p.withoutExtension(p.basename(
                                              musicFiles[index].toString())) &&
                                      isSongPlaying)
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: curSong ==
                                      p.withoutExtension(p.basename(
                                          musicFiles[index].toString()))
                                  ? Colors.lightBlue
                                  : Colors.grey[200],
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            // Get Songs Container
            : Container(
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
                    Image.asset("assets/images/error_illustrations/2.png"),
                    // No Songs Warning
                    const Text(
                      "You have no songs imported!",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Get Songs Button
                    GestureDetector(
                      onTap: () {
                        getSongsOnDevice();
                        print("Here");
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
                  ],
                ),
              ),
        front: Container(
          height: MediaQuery.of(context).size.height - 100,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              // Album Art
              FlipCard(
                back: Container(
                  height: 350.0,
                  width: 400.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        spreadRadius: 1.0,
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 30.0),
                  clipBehavior: Clip.hardEdge,
                  child: const Center(
                    child: Text("Back"),
                  ),
                ),
                // Album Art
                front: Stack(
                  children: [
                    Container(
                      height: 350.0,
                      width: 400.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            spreadRadius: 1.0,
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 30.0),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        albumArtImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: IconButton(
                          onPressed: () {
                            setFullscreen();
                          },
                          icon: Icon(
                            fullScreenMode == true
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Song title + Controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      spreadRadius: 1.0,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                    // Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Slider(
                        activeColor: Colors.grey[900],
                        inactiveColor: Colors.grey[500], //Color(0xaa6C63FF),
                        value: 75,
                        min: 0,
                        max: 100,
                        onChanged: (value) {
                          print("a");
                        },
                      ),
                    ),
                    // Controlls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Repeat Button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.repeat,
                            size: 26.0,
                          ),
                        ),
                        // Fast Rewind Button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.fast_rewind_rounded,
                            size: 36.0,
                          ),
                        ),
                        // Pause and Play Button
                        IconButton(
                          onPressed: () {
                            pausePlaySong();
                          },
                          icon: Icon(
                            isSongPlaying ? Icons.pause : Icons.play_arrow,
                            size: 36.0,
                          ),
                        ),
                        // Fast Forward Button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.fast_forward_rounded,
                            size: 36.0,
                          ),
                        ),
                        // Shuffle Button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.shuffle,
                            size: 26.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
