import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler
  with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    /// 🔥 1. SYNC PLAYBACK STATE
    _player.playbackEventStream.map(_transformEvent).listen((state){
      playbackState.add(state);
    });

    /// 🔥 2. UPDATE MEDIA ITEM SAAT LAGU BERGANTI
    _player.currentIndexStream.listen((index) {
      if (index == null) return;

      final q = queue.value;
      if (index >= 0 && index < q.length) {
        final item = q[index];

        mediaItem.add(
          item.copyWith(
            duration: _player.duration,
          ),
        );
      }
    });

    /// 🔥 3. UPDATE DURATION (INI KUNCI PROGRESS BAR)
    _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current == null || duration == null) return;

      mediaItem.add(
        current.copyWith(duration: duration),
      );
    });
  }

  /// 🔥 SET PLAYLIST
Future<void> setPlaylist(List<MediaItem> items, int index) async {
  try {
    // 1. Update antrean di audio_service (notifikasi)
    await updateQueue(items);

    // 2. Gunakan setAudioSources (jamak) sesuai rekomendasi terbaru
    // Ini secara otomatis akan membuat ConcatenatingAudioSource di internal engine
    await _player.setAudioSources(
      items.map((item) {
        return AudioSource.uri(
            Uri.parse(item.id),
          tag: item, // Sangat penting agar currentIndexStream mengenali MediaItem ini
        );
      }).toList(),
      initialIndex: index,
      initialPosition: Duration.zero,
    );

    // 3. Update MediaItem yang sedang aktif saat ini tanpa menunggu Stream
    // Ini mencegah UI 'blank' atau menampilkan lagu lama saat transisi
    if (index >= 0 && index < items.length) {
      mediaItem.add(items[index]);
    }
    
  } catch (e) {
    print("❌ Error setPlaylist: $e");
  }
}

  /// 🔥 CONTROLS
  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  /// 🔥 STREAM UNTUK UI
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// 🔥 TRANSFORM STATE (UNTUK NOTIFICATION)
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],

      /// 🔥 PENTING (URUTAN HARUS SESUAI INDEX)
      androidCompactActionIndices: const [0, 1, 2],

      /// 🔥 ENABLE SEEK (BIAR PROGRESS BAR MUNCUL)
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },

      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState] ?? AudioProcessingState.idle,

      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,

      /// 🔥 WAJIB UNTUK PROGRESS UPDATE
      updateTime: DateTime.now(),
    );
  }
}