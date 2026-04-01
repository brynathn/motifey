import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motifey/screens/main_screen.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../models/search_result.dart';
import '../services/api_service.dart';
import '../controller/audio_controller.dart';
import '../widgets/profile_drawer.dart';
import '../controller/auth_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Playlist> allPlaylists = [];
  List<SearchResult> results = [];
  bool isLoading = true;

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.fetchPlaylistsWithSongs();
      if (!mounted) return;

      setState(() {
        allPlaylists = data;
        results = data.map((p) => SearchResult(type: 'playlist', data: p)).toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        results = allPlaylists.map((p) => SearchResult(type: 'playlist', data: p)).toList();
      });
      return;
    }

    List<SearchResult> temp = [];
    final seenSongs = <String>{};

    for (var playlist in allPlaylists) {
      if (playlist.title.toLowerCase().contains(q)) {
        temp.add(SearchResult(type: 'playlist', data: playlist));
      }

      for (var song in playlist.songs) {
        final key = "${song.title}-${song.artist}";
        if (!seenSongs.contains(key) &&
            (song.title.toLowerCase().contains(q) || song.artist.toLowerCase().contains(q))) {
          seenSongs.add(key);
          temp.add(SearchResult(type: 'song', data: song));
        }
      }
    }
    setState(() => results = temp);
  }

  void _playSong(Song song, Playlist playlist) async {
    if (playlist.songs.isEmpty) {
      final songs = await ApiService.fetchSongsByPlaylist(playlist.id);
      playlist.songs.addAll(songs);
    }
    final index = playlist.songs.indexWhere((s) => s.url == song.url);
    if (index != -1) {
      await AudioController.instance.setPlaylist(playlist.songs, index);
    }
  }

  Playlist? _findPlaylistOfSong(Song song) {
    try {
      return allPlaylists.firstWhere((p) => p.songs.any((s) => s.url == song.url));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      drawer: const ProfileDrawer(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🏠 CUSTOM HEADER (Ganti AppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        MainScreen.scaffoldKey.currentState?.openDrawer();
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(AuthController.instance.currentUser?.profileImage ?? ""),
                      ),
                    );
                  }),
                  const SizedBox(width: 16),
                  const Text(
                    "Search",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            /// 🔍 MODERN SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _searchFocusNode,
                  onChanged: _search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Songs, artists, or playlists",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _controller.clear();
                              _search("");
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            /// 🔥 RESULTS
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : results.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.only(top: 10, bottom: isKeyboardOpen ? 20 : 120),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final item = results[index];
                            if (item.type == 'playlist') {
                              return _buildPlaylistTile(item.data as Playlist);
                            } else {
                              return _buildSongTile(item.data as Song);
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("No results found", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPlaylistTile(Playlist playlist) {
    return ListTile(
      onTap: () => context.push('/playlist', extra: playlist),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(image: NetworkImage(playlist.playlistCover), fit: BoxFit.cover),
        ),
      ),
      title: Text(playlist.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: const Text("Playlist", style: TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
    );
  }

  Widget _buildSongTile(Song song) {
    final playlist = _findPlaylistOfSong(song);
    return ListTile(
      onTap: playlist == null ? null : () => _playSong(song, playlist),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(image: NetworkImage(song.songCover), fit: BoxFit.cover),
        ),
      ),
      title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text("${song.artist} • Song", style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.more_vert, color: Colors.grey),
    );
  }
}