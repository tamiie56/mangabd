import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore/firestore_service.dart';
import '../../models/manga_model.dart';
import '../home/manga_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login',
              style: TextStyle(color: Color(0xFF4A7A55))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Bookmarks',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD60A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_rounded,
                      color: Color(0xFFFFD60A), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Saved',
                    style: TextStyle(
                      color: Color(0xFFFFD60A),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getBookmarks(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF00C853)),
            );
          }
          final bookmarks = snapshot.data ?? [];
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD60A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.bookmark_rounded,
                        size: 40, color: Color(0xFFFFD60A)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bookmarks yet.',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bookmark manga to read them later.',
                    style:
                        TextStyle(color: Color(0xFF4A7A55), fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final b = bookmarks[index];
              final manga = MangaModel(
                id: b['mangaId'] ?? '',
                title: b['title'] ?? '',
                description: '',
                coverUrl: b['coverUrl'] ?? '',
                creatorId: '',
                creatorName: '',
                totalChapters: b['totalChapters'] ?? 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MangaDetailScreen(manga: manga),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132718)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              (b['coverUrl'] ?? '').toString().isNotEmpty
                                  ? Image.network(
                                      b['coverUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) =>
                                          _buildPlaceholder(),
                                    )
                                  : _buildPlaceholder(),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD60A),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.bookmark_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['title'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0D1F12),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${b['totalChapters'] ?? 0} chapters',
                              style: const TextStyle(
                                  color: Color(0xFF4A7A55), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00A844)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 48),
      ),
    );
  }
}