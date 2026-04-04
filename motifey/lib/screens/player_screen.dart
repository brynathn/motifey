import 'package:flutter/material.dart';
import 'package:motifey/controller/audio_controller.dart';
import 'package:motifey/widgets/add_to_playlist_sheet.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudioController.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol Back manual jika dibutuhkan, atau biarkan default
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Now Playing",
          style: TextStyle(fontSize: 14, letterSpacing: 1, color: Colors.grey),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<int?>(
        stream: controller.currentIndexStream,
        builder: (context, indexSnapshot) {
          final currentIndex = indexSnapshot.data;
          
          if (currentIndex == null || controller.currentPlaylist.isEmpty) {
            return const Center(
              child: Text("No song playing", style: TextStyle(color: Colors.white)),
            );
          }

          final song = controller.currentPlaylist[currentIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                /// 🎵 COVER ALBUM (Update ke Image.network)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1), // Dikurangi agar tidak terlalu silau
                          blurRadius: 50,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        song.songCover, // Menggunakan URL
                        height: MediaQuery.of(context).size.width * 0.85,
                        width: MediaQuery.of(context).size.width * 0.85,
                        fit: BoxFit.cover,
                        // Placeholder jika internet lambat
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: MediaQuery.of(context).size.width * 0.85,
                          width: MediaQuery.of(context).size.width * 0.85,
                          color: Colors.grey[900],
                          child: const Icon(Icons.music_note, color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                /// 📝 INFO LAGU
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              _showAddToPlaylist(context, song.id, song.songCover);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.artist,
                        style: const TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// ⏱ SLIDER & PROGRESS
                StreamBuilder<Duration>(
                  stream: controller.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;

                    return StreamBuilder<Duration?>(
                      stream: controller.durationStream,
                      builder: (context, durSnapshot) {
                        final duration = durSnapshot.data ?? Duration.zero;
                        
                        final maxSeconds = duration.inSeconds > 0 ? duration.inSeconds : 1;
                        final currentSeconds = position.inSeconds.clamp(0, maxSeconds);

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                min: 0,
                                max: maxSeconds.toDouble(),
                                value: currentSeconds.toDouble(),
                                onChanged: (value) {
                                  controller.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatTime(position), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(formatTime(duration), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                /// ▶️ CONTROL BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                      iconSize: 45,
                      onPressed: controller.previous,
                    ),
                    StreamBuilder<bool>(
                      stream: controller.isPlayingStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                          ),
                          iconSize: 90,
                          onPressed: () {
                            isPlaying ? controller.pause() : controller.play();
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                      iconSize: 45,
                      onPressed: controller.next,
                    ),
                  ],
                ),

                const Spacer(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showAddToPlaylist(
  BuildContext context,
  String songId,
  String songCover,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return AddToPlaylistSheet(
        songId: songId,
        songCover: songCover,
      );
    },
  );
}