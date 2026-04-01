import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/mini_player.dart';
import '../widgets/profile_drawer.dart'; // Pastikan import drawer kamu

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  // 🔥 1. Tambahkan GlobalKey agar Drawer bisa dibuka dari screen anak (Home, Search, Library)
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  const MainScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return Scaffold(
      // 🔥 2. Pasang GlobalKey di sini
      key: scaffoldKey,
      
      // 🔥 3. Pasang Drawer di sini agar dia berada di atas Stack body
      drawer: const ProfileDrawer(),
      
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          /// 1. Konten Halaman Utama (Home, Search, Library)
          Positioned.fill(child: navigationShell),

          /// 2. Mini Player (Akan tertutup Drawer saat terbuka)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            left: 12,
            right: 12,
            bottom: isKeyboardOpen ? -100 : 90, 
            child: const MiniPlayer(),
          ),
          
          /// 3. Navbar (Akan tertutup Drawer saat terbuka)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            left: 0,
            right: 0,
            bottom: isKeyboardOpen ? -120 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isKeyboardOpen ? 0.0 : 1.0,
              child: _buildNavbar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: "Library"),
          ],
        ),
      ),
    );
  }
}