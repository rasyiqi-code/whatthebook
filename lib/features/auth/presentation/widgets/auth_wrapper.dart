import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/guest_home_page.dart';
import '../pages/user_profile_page.dart';
import '../../../books/presentation/pages/home_page.dart';
import '../../../books/presentation/pages/library_page.dart';
import '../../../books/presentation/pages/write/my_books_page.dart';
import '../../../achievements/presentation/pages/achievements_entrypoint.dart';
import 'role_aware_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show login page if not authenticated
        if (!snapshot.hasData || snapshot.data?.session == null) {
          return const GuestHomePage();
        }

        // Show main app if authenticated
        return MainScreen(
          currentIndex: _currentIndex,
          onIndexChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    // Define tabs
    final List<Widget> tabs = [
      const HomePage(), // 0
      const LibraryPage(), // 1
      const MyBooksPage(), // 2
      const AchievementsEntrypoint(), // 3
      const ProfileTab(), // 4
    ];

    // Ensure currentIndex is within bounds
    int safeIndex = widget.currentIndex;
    if (safeIndex >= tabs.length) {
      safeIndex = tabs.length - 1;
    }

    return RoleAwareNavigation(
      child: Scaffold(
        // Remove the app bar from main scaffold since pages have their own
        body: tabs[safeIndex],
        bottomNavigationBar: _buildBottomNav(safeIndex),
      ),
    );
  }

  Widget _buildBottomNav(int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: widget.onIndexChanged,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Library',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Tulis'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Achievements',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return const SizedBox();

    return UserProfilePage(userId: currentUser.id);
  }
}
