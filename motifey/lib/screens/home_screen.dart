import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motifey/screens/main_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/playlist_model.dart';
import '../services/api_service.dart';
import '../widgets/profile_drawer.dart';
import '../controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();

    // 🔥 load pertama kali
    ApiService.emitPlaylists();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  void _openPlaylist(Playlist playlist) {
    if (!mounted) return;
    context.push('/playlist', extra: playlist);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const ProfileDrawer(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<List<Playlist>>(
          stream: ApiService.playlistStream,
          builder: (context, snapshot) {
            /// 🔄 LOADING
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            final playlists = snapshot.data!;

            /// ❌ EMPTY
            if (playlists.isEmpty) {
              return const Center(
                child: Text("No playlists available",
                    style: TextStyle(color: Colors.white)),
              );
            }

            final gridPlaylists = playlists.take(6).toList();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
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
                                    "https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public/profile/default_profile.png",
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 16),
                        const Text(
                          "Motifey 🎧",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// CONTENT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        /// GRID
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: gridPlaylists.map((playlist) {
                            return GestureDetector(
                              onTap: () => _openPlaylist(playlist),
                              child: Container(
                                width: (screenWidth - 44) / 2,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                              left: Radius.circular(4)),
                                      child: Image.network(
                                        playlist.playlistCover,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            Container(
                                                width: 56,
                                                color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        playlist.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          "Made For You",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// HORIZONTAL
                        SizedBox(
                          height: 210,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];

                              return GestureDetector(
                                onTap: () => _openPlaylist(playlist),
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.network(
                                          playlist.playlistCover,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              Container(
                                            height: 150,
                                            width: 150,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        playlist.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        AuthController.instance.currentUser
                                                ?.username ??
                                            'User',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}