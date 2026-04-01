import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motifey/screens/main_screen.dart';
import '../models/playlist_model.dart';
import '../services/api_service.dart';
import '../widgets/profile_drawer.dart';
import '../controller/auth_controller.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<Playlist>> _playlistFuture;

  @override
  void initState() {
    super.initState();
    // Menggunakan fetchPlaylists (pastikan backend sudah update query song_count)
    _playlistFuture = ApiService.fetchPlaylists();
  }

  void _openPlaylist(Playlist playlist) {
    context.push('/playlist', extra: playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      backgroundColor: Colors.black,
      // AppBar dihapus untuk diganti dengan Custom Header di body
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📚 CUSTOM HEADER (Simetris dengan Home & Search)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Builder(builder: (context) {
                    final auth = AuthController.instance;
                    return GestureDetector(
                      onTap: () {
                        MainScreen.scaffoldKey.currentState?.openDrawer();
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          auth.currentUser?.profileImage ?? 
                          "https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public/profile/default_profile.png"
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 16),
                  const Text(
                    "Your Library",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 CONTENT LIST
            Expanded(
              child: FutureBuilder<List<Playlist>>(
                future: _playlistFuture,
                builder: (context, snapshot) {
                  // --- STATE LOADING ---
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }

                  // --- STATE ERROR ---
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Error loading library",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _playlistFuture = ApiService.fetchPlaylists();
                            }),
                            child: const Text("Retry", style: TextStyle(color: Colors.green)),
                          )
                        ],
                      ),
                    );
                  }

                  final playlists = snapshot.data ?? [];

                  // --- STATE KOSONG ---
                  if (playlists.isEmpty) {
                    return const Center(
                      child: Text(
                        "No playlists found",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  // --- LIST VIEW ---
                  return ListView.builder(
                    // Memberikan padding bawah agar tidak tertutup MiniPlayer
                    padding: const EdgeInsets.only(bottom: 120, top: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];

                      return ListTile(
                        onTap: () => _openPlaylist(playlist),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            playlist.playlistCover,
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 55,
                              height: 55,
                              color: Colors.grey[900],
                              child: const Icon(Icons.music_note, color: Colors.white24),
                            ),
                          ),
                        ),
                        title: Text(
                          playlist.title,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "${AuthController.instance.currentUser?.username ?? 'User'} • ${playlist.songCount} songs",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        trailing: const Icon(Icons.more_vert, color: Colors.grey),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}