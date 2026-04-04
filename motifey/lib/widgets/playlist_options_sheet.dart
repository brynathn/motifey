import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/playlist_model.dart';
import '../services/api_service.dart';
import '../controller/auth_controller.dart';

class PlaylistOptionsSheet extends StatelessWidget {
  final Playlist playlist;

  const PlaylistOptionsSheet({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final username =
        AuthController.instance.currentUser?.username ?? "User";

    return FractionallySizedBox(
      heightFactor: 0.55,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            /// 🔘 DRAG HANDLE
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// 🎵 HEADER (COVER + INFO)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    playlist.playlistCover,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// 🔧 OPTIONS
            _buildItem(
              icon: Icons.edit,
              title: "Edit playlist",
              onTap: () {
                // nanti
              },
            ),

            _buildItem(
              icon: Icons.info_outline,
              title: "Name & details",
              onTap: () {
                // nanti
              },
            ),

            _buildItem(
              icon: Icons.delete,
              title: "Delete playlist",
              isDanger: true,
              onTap: () {
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon,
          color: isDanger ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }

  /// 🔥 CONFIRM DELETE
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Delete Playlist?",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "This action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.deletePlaylist(playlist.id);

                context.pop(); // close dialog
                context.pop(); // close sheet
                context.pop(); // back to previous screen
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}