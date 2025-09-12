import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/role_service.dart';
import '../../domain/entities/user.dart';
import '../pages/admin/admin_panel_page.dart';
import '../../../books/presentation/pages/publisher_dashboard_page.dart';
import '../../../../core/injection/injection_container.dart';

class RoleAwareNavigation extends StatelessWidget {
  final Widget child;
  late final RoleService _roleService;

  RoleAwareNavigation({super.key, required this.child}) {
    _roleService = sl<RoleService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, drawer: _buildDrawer(context));
  }

  Widget _buildDrawer(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<UserRole?>(
      future: _roleService.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final userRole = snapshot.data ?? UserRole.reader;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'User',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userRole.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
              ),
              if (userRole == UserRole.admin) ...[
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Panel'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPanelPage(),
                      ),
                    );
                  },
                ),
              ],
              if (userRole == UserRole.publisher) ...[
                ListTile(
                  leading: const Icon(Icons.published_with_changes),
                  title: const Text('Publisher Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PublisherDashboardPage(),
                      ),
                    );
                  },
                ),
              ],
              if (userRole == UserRole.author ||
                  userRole == UserRole.admin) ...[
                ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text('My Books'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my-books');
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  _roleService.clearCache();
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
