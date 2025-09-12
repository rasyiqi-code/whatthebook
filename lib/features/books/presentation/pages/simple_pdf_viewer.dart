import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/reading_progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection_container.dart' as di;
import '../bloc/pdf_bookmark_bloc.dart';
import '../widgets/pdf_bookmark_list_widget.dart';
import '../widgets/add_pdf_bookmark_dialog.dart';
import '../bloc/pdf_bookmark_event.dart';

class AdvancedPdfViewer extends StatefulWidget {
  final String bookId; // UUID dari tabel books
  final String pdfUrl;
  final String? title;

  const AdvancedPdfViewer({
    super.key,
    required this.bookId,
    required this.pdfUrl,
    this.title,
  });

  @override
  State<AdvancedPdfViewer> createState() => _AdvancedPdfViewerState();
}

class _AdvancedPdfViewerState extends State<AdvancedPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isDark = false;
  PdfScrollDirection _scrollDirection = PdfScrollDirection.vertical;
  PdfPageLayoutMode _pageLayoutMode = PdfPageLayoutMode.continuous;

  late final ReadingProgressService _readingProgressService;
  int _currentPage = 1;
  int _totalPages = 1;
  double _progress = 0.0;
  bool _progressLoaded = false;

  @override
  void initState() {
    super.initState();
    _readingProgressService = ReadingProgressService(
      supabase: Supabase.instance.client,
    );
    _loadPdfProgress();
  }

  Future<void> _loadPdfProgress() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      // Fallback ke local storage
      final prefs = await SharedPreferences.getInstance();
      final localPage = prefs.getInt('pdf_progress_${widget.pdfUrl}');
      if (localPage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pdfViewerController.jumpToPage(localPage);
        });
      }
      setState(() => _progressLoaded = true);
      return;
    }
    final progress = await _readingProgressService.getProgressForPdf(
      pdfBookId: widget.bookId,
      userId: userId,
    );
    if (progress != null &&
        progress.progressPercentage != null &&
        _totalPages > 1) {
      final page = (progress.progressPercentage! * _totalPages / 100)
          .round()
          .clamp(1, _totalPages);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pdfViewerController.jumpToPage(page);
      });
    }
    setState(() => _progressLoaded = true);
  }

  Future<void> _savePdfProgress(int page) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (_totalPages < 1) return;
    final progressPercentage = (page / _totalPages * 100)
        .clamp(0, 100)
        .toDouble();
    if (userId == null) {
      // Fallback ke local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pdf_progress_${widget.pdfUrl}', page);
      return;
    }
    await _readingProgressService.saveOrUpdateProgress(
      pdfBookId: widget.bookId,
      chapterId: null,
      progressPercentage: progressPercentage,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PdfBookmarkBloc>(
      create: (_) => di.sl<PdfBookmarkBloc>(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.title ?? 'Baca Buku'),
            backgroundColor: const Color(0xFF8B4513),
            actions: [
              Builder(
                builder: (buttonContext) => IconButton(
                  icon: const Icon(Icons.bookmark),
                  tooltip: 'Lihat Bookmark',
                  onPressed: () {
                    showModalBottomSheet(
                      context: buttonContext,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (modalContext) => BlocProvider.value(
                        value: context.read<PdfBookmarkBloc>(),
                        child: SafeArea(
                          child: SizedBox(
                            height:
                                MediaQuery.of(buttonContext).size.height * 0.6,
                            child: PdfBookmarkListWidget(
                              pdfBookId: widget.bookId,
                              onBookmarkTap: (bookmark) {
                                Navigator.of(modalContext).pop();
                                _pdfViewerController.jumpToPage(
                                  bookmark.page + 1,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add),
                tooltip: 'Tambah Bookmark di Halaman Ini',
                onPressed: () async {
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login untuk menambah bookmark'),
                      ),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AddPdfBookmarkDialog(
                      onSave: (note, bookmarkName) {
                        context.read<PdfBookmarkBloc>().add(
                          AddPdfBookmarkEvent(
                            pdfBookId: widget.bookId,
                            page: _currentPage - 1,
                            note: note,
                            bookmarkName: bookmarkName,
                            userId: userId,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu_book),
                tooltip: 'Daftar Isi',
                onPressed: () {
                  _pdfViewerKey.currentState?.openBookmarkView();
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Cari Teks',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gunakan Ctrl+F atau search bar di toolbar PDF Viewer.',
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Ganti Tema',
                onPressed: () {
                  setState(() {
                    _isDark = !_isDark;
                  });
                },
              ),
              PopupMenuButton<String>(
                tooltip: 'Mode Tampilan',
                onSelected: (value) {
                  if (value == 'vertical') {
                    setState(
                      () => _scrollDirection = PdfScrollDirection.vertical,
                    );
                  } else if (value == 'horizontal') {
                    setState(
                      () => _scrollDirection = PdfScrollDirection.horizontal,
                    );
                  } else if (value == 'single') {
                    setState(() => _pageLayoutMode = PdfPageLayoutMode.single);
                  } else if (value == 'continuous') {
                    setState(
                      () => _pageLayoutMode = PdfPageLayoutMode.continuous,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'vertical',
                    child: Text('Scroll Vertikal'),
                  ),
                  const PopupMenuItem(
                    value: 'horizontal',
                    child: Text('Scroll Horizontal'),
                  ),
                  const PopupMenuItem(
                    value: 'single',
                    child: Text('Flipbook (Single Page)'),
                  ),
                  const PopupMenuItem(
                    value: 'continuous',
                    child: Text('Continuous'),
                  ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              Theme(
                data: _isDark ? ThemeData.dark() : ThemeData.light(),
                child: SfPdfViewer.network(
                  widget.pdfUrl,
                  key: _pdfViewerKey,
                  controller: _pdfViewerController,
                  scrollDirection: _scrollDirection,
                  pageLayoutMode: _pageLayoutMode,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  canShowPaginationDialog: true,
                  enableTextSelection: true,
                  onDocumentLoadFailed: (details) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'PDF gagal dimuat: \n${details.description}',
                        ),
                      ),
                    );
                  },
                  onDocumentLoaded: (details) {
                    setState(() {
                      _totalPages = details.document.pages.count;
                    });
                    if (!_progressLoaded) _loadPdfProgress();
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                      _progress = _totalPages > 1
                          ? _currentPage / _totalPages
                          : 0.0;
                    });
                    _savePdfProgress(details.newPageNumber);
                  },
                ),
              ),
              if (_totalPages > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: Colors.brown[100],
                    color: Colors.brown[700],
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF8B4513),
            child: const Icon(Icons.fullscreen),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: SfPdfViewer.network(
                      widget.pdfUrl,
                      controller: PdfViewerController(),
                      scrollDirection: _scrollDirection,
                      pageLayoutMode: _pageLayoutMode,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      canShowPaginationDialog: true,
                      enableTextSelection: true,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
