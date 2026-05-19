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
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
    _checkFollow();
  }

  void _checkBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final result =
        await _firestoreService.isBookmarked(user.uid, widget.manga.id);
    if (mounted) setState(() => _isBookmarked = result);
  }

  void _checkFollow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (user.uid == widget.manga.creatorId) return;
    final result = await _firestoreService.isFollowing(
        user.uid, widget.manga.creatorId);
    if (mounted) setState(() => _isFollowing = result);
  }

  void _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.toggleBookmark(user.uid, widget.manga);
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  void _toggleFollow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.toggleFollow(
        user.uid, widget.manga.creatorId);
    if (mounted) setState(() => _isFollowing = !_isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwnManga = user?.uid == widget.manga.creatorId;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: _isBookmarked
                      ? colorScheme.primary
                      : Colors.white,
                ),
                onPressed: _toggleBookmark,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.manga.coverUrl.isNotEmpty
                  ? Image.network(widget.manga.coverUrl,
                      fit: BoxFit.cover)
                  : Container(
                      color:
                          colorScheme.primary.withValues(alpha: 0.3),
                      child: Center(
                        child: Icon(Icons.menu_book,
                            color: colorScheme.primary, size: 80),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'by ${widget.manga.creatorName}',
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 14),
                        ),
                      ),
                      if (!isOwnManga)
                        StreamBuilder<int>(
                          stream: _firestoreService.getFollowerCount(
                              widget.manga.creatorId),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return OutlinedButton.icon(
                              onPressed: _toggleFollow,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _isFollowing
                                      ? colorScheme.primary
                                      : Colors.grey,
                                ),
                                foregroundColor: _isFollowing
                                    ? colorScheme.primary
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                              ),
                              icon: Icon(
                                _isFollowing
                                    ? Icons.check
                                    : Icons.person_add_outlined,
                                size: 16,
                              ),
                              label: Text(
                                _isFollowing
                                    ? 'Following ($count)'
                                    : 'Follow ($count)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: widget.manga.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.manga.description,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chapters',
                    style: TextStyle(
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
                  child: Center(child: CircularProgressIndicator()),
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
                          color: colorScheme.primary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${chapter.chapterNumber}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        'Chapter ${chapter.chapterNumber}: ${chapter.title}',
                      ),
                      subtitle: Text(
                        '${chapter.pageUrls.length} pages',
                        style:
                            const TextStyle(color: Colors.grey),
                      ),
                      trailing: Icon(Icons.play_arrow,
                          color: colorScheme.primary),
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