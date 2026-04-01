class Song {
  final String id; // Tambahkan ID agar mudah jika nanti mau delete/like
  final String title;
  final String artist;
  final String url;
  final String songCover;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.songCover,
  });

  // ✨ Tambahkan ini: Mengubah JSON dari Express ke Objek Song
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      url: json['url'] ?? '',
      songCover: json['cover'] ?? '', // DB pakai 'cover', model pakai 'songCover'
    );
  }
}