import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/user_role_chip.dart';
import 'admin_books_page.dart';
import 'package:file_picker/file_picker.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  bool _isUsersExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final response = await _client
          .from('books')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _books = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('role', ascending: true)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _promoteUser(String userId, UserRole newRole) async {
    try {
      String functionName;
      switch (newRole) {
        case UserRole.author:
          functionName = 'promote_to_author';
          break;
        case UserRole.publisher:
          functionName = 'promote_to_publisher';
          break;
        case UserRole.admin:
          functionName = 'promote_to_admin';
          break;
        default:
          return;
      }

      await _client.rpc(functionName, params: {'user_id': userId});
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating user role: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      // Admin Panel Title
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                        child: const Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Stats Header
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            children: [
                              _buildStatCard(
                                'Total Authors',
                                (_users
                                        .where((u) => u['role'] == 'author')
                                        .length)
                                    .toString(),
                                Icons.people,
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Contributors',
                                (_users
                                        .where(
                                          (u) =>
                                              u['role'] == 'author' ||
                                              u['role'] == 'publisher',
                                        )
                                        .length)
                                    .toString(),
                                Icons.edit_note,
                                Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Published Books',
                                _books
                                    .where((b) => b['status'] == 'published')
                                    .length
                                    .toString(),
                                Icons.book,
                                Colors.purple,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Draft Books',
                                _books
                                    .where((b) => b['status'] == 'draft')
                                    .length
                                    .toString(),
                                Icons.edit_document,
                                Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Completed Books',
                                _books
                                    .where((b) => b['status'] == 'completed')
                                    .length
                                    .toString(),
                                Icons.task_alt,
                                Colors.teal,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Users Accordion
                      _buildAccordionSection(
                        title: 'User Management',
                        icon: Icons.people,
                        count: _users.length,
                        color: Colors.blue,
                        isExpanded: _isUsersExpanded,
                        onToggle: () {
                          setState(() {
                            _isUsersExpanded = !_isUsersExpanded;
                          });
                        },
                        content: _buildUsersContent(),
                      ),

                      const SizedBox(height: 8),

                      // Books Management
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: const AdminBooksPage(),
                      ),

                      // --- Banner Management Section ---
                      const SizedBox(height: 24),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Homepage Banner Management',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.upload),
                                label: const Text('Upload New Banner'),
                                onPressed: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(type: FileType.image);
                                  if (result != null &&
                                      result.files.single.bytes != null) {
                                    final file = result.files.single;
                                    final fileName =
                                        'banner_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
                                    final storage =
                                        Supabase.instance.client.storage;
                                    final uploadRes = await storage
                                        .from('banners')
                                        .uploadBinary(fileName, file.bytes!);
                                    if (uploadRes.isNotEmpty) {
                                      final publicUrl = storage
                                          .from('banners')
                                          .getPublicUrl(fileName);
                                      // Insert to banners table
                                      await Supabase.instance.client
                                          .from('banners')
                                          .insert({
                                            'image_url': publicUrl,
                                            'is_active': true,
                                          });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Banner uploaded successfully!',
                                            ),
                                          ),
                                        );
                                        setState(() {}); // Refresh
                                      }
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: Supabase.instance.client
                                    .from('banners')
                                    .select()
                                    .order('created_at', ascending: false),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final banners = snapshot.data!;
                                  if (banners.isEmpty) {
                                    return const Text(
                                      'No banners uploaded yet.',
                                    );
                                  }
                                  return Column(
                                    children: banners.map((banner) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: ListTile(
                                          leading: Image.network(
                                            banner['image_url'],
                                            width: 100,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(Icons.broken_image),
                                          ),
                                          title: Text(banner['image_url']),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final url =
                                                  banner['image_url'] as String;
                                              final fileName = url
                                                  .split('/')
                                                  .last;
                                              // Delete from storage
                                              await Supabase
                                                  .instance
                                                  .client
                                                  .storage
                                                  .from('banners')
                                                  .remove([fileName]);
                                              // Delete from table
                                              await Supabase.instance.client
                                                  .from('banners')
                                                  .delete()
                                                  .eq('id', banner['id']);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Banner deleted.',
                                                    ),
                                                  ),
                                                );
                                                setState(() {}); // Refresh
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required IconData icon,
    required int count,
    required Color color,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 51),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$count ${count == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 51),
                        ),
                      ),
                    ),
                    child: content,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    if (_users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No users found',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final currentRole = user['role'] as String;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              user['full_name'] ?? user['email'],
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  user['email'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                UserRoleChip(
                  role: UserRole.values.firstWhere(
                    (r) => r.toString().split('.').last == currentRole,
                    orElse: () => UserRole.reader,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<UserRole>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.primary,
              ),
              onSelected: (UserRole role) {
                _promoteUser(user['id'], role);
              },
              itemBuilder: (BuildContext context) => [
                if (currentRole != 'author')
                  const PopupMenuItem(
                    value: UserRole.author,
                    child: Text('Promote to Author'),
                  ),
                if (currentRole != 'publisher')
                  const PopupMenuItem(
                    value: UserRole.publisher,
                    child: Text('Promote to Publisher'),
                  ),
                if (currentRole != 'admin')
                  const PopupMenuItem(
                    value: UserRole.admin,
                    child: Text('Promote to Admin'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 76)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
