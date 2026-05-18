import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/manga_model.dart';
import '../../models/chapter_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../reader/reader_screen.dart';

class MangaDetailScreen extends StatefulWidget {
  final MangaModel manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final _firestoreService = FirestoreService();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  void _checkBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final result =
        await _firestoreService.isBookmarked(user.uid, widget.manga.id);
    if (mounted) setState(() => _isBookmarked = result);
  }

  void _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.toggleBookmark(user.uid, widget.manga);
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: _isBookmarked ? Colors.deepPurpleAccent : Colors.white,
                ),
                onPressed: _toggleBookmark,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.manga.coverUrl.isNotEmpty
                  ? Image.network(widget.manga.coverUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.deepPurple.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.menu_book,
                            color: Colors.deepPurple, size: 80),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${widget.manga.creatorName}',
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: widget.manga.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                              color: Colors.deepPurpleAccent, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.manga.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chapters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<ChapterModel>>(
            stream: _firestoreService.getChapters(widget.manga.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No chapters yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              final chapters = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(
                            manga: widget.manga,
                            chapter: chapter,
                          ),
                        ),
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${chapter.chapterNumber}',
                            style: const TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        'Chapter ${chapter.chapterNumber}: ${chapter.title}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${chapter.pageUrls.length} pages',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.play_arrow,
                          color: Colors.deepPurpleAccent),
                    );
                  },
                  childCount: chapters.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}