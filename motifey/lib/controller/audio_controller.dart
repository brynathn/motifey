import 'package:audio_service/audio_service.dart';

import '../models/song_model.dart';
import '../services/audio_handler.dart';

class AudioController {
  static final AudioController instance = AudioController._internal();
  factory AudioController() => instance;
  AudioController._internal();

  late MyAudioHandler _handler;

  List<Song> currentPlaylist = [];

  int? _lastIndex;

  /// 🔥 INIT
  void init(MyAudioHandler handler) {
    _handler = handler;

    _handler.currentIndexStream.listen((index) {
      _lastIndex = index;
    });
  }

  Stream<int?> get currentIndexStream => _handler.currentIndexStream;
  Stream<bool> get isPlayingStream => _handler.playingStream;
  Stream<Duration> get positionStream => _handler.positionStream;
  Stream<Duration?> get durationStream => _handler.durationStream;

  Song? get currentSong {
    final index = _lastIndex;
    if (index == null || index < 0 || index >= currentPlaylist.length) {
      return null;
    }
    return currentPlaylist[index];
  }

  /// 🔥 SET PLAYLIST (FIX COVER NOTIFICATION)
  Future<void> setPlaylist(List<Song> songs, int index) async {
    if (songs.isEmpty) return;

    currentPlaylist = songs;

    final List<MediaItem> mediaItems = [];

    for (var song in songs) {
      print("🎵 TITLE: ${song.title}");
      print("🖼 COVER PATH: ${song.songCover}");
      print("🔊 AUDIO PATH: ${song.url}");

      try {
        mediaItems.add(
          MediaItem(
            id: song.url,
            album: "Motifey",
            title: song.title,
            artist: song.artist,
            artUri: Uri.parse(song.songCover),
          ),
        );
      } catch (e) {
        print("❌ Image convert error: $e");

        mediaItems.add(
          MediaItem(
            id: song.url,
            album: "Motifey",
            title: song.title,
            artist: song.artist,
          ),
        );
      }
    }
    try{
      await _handler.setPlaylist(mediaItems, index);
      await _handler.play();

    } catch (e) {
      print("❌ Error setPlaylist: $e");
    }
  }

  Future<void> play() async {
    try {
      await _handler.play();
    } catch (e) {
      print("❌ play error: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _handler.pause();
    } catch (e) {
      print("❌ pause error: $e");
    }
  }

  Future<void> next() async {
    try {
      await _handler.skipToNext();
    } catch (e) {
      print("❌ next error: $e");
    }
  }

  Future<void> previous() async {
    try {
      await _handler.skipToPrevious();
    } catch (e) {
      print("❌ previous error: $e");
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _handler.seek(position);
    } catch (e) {
      print("❌ seek error: $e");
    }
  }
}