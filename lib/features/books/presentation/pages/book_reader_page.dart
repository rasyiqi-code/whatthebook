import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/injection/injection_container.dart' as di;
import '../../../../core/services/pdf_export_service.dart';
import '../widgets/editor/utils/markdown_formatter.dart';
import '../../data/datasources/reading_progress_service.dart';
import '../bloc/bookmark_bloc.dart';
import '../bloc/bookmark_event.dart';
import '../widgets/bookmark_list_widget.dart';
import '../widgets/add_bookmark_dialog.dart';
import '../../domain/entities/bookmark.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatthebook/core/services/logger_service.dart';

class BookReaderPage extends StatefulWidget {
  final String bookId;
  final String? initialChapterId;
  final String bookTitle;

  const BookReaderPage({
    super.key,
    required this.bookId,
    this.initialChapterId,
    required this.bookTitle,
  });

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage>
    with TickerProviderStateMixin {
  // Data
  List<Map<String, dynamic>> chapters = [];
  int currentChapterIndex = 0;
  List<String> currentPages = [];
  int currentPageIndex = 0;
  bool isLoading = true;

  // Reading settings
  double fontSize = 16.0;
  double lineHeight = 1.5;
  bool isDarkMode = false;
  String fontFamily = 'Default';
  double pageMargin = 24.0;

  // UI Controllers
  late PageController pageController;
  late AnimationController settingsAnimationController;
  late AnimationController progressAnimationController;
  bool showSettings = false;
  bool showProgress = false;
  bool showAppBar = true;

  // Reading progress
  double readingProgress = 0.0;
  int totalPages = 0;
  int currentGlobalPage = 0;

  // Reading state
  String? lastReadChapterId;
  int? lastReadPageIndex;

  // Bookmark state
  late final BookmarkBloc _bookmarkBloc;
  bool showBookmarkList = false;

  // Search functionality
  bool showSearch = false;
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];
  TextEditingController searchController = TextEditingController();

  // Reading time estimation
  int estimatedReadingTimeMinutes = 0;

  late final ReadingProgressService _readingProgressService;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _readingProgressService = ReadingProgressService(
      supabase: Supabase.instance.client,
    );
    _bookmarkBloc = di.sl<BookmarkBloc>();
    _loadBook();
    _loadReadingSettings();
  }

  @override
  void dispose() {
    pageController.dispose();
    settingsAnimationController.dispose();
    progressAnimationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    try {
      // Load all chapters
      final response = await Supabase.instance.client
          .from('chapters')
          .select()
          .eq('book_id', widget.bookId)
          .order('chapter_number');

      setState(() {
        chapters = List<Map<String, dynamic>>.from(response);
      });

      // Find initial chapter
      if (widget.initialChapterId != null) {
        final index = chapters.indexWhere(
          (chapter) => chapter['id'] == widget.initialChapterId,
        );
        if (index != -1) {
          currentChapterIndex = index;
        }
      }

      await _loadCurrentChapter();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading book: $e')));
    }
  }

  Future<void> _loadCurrentChapter() async {
    if (chapters.isEmpty) return;

    try {
      final chapter = chapters[currentChapterIndex];
      final content = chapter['content'] ?? '';

      // Parse content and split into pages
      final text = _parseContentToText(content);
      final pages = _splitTextIntoPages(text);

      setState(() {
        currentPages = pages;
        currentPageIndex = 0;
        isLoading = false;
      });

      _calculateProgress();
      _calculateReadingTime();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _parseContentToText(String content) {
    if (content.isEmpty) return '';

    try {
      // Try to parse as JSON (editor blocks)
      final List<dynamic> blocks = jsonDecode(content);
      final rawText = blocks
          .map((block) {
            // Handle block structure from our BlockEditor
            if (block is Map<String, dynamic>) {
              return block['content']?.toString() ?? '';
            }
            return block.toString();
          })
          .where((text) => text.isNotEmpty)
          .join('\n\n');

      return rawText;
    } catch (e) {
      // If not JSON, return as plain text
      return content;
    }
  }

  List<String> _splitTextIntoPages(String text) {
    if (text.isEmpty) return [''];

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
    );

    final style = TextStyle(
      fontSize: fontSize,
      height: lineHeight,
      fontFamily: fontFamily == 'Default' ? null : fontFamily,
    );

    // Calculate available space
    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - (pageMargin * 2);
    final availableHeight =
        screenSize.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        (pageMargin * 2) -
        100; // Extra space for controls

    final pages = <String>[];
    final words = text.split(' ');
    String currentPage = '';

    for (int i = 0; i < words.length; i++) {
      final testPage = currentPage.isEmpty
          ? words[i]
          : '$currentPage ${words[i]}';

      textPainter.text = TextSpan(text: testPage, style: style);
      textPainter.layout(maxWidth: availableWidth);

      if (textPainter.height > availableHeight && currentPage.isNotEmpty) {
        pages.add(currentPage.trim());
        currentPage = words[i];
      } else {
        currentPage = testPage;
      }
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage.trim());
    }

    return pages.isEmpty ? [''] : pages;
  }

  void _calculateProgress() {
    // Calculate total pages across all chapters
    totalPages = 0;
    currentGlobalPage = 0;

    for (int i = 0; i < chapters.length; i++) {
      final chapterContent = _parseContentToText(chapters[i]['content'] ?? '');
      final chapterPages = _splitTextIntoPages(chapterContent);

      if (i < currentChapterIndex) {
        currentGlobalPage += chapterPages.length;
      } else if (i == currentChapterIndex) {
        currentGlobalPage += currentPageIndex + 1;
      }

      totalPages += chapterPages.length;
    }

    readingProgress = totalPages > 0 ? currentGlobalPage / totalPages : 0.0;
  }

  void _calculateReadingTime() {
    // Average reading speed: 200-250 words per minute
    const averageWordsPerMinute = 225;

    int totalWords = 0;
    for (final chapter in chapters) {
      totalWords += (chapter['word_count'] as num?)?.toInt() ?? 0;
    }

    setState(() {
      estimatedReadingTimeMinutes = (totalWords / averageWordsPerMinute)
          .round();
    });
  }

  Future<void> _loadReadingSettings() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      setState(() {
        lastReadChapterId = null;
        lastReadPageIndex = null;
      });
      if (userId == null) {
        // If no user, try local storage
        final prefs = await SharedPreferences.getInstance();
        final localState = prefs.getString('reading_state_${widget.bookId}');
        if (localState != null) {
          final Map<String, dynamic> savedState = jsonDecode(localState);
          setState(() {
            lastReadChapterId = savedState['last_read_chapter'];
            lastReadPageIndex = savedState['last_read_page'];
          });
        }
        return;
      }
      try {
        // Ambil progress dari ReadingProgressService
        final progress = await _readingProgressService.getProgress(
          bookId: widget.bookId,
          userId: userId,
        );
        setState(() {
          if (progress != null) {
            lastReadChapterId = progress.chapterId;
            // lastReadPageIndex tetap 0, resume ke awal chapter
          }
        });
      } catch (e) {
        logger.error('Error loading reading progress: $e');
        // If Supabase fails (offline or table missing), try local storage
        final prefs = await SharedPreferences.getInstance();
        final localState = prefs.getString('reading_state_${widget.bookId}');
        if (localState != null) {
          final Map<String, dynamic> savedState = jsonDecode(localState);
          setState(() {
            lastReadChapterId = savedState['last_read_chapter'];
            lastReadPageIndex = savedState['last_read_page'];
          });
        }
      }
    } catch (e) {
      logger.error('Error in reading settings: $e');
    }
  }

  Future<void> saveReadingState() async {
    try {
      logger.debug('=== SAVE READING STATE START ===');
      logger.debug('Attempting to save reading state...');

      // Only attempt to save if we have chapters
      if (chapters.isEmpty) {
        logger.warning('No chapters to save');
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      logger.debug('Current user ID: $userId');
      logger.debug('Current chapter index: $currentChapterIndex');
      logger.debug('Current page index: $currentPageIndex');
      logger.debug('Book ID: ${widget.bookId}');

      // Always save to local storage first as backup
      final prefs = await SharedPreferences.getInstance();
      final localState = {
        'book_id': widget.bookId,
        'last_read_chapter': chapters[currentChapterIndex]['id'],
        'last_read_page': currentPageIndex,
        'last_read_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString(
        'reading_state_${widget.bookId}',
        jsonEncode(localState),
      );
      logger.info('Saved to local storage successfully');

      if (userId == null) {
        logger.warning('No user ID - only local storage saved');
        return;
      }

      final now = DateTime.now();
      final chapterId = chapters[currentChapterIndex]['id'];

      try {
        // Calculate progress percentage based on current page and total pages
        final progressPercentage = (currentGlobalPage / totalPages * 100)
            .clamp(0, 100)
            .toDouble();

        logger.debug('Saving to Supabase...');

        // Simpan progress ke ReadingProgressService
        await _readingProgressService.saveOrUpdateProgress(
          bookId: widget.bookId,
          chapterId: chapterId,
          progressPercentage: progressPercentage,
          userId: userId,
        );
      } catch (e) {
        logger.error('Error saving to Supabase: $e');
        // If Supabase save fails (offline), save to local storage
        final prefs = await SharedPreferences.getInstance();
        final localState = {
          'book_id': widget.bookId,
          'last_read_chapter': chapterId,
          'last_read_page': currentPageIndex,
          'last_read_at': now.toIso8601String(),
        };
        await prefs.setString(
          'reading_state_${widget.bookId}',
          jsonEncode(localState),
        );
      }
    } catch (e) {
      logger.error('Error saving reading state: $e');
    }
  }

  void _addBookmark() {
    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        onSave: (note, bookmarkName) {
          _bookmarkBloc.add(
            AddBookmarkEvent(
              bookId: widget.bookId,
              chapterId: chapters[currentChapterIndex]['id'],
              pageIndex: currentPageIndex,
              note: note,
              bookmarkName: bookmarkName,
            ),
          );
        },
      ),
    );
  }

  void _showBookmarkList() {
    setState(() {
      showBookmarkList = !showBookmarkList;
      if (showBookmarkList) showProgress = false;
    });
    if (showBookmarkList) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (modalContext) => BlocProvider.value(
          value: _bookmarkBloc,
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Bookmarks'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(modalContext).pop(),
                    ),
                  ),
                  Expanded(
                    child: BookmarkListWidget(
                      bookId: widget.bookId,
                      onBookmarkTap: (bookmark) {
                        Navigator.of(modalContext).pop();
                        _jumpToBookmark(bookmark);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).whenComplete(() {
        setState(() {
          showBookmarkList = false;
        });
      });
    }
  }

  void _showChapterList() {
    setState(() {
      showProgress = !showProgress;
      if (showProgress) showBookmarkList = false;
    });
    if (showProgress) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text('Daftar Chapter'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final isCurrentChapter = index == currentChapterIndex;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isCurrentChapter ? Colors.blue[50] : null,
                        child: ListTile(
                          title: Text(
                            chapter['title'] ?? 'Chapter ${index + 1}',
                            style: TextStyle(
                              fontWeight: isCurrentChapter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text('Chapter ${index + 1}'),
                          trailing: isCurrentChapter
                              ? const Icon(Icons.play_arrow, color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              currentChapterIndex = index;
                              currentPageIndex = 0;
                              showProgress = false;
                            });
                            _loadCurrentChapter();
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ).whenComplete(() {
        setState(() {
          showProgress = false;
        });
      });
    }
  }

  void _jumpToBookmark(Bookmark bookmark) {
    // Find the chapter index
    final chapterIndex = chapters.indexWhere(
      (chapter) => chapter['id'] == bookmark.chapterId,
    );

    if (chapterIndex != -1) {
      final isSameChapter = chapterIndex == currentChapterIndex;
      setState(() {
        currentChapterIndex = chapterIndex;
        currentPageIndex = bookmark.pageIndex ?? 0;
        showBookmarkList = false;
      });

      if (isSameChapter) {
        // Langsung loncat ke halaman jika masih di chapter yang sama
        WidgetsBinding.instance.addPostFrameCallback((_) {
          pageController.jumpToPage(currentPageIndex);
        });
      } else {
        // Jika pindah chapter, tunggu _loadCurrentChapter selesai, lalu loncat ke halaman
        _loadCurrentChapter().then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            pageController.jumpToPage(currentPageIndex);
          });
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumped to bookmark: ${bookmark.bookmarkName ?? 'Bookmark'}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final results = <Map<String, dynamic>>[];

    for (int chapterIndex = 0; chapterIndex < chapters.length; chapterIndex++) {
      final chapter = chapters[chapterIndex];
      final content = _parseContentToText(chapter['content'] ?? '');
      final pages = _splitTextIntoPages(content);

      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        final page = pages[pageIndex];
        final lowerPage = page.toLowerCase();
        final lowerQuery = query.toLowerCase();

        if (lowerPage.contains(lowerQuery)) {
          results.add({
            'chapterIndex': chapterIndex,
            'pageIndex': pageIndex,
            'chapterTitle': chapter['title'] ?? 'Chapter ${chapterIndex + 1}',
            'pageContent': page,
            'matchIndex': lowerPage.indexOf(lowerQuery),
          });
        }
      }
    }

    setState(() {
      searchResults = results;
    });
  }

  void _jumpToSearchResult(Map<String, dynamic> result) {
    final chapterIndex = result['chapterIndex'] as int;
    final pageIndex = result['pageIndex'] as int;

    setState(() {
      currentChapterIndex = chapterIndex;
      currentPageIndex = pageIndex;
      showSearch = false;
      searchQuery = '';
      searchResults = [];
    });

    _loadCurrentChapter();
  }

  void toggleSettings() {
    setState(() {
      showSettings = !showSettings;
    });
    if (showSettings) {
      settingsAnimationController.forward();
    } else {
      settingsAnimationController.reverse();
    }
  }

  void toggleProgress() {
    setState(() {
      showProgress = !showProgress;
    });
    if (showProgress) {
      progressAnimationController.forward();
    } else {
      progressAnimationController.reverse();
    }
  }

  void toggleSearch() {
    setState(() {
      showSearch = !showSearch;
      if (!showSearch) {
        searchQuery = '';
        searchResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: showAppBar ? _buildAppBar() : null,
      body: Stack(
        children: [
          _buildMainContent(),
          if (showSettings) _buildSettingsPanel(),
          if (showProgress) _buildProgressPanel(),
          if (showSearch) _buildSearchPanel(),
          if (showBookmarkList) _buildBookmarkPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.bookTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (chapters.isNotEmpty)
            Text(
              'Chapter ${currentChapterIndex + 1}',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_add),
          onPressed: _addBookmark,
          tooltip: 'Tambah Bookmark di Halaman Ini',
        ),
        IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: _showBookmarkList,
          tooltip: 'Lihat Bookmark',
        ),
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: _showChapterList,
          tooltip: 'Lihat Daftar Chapter',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: toggleSearch,
          tooltip: 'Cari dalam Buku',
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: () => PdfExportService.exportBookToPdf(
            bookTitle: widget.bookTitle,
            chapters: chapters,
            context: context,
          ),
          tooltip: 'Export ke PDF',
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            saveReadingState();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reading progress saved manually'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Simpan Progress Baca',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: toggleSettings,
          tooltip: 'Pengaturan',
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          currentPageIndex = index;
        });
        _calculateProgress();
        saveReadingState();
      },
      itemCount: currentPages.length,
      itemBuilder: (context, index) {
        return buildPage(currentPages[index]);
      },
    );
  }

  Widget _buildBookmarkPanel() {
    return AnimatedBuilder(
      animation: progressAnimationController,
      builder: (context, child) {
        return Positioned(
          left: -300 + (300 * progressAnimationController.value),
          top: 0,
          bottom: 0,
          width: 300,
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Bookmarks'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _showBookmarkList,
                    ),
                  ),
                  Expanded(
                    child: BookmarkListWidget(
                      bookId: widget.bookId,
                      onBookmarkTap: _jumpToBookmark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressPanel() {
    return AnimatedBuilder(
      animation: progressAnimationController,
      builder: (context, child) {
        return Positioned(
          left: -300 + (300 * progressAnimationController.value),
          top: 0,
          bottom: 0,
          width: 300,
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Reading Progress'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: toggleProgress,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        final isCurrentChapter = index == currentChapterIndex;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isCurrentChapter ? Colors.blue[50] : null,
                          child: ListTile(
                            title: Text(
                              chapter['title'] ?? 'Chapter ${index + 1}',
                              style: TextStyle(
                                fontWeight: isCurrentChapter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text('Chapter ${index + 1}'),
                            trailing: isCurrentChapter
                                ? const Icon(
                                    Icons.play_arrow,
                                    color: Colors.blue,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                currentChapterIndex = index;
                                currentPageIndex = 0;
                                showProgress = false;
                              });
                              _loadCurrentChapter();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchPanel() {
    return AnimatedBuilder(
      animation: progressAnimationController,
      builder: (context, child) {
        return Positioned(
          left: -300 + (300 * progressAnimationController.value),
          top: 0,
          bottom: 0,
          width: 300,
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Search'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: toggleSearch,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search in book...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: performSearch,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(result['chapterTitle']),
                            subtitle: Text(
                              result['pageContent'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _jumpToSearchResult(result),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsPanel() {
    return AnimatedBuilder(
      animation: settingsAnimationController,
      builder: (context, child) {
        return Positioned(
          right: -300 + (300 * settingsAnimationController.value),
          top: 0,
          bottom: 0,
          width: 300,
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Reading Settings'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: toggleSettings,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Font size
                        Text(
                          'Font Size',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          value: fontSize,
                          min: 12.0,
                          max: 24.0,
                          divisions: 12,
                          label: fontSize.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              fontSize = value;
                            });
                            _loadCurrentChapter(); // Recalculate pages
                          },
                        ),
                        const SizedBox(height: 16),

                        // Line height
                        Text(
                          'Line Height',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          value: lineHeight,
                          min: 1.0,
                          max: 2.0,
                          divisions: 10,
                          label: lineHeight.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              lineHeight = value;
                            });
                            _loadCurrentChapter(); // Recalculate pages
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dark mode
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          value: isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              isDarkMode = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Font family
                        Text(
                          'Font Family',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        DropdownButton<String>(
                          value: fontFamily,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'Default',
                              child: Text('Default'),
                            ),
                            DropdownMenuItem(
                              value: 'serif',
                              child: Text('Serif'),
                            ),
                            DropdownMenuItem(
                              value: 'monospace',
                              child: Text('Monospace'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                fontFamily = value;
                              });
                              _loadCurrentChapter(); // Recalculate pages
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Page margin
                        Text(
                          'Page Margin',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          value: pageMargin,
                          min: 16.0,
                          max: 48.0,
                          divisions: 8,
                          label: pageMargin.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              pageMargin = value;
                            });
                            _loadCurrentChapter(); // Recalculate pages
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPage(String content) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      height: lineHeight,
      color: isDarkMode ? Colors.white : Colors.black,
      fontFamily: fontFamily == 'Default' ? null : fontFamily,
    );

    return Container(
      padding: EdgeInsets.all(pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RichText(
                text: MarkdownFormatter.formatText(content, baseStyle),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${currentPageIndex + 1} of ${currentPages.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '${(readingProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
