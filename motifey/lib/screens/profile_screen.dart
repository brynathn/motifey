import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: ApiService.fetchPlaylists(),
        builder: (context, snapshot) {
          final playlists = snapshot.data ?? [];

          return Column(
            children: [
              const SizedBox(height: 20),

              /// 👤 PROFILE
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(auth.currentUser?.profileImage ?? 
                    "https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public/profile/default_profile.png"),
              ),

              const SizedBox(height: 10),

              Text(
                auth.currentUser?.username ?? "Unknown User",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),

              const SizedBox(height: 20),

              /// 🎧 PLAYLIST LIST
              const Text("Your Playlists", style: TextStyle(color: Colors.white)),

              Expanded(
                child: ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];

                    return ListTile(
                      leading: Image.network(playlist.playlistCover, width: 50),
                      title: Text(playlist.title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(playlist.description, style: const TextStyle(color: Colors.grey)),
                    );
                  },
                ),
              ),

              /// 🚪 LOGOUT
              ElevatedButton(
                onPressed: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("Logout"),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}