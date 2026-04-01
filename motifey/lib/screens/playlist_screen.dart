import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motifey/controller/audio_controller.dart';
import 'package:motifey/controller/auth_controller.dart';
import 'package:motifey/services/api_service.dart';
import 'package:motifey/models/song_model.dart';
import '../models/playlist_model.dart';
import '../widgets/play_button.dart';
import '../widgets/equalizer.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late Future<List<Song>> _songsFuture;
  List<Song> _loadedSongs = [];

  @override
  void initState() {
    super.initState();
    // 🔍 1. Panggil fetch songs saat layar diinisialisasi
    _songsFuture = ApiService.fetchSongsByPlaylist(widget.playlist.id);
  }

  // Fungsi untuk memutar lagu melalui AudioController
  void playPlaylist(int index) async {
    if (_loadedSongs.isEmpty) return;
    await AudioController.instance.setPlaylist(_loadedSongs, index);
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudioController.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, songSnapshot) {
          // --- STATE LOADING ---
          if (songSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } 
          
          // --- STATE ERROR ---
          else if (songSnapshot.hasError) {
            return const Center(
              child: Text(
                "Failed to load songs",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Simpan data lagu yang berhasil di-fetch
          _loadedSongs = songSnapshot.data ?? [];

          // --- UI UTAMA DENGAN STREAM ---
          return StreamBuilder<int?>(
            stream: controller.currentIndexStream,
            builder: (context, indexSnapshot) {
              final currentIndex = indexSnapshot.data;

              return StreamBuilder<bool>(
                stream: controller.isPlayingStream,
                builder: (context, playSnapshot) {
                  final isPlaying = playSnapshot.data ?? false;

                  // Cek apakah playlist ini sedang diputar (berdasarkan URL lagu pertama)
                  final isThisPlaylistPlaying = controller.currentPlaylist.isNotEmpty &&
                      _loadedSongs.isNotEmpty &&
                      controller.currentPlaylist.first.url == _loadedSongs.first.url;

                  return CustomScrollView(
                    slivers: [
                      /// 🔥 APP BAR (Sliver)
                      SliverAppBar(
                        expandedHeight: 300,
                        pinned: true,
                        backgroundColor: Colors.black,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                widget.playlist.playlistCover,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey[900]),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black, Colors.transparent, Colors.black],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// 🔥 HEADER INFO
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.playlist.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Playlist by ${AuthController.instance.currentUser?.username ?? 'User'}",
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.playlist.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Created at ${formatDate(widget.playlist.createdAt)}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 10),

                              /// 🔥 ACTION ROW (Play Button)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PlayButton(
                                    isPlaying: isThisPlaylistPlaying && isPlaying,
                                    onTap: () {
                                      if (!isThisPlaylistPlaying) {
                                        playPlaylist(0);
                                      } else {
                                        isPlaying ? controller.pause() : controller.play();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// 🔥 SONG LIST
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = _loadedSongs[index];

                            // Cek apakah lagu di index ini sedang diputar
                            final isCurrent = isThisPlaylistPlaying && currentIndex == index;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              onTap: () => playPlaylist(index),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  song.songCover,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey, width: 52, height: 52),
                                ),
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isCurrent ? Colors.green : Colors.white,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                song.artist,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              trailing: isCurrent
                                  ? Equalizer(isPlaying: isPlaying)
                                  : const Icon(Icons.more_vert, color: Colors.grey),
                            );
                          },
                          childCount: _loadedSongs.length,
                        ),
                      ),

                      // Memberikan space agar tidak tertutup Mini Player di bawah
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 180),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}