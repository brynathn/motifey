import 'package:motifey/models/song_model.dart';

class Playlist {
  final String id;
  final String title;
  final String creator;
  final String playlistCover;
  final String description;
  final DateTime createdAt;
  final List<Song> songs;
  final int songCount;

  Playlist({
    required this.id,
    required this.title,
    required this.creator,
    required this.playlistCover,
    required this.description,
    required this.createdAt,
    required this.songs,
    required this.songCount,
  });

  // ✨ Tambahkan ini: Mengubah JSON dari Express ke Objek Playlist
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      title: json['title'],
      creator: json['creator_id'] ?? '', // Di DB namanya creator_id
      playlistCover: json['cover'] ?? '', // Di DB namanya cover
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      songs: [], // Default kosong, nanti diisi lewat fetchSongsByPlaylist
      songCount: json['song_count'] ?? 0, // Di DB namanya song_count
    );
  }
}