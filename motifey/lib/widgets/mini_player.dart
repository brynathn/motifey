import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motifey/controller/audio_controller.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudioController.instance;

    return StreamBuilder<int?>(
      // Mendengarkan index lagu yang sedang aktif
      stream: controller.currentIndexStream,
      builder: (context, indexSnapshot) {
        final currentIndex = indexSnapshot.data;
        
        // Jika tidak ada lagu yang diputar atau playlist kosong, jangan tampilkan apa-apa
        if (currentIndex == null || controller.currentPlaylist.isEmpty) {
          return const SizedBox.shrink();
        }

        // Ambil data lagu berdasarkan index saat ini
        final song = controller.currentPlaylist[currentIndex];

        return GestureDetector(
          onTap: () => context.push('/player'),
          
          /// 🔥 SWIPE CONTROL (Next/Previous)
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -200) {
              controller.next();
            } else if (velocity > 200) {
              controller.previous();
            }
          },

          child: Container(
            height: 68,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Beri sedikit margin agar tidak menempel ke pinggir layar
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Stack(
              children: [
                /// 🔥 PROGRESS BAR (Line tipis di bawah)
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: 10,
                  child: StreamBuilder<Duration>(
                    stream: controller.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? Duration.zero;
                      
                      return StreamBuilder<Duration?>(
                        stream: controller.durationStream,
                        builder: (context, durSnapshot) {
                          final duration = durSnapshot.data ?? Duration.zero;
                          
                          // Hitung progress (0.0 sampai 1.0)
                          final progress = duration.inMilliseconds > 0
                              ? position.inMilliseconds / duration.inMilliseconds
                              : 0.0;

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 2.5,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Row(
                  children: [
                    /// 🎵 COVER ALBUM (Update ke Image.network)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.songCover, // Menggunakan URL dari Supabase
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        // Tampilkan placeholder jika gambar gagal dimuat
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 46,
                          height: 46,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note, color: Colors.white54),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 🎵 INFO TEKS
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ▶️ PLAY/PAUSE BUTTON
                    StreamBuilder<bool>(
                      stream: controller.isPlayingStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            isPlaying ? controller.pause() : controller.play();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}