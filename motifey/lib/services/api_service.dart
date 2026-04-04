import 'package:motifey/models/song_model.dart';

import '../models/playlist_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = "http://192.168.1.11:3000";

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
        return null;
      } catch (e) {
        print("Signup error: $e");
        return null;
      }
    }

  /// 🔑 LOGIN
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
          
          // Simpan token dan user data (seperti yang sudah kamu buat)
          await prefs.setString("token", data["token"]);
          await prefs.setString("user_data", jsonEncode(data["user"])); 
            
          return true;
        } 
        return false; 
      } catch(e) {
        print("Login error: $e");
        return false;
      }
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
  
  static Future<List<Playlist>> fetchPlaylists() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/playlists"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      // 🎯 Jauh lebih simpel menggunakan .fromJson
      return data.map((json) => Playlist.fromJson(json)).toList();
    }
    throw Exception("Failed to load playlists");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data (token & user info)
  }

  static Future<Map<String, dynamic>?> getLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString("user_data");
    if (userStr != null) return jsonDecode(userStr);
    return null;
  }

  static Future<List<Song>> fetchSongsByPlaylist(String playlistId) async {
  final response = await http.get(
    Uri.parse("$baseUrl/playlists/$playlistId/songs"),
  );

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    // 🎯 Langsung jadi List objek Song
    return data.map((json) => Song.fromJson(json)).toList();
  }
  return [];
}

static Future<List<Playlist>> fetchPlaylistsWithSongs() async {
  final playlists = await fetchPlaylists();
  
  // Ambil lagu untuk setiap playlist secara paralel agar cepat
  await Future.wait(playlists.map((p) async {
    final songs = await fetchSongsByPlaylist(p.id);
    p.songs.addAll(songs); // Masukkan lagu ke dalam objek playlist
  }));

  return playlists;
}

static Future<List<Map<String, dynamic>>> fetchPlaylistsWithStatus(String songId) async {
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

static Future<void> addSongToPlaylist(String playlistId, String songId) async {
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
}

static Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
  final token = await getToken();

  await http.delete(
    Uri.parse("$baseUrl/playlists/$playlistId/songs/$songId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );
}
}
