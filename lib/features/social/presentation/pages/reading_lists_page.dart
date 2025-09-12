import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/social_bloc.dart';
import '../bloc/social_event.dart';
import '../bloc/social_state.dart';
import '../widgets/reading_list_card.dart';
import 'create_reading_list_page.dart';
import 'reading_list_details_page.dart';

class ReadingListsPage extends StatefulWidget {
  const ReadingListsPage({super.key});

  @override
  State<ReadingListsPage> createState() => _ReadingListsPageState();
}

class _ReadingListsPageState extends State<ReadingListsPage> {
  @override
  void initState() {
    super.initState();
    _loadReadingLists();
  }

  void _loadReadingLists() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      context.read<SocialBloc>().add(
        GetUserReadingListsRequested(currentUser.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  Supabase.instance.client.auth.currentUser?.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Reading Lists Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Bacaan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadReadingLists,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SocialBloc, SocialState>(
                    builder: (context, state) {
                      if (state is SocialLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ReadingListsLoaded) {
                        if (state.readingLists.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada daftar bacaan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Buat daftar bacaan pertama Anda!',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.readingLists.length,
                          itemBuilder: (context, index) {
                            final readingList = state.readingLists[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ReadingListCard(
                                readingList: readingList,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReadingListDetailsPage(
                                            readingList: readingList,
                                          ),
                                    ),
                                  ).then((deleted) {
                                    if (deleted == true) {
                                      _loadReadingLists();
                                    }
                                  });
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus Daftar Bacaan'),
                                      content: const Text(
                                        'Apakah Anda yakin ingin menghapus daftar bacaan ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            context.read<SocialBloc>().add(
                                              DeleteReadingListRequested(
                                                readingList.id,
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }

                      return const Center(
                        child: Text('Gagal memuat daftar bacaan'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateReadingListPage(),
            ),
          );
          if (result == true) {
            _loadReadingLists();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
