import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controller/auth_controller.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: NetworkImage(auth.currentUser?.profileImage ?? 
                              "https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public/profile/default_profile.png"),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          auth.currentUser?.username ?? "Unknown User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/profile');
                          },
                          child: const Text(
                            "View Profile",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, indent: 20, endIndent: 20),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Colors.white),
                  title: const Text("Settings", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Logika settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white),
                  title: const Text("Listening History", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Logika history
                  },
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              // Jarak aman dari MiniPlayer & Bottom Nav Bar
              bottom: MediaQuery.of(context).padding.bottom + 20, 
            ),
            child: ListTile(
              // Diberi bentuk agar terlihat seperti button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.red.withValues(alpha: 0.1),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                auth.logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}