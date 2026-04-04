import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final String songId;
  final String songCover; 

  const AddToPlaylistSheet({super.key, required this.songId, required this.songCover});

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  List<Map<String, dynamic>> playlists = [];
  List<Map<String, dynamic>> filteredPlaylists = [];

  bool isLoading = true;
  bool isUpdating = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPlaylists();

    searchController.addListener(() {
      filterPlaylists();
    });
  }

  Future<void> loadPlaylists() async {
    final data = await ApiService.fetchPlaylistsWithStatus(widget.songId);

    setState(() {
      playlists = data;
      filteredPlaylists = data;
      isLoading = false;
    });
  }

  void filterPlaylists() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredPlaylists = playlists.where((p) {
        return p["title"].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> togglePlaylist(String playlistId, bool isAdded) async {
    if (isUpdating) return;

    setState(() => isUpdating = true);

    try {
      if (isAdded) {
        await ApiService.removeSongFromPlaylist(playlistId, widget.songId);
      } else {
        await ApiService.addSongToPlaylist(playlistId, widget.songId);
      }

      setState(() {
        playlists = playlists.map((p) {
          if (p["id"] == playlistId) {
            return {
              ...p,
              "is_added": !isAdded,
              "song_count": isAdded
                  ? (p["song_count"] ?? 1) - 1
                  : (p["song_count"] ?? 0) + 1,
            };
          }
          return p;
        }).toList();

        filterPlaylists();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdded ? "Removed from playlist" : "Added to playlist",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

Future<void> createPlaylist() async {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "New Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Playlist name",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(context);

              // 🔥 CREATE + AUTO ADD + SET COVER
              await ApiService.createPlaylist(
                name,
                widget.songCover, // cover dari lagu
                widget.songId,    // auto add lagu
              );

              await loadPlaylists(); // refresh

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Playlist created & song added"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9, // 🔥 bikin sheet tinggi
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              /// 🔘 DRAG
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// TITLE
              const Text(
                "Saved in",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// 🔍 SEARCH
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search playlist...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// CONTENT
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      /// 🎵 PLAYLIST LIST
                      ...filteredPlaylists.map((playlist) {
                        final isAdded = playlist["is_added"] == true;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              playlist["cover"] ?? "",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[800],
                                child: const Icon(Icons.music_note,
                                    color: Colors.white),
                              ),
                            ),
                          ),

                          title: Text(
                            playlist["title"],
                            style: const TextStyle(color: Colors.white),
                          ),

                          subtitle: Text(
                            "${playlist["song_count"] ?? 0} songs",
                            style: const TextStyle(color: Colors.white60),
                          ),

                          trailing: Icon(
                            isAdded ? Icons.check : Icons.add,
                            color: Colors.white,
                          ),

                          onTap: () {
                            togglePlaylist(playlist["id"], isAdded);
                          },
                        );
                      }),

                      const SizedBox(height: 20),

                      /// ➕ CREATE PLAYLIST
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                        title: const Text(
                          "Create new playlist",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: createPlaylist,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}