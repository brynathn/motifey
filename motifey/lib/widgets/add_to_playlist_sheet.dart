import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final String songId;

  const AddToPlaylistSheet({super.key, required this.songId});

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  List<Map<String, dynamic>> playlists = [];
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    final data = await ApiService.fetchPlaylistsWithStatus(widget.songId);

    setState(() {
      playlists = data;
      isLoading = false;
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
              // 🔥 update count biar realtime
              "song_count": isAdded
                  ? (p["song_count"] ?? 1) - 1
                  : (p["song_count"] ?? 0) + 1,
            };
          }
          return p;
        }).toList();
      });

      // 🔥 Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdded ? "Removed from playlist" : "Added to playlist",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print("Toggle error: $e");
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔘 DRAG INDICATOR
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

            const SizedBox(height: 20),

            /// CONTENT
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (playlists.isEmpty)
              const Text(
                "No playlists found",
                style: TextStyle(color: Colors.white70),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final isAdded = playlist["is_added"] == true;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,

                      /// 🎵 COVER
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          playlist["cover"] ?? "",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                        ),
                      ),

                      /// 📝 TITLE
                      title: Text(
                        playlist["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      /// 🎧 SONG COUNT
                      subtitle: Text(
                        "${playlist["song_count"] ?? 0} songs",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),

                      /// ➕ / ✔ BUTTON
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isAdded ? Icons.check : Icons.add,
                          key: ValueKey(isAdded),
                          color: isUpdating
                              ? Colors.grey
                              : Colors.white,
                        ),
                      ),

                      onTap: () {
                        togglePlaylist(playlist["id"], isAdded);
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