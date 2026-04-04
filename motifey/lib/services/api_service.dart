import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.11:3000";

  /// 🔥 STREAM CONTROLLER
  static final StreamController<List<Playlist>> _playlistController =
      StreamController<List<Playlist>>.broadcast();

  static Stream<List<Playlist>> get playlistStream =>
      _playlistController.stream;

  /// 🔥 EMIT PLAYLIST (REALTIME UPDATE)
  static Future<void> emitPlaylists() async {
    try {
      if (_playlistController.isClosed) return;

      final data = await fetchPlaylists();
      _playlistController.add(data);
    } catch (e) {
      print("Emit error: $e");
    }
  }

  /// ================= AUTH =================

  static Future<Map<String, dynamic>?> signup(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Signup error: $e");
    }
    return null;
  }

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", data["token"]);
        await prefs.setString("user_data", jsonEncode(data["user"]));

        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>?> getLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString("user_data");
    if (userStr != null) return jsonDecode(userStr);
    return null;
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  /// ================= TOKEN =================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  /// ================= PLAYLIST =================

  static Future<List<Playlist>> fetchPlaylists() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/playlists"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Playlist.fromJson(json)).toList();
    }

    throw Exception("Failed to load playlists");
  }

  static Future<void> createPlaylist(
    String title,
    String cover,
    String songId,
  ) async {
    final token = await getToken();

    await http.post(
      Uri.parse("$baseUrl/playlists"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": title,
        "cover": cover,
        "songId": songId,
      }),
    );

    /// 🔥 AUTO UPDATE UI
    await emitPlaylists();
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final token = await getToken();

    await http.delete(
      Uri.parse("$baseUrl/playlists/$playlistId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    /// 🔥 AUTO UPDATE UI
    await emitPlaylists();
  }

  /// ================= SONG =================

  static Future<List<Song>> fetchSongsByPlaylist(String playlistId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/playlists/$playlistId/songs"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Song.fromJson(json)).toList();
    }

    return [];
  }

  static Future<void> addSongToPlaylist(
      String playlistId, String songId) async {
    final token = await getToken();

    await http.post(
      Uri.parse("$baseUrl/playlists/$playlistId/songs"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "songId": songId,
      }),
    );

    /// 🔥 UPDATE (optional tapi bagus)
    await emitPlaylists();
  }

  static Future<void> removeSongFromPlaylist(
      String playlistId, String songId) async {
    final token = await getToken();

    await http.delete(
      Uri.parse("$baseUrl/playlists/$playlistId/songs/$songId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    /// 🔥 UPDATE
    await emitPlaylists();
  }

  /// ================= EXTRA =================

  static Future<List<Map<String, dynamic>>> fetchPlaylistsWithStatus(
      String songId) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/playlists-with-status/$songId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  static Future<List<Playlist>> fetchPlaylistsWithSongs() async {
  try {
    final playlists = await fetchPlaylists();

    await Future.wait(
      playlists.map((p) async {
        final songs = await fetchSongsByPlaylist(p.id);
        p.songs.clear(); // 🔥 biar gak duplicate
        p.songs.addAll(songs);
      }),
    );

    return playlists;
  } catch (e) {
    print("fetchPlaylistsWithSongs error: $e");
    return [];
  }
}

  /// 🔥 CLEANUP (optional)
  static void disposeStream() {
    _playlistController.close();
  }
}