import 'package:flutter/material.dart';
import '../../models/manga_model.dart';
import '../../models/chapter_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../reader/reader_screen.dart';

class MangaDetailScreen extends StatelessWidget {
  final MangaModel manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          // App Bar with cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: manga.coverUrl.isNotEmpty
                  ? Image.network(manga.coverUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.deepPurple.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.menu_book,
                            color: Colors.deepPurple, size: 80),
                      ),
                    ),
            ),
          ),

          // Manga info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${manga.creatorName}',
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: manga.genres.map((genre) {
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
                    manga.description,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
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

          // Chapters list
          StreamBuilder<List<ChapterModel>>(
            stream: firestoreService.getChapters(manga.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child:
                        CircularProgressIndicator(color: Colors.deepPurple),
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
                            manga: manga,
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