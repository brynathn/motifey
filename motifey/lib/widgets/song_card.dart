import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        song.songCover,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}