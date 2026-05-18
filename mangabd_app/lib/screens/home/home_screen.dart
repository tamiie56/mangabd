import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_provider.dart';
import '../../models/manga_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../creator/creator_dashboard_screen.dart';
import '../home/manga_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'MangaBD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            if (auth.isCreator)
              IconButton(
                icon: const Icon(Icons.dashboard, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatorDashboardScreen(),
                  ),
                ),
              ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.deepPurpleAccent,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ForYouTab(),
            _FollowingTab(userId: auth.user?.uid ?? ''),
          ],
        ),
      ),
    );
  }
}

class _ForYouTab extends StatelessWidget {
  final _firestoreService = FirestoreService();

  _ForYouTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MangaModel>>(
      stream: _firestoreService.getMangas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No manga yet.\nBe the first to upload!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }
        return _MangaGrid(mangas: snapshot.data!);
      },
    );
  }
}

class _FollowingTab extends StatelessWidget {
  final String userId;
  final _firestoreService = FirestoreService();

  _FollowingTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Center(
        child: Text('Please login', style: TextStyle(color: Colors.grey)),
      );
    }

    return StreamBuilder<List<MangaModel>>(
      stream: _firestoreService.getFollowingMangas(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Follow some creators to see their manga here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }
        return _MangaGrid(mangas: snapshot.data!);
      },
    );
  }
}

class _MangaGrid extends StatelessWidget {
  final List<MangaModel> mangas;
  const _MangaGrid({required this.mangas});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        return _MangaCard(manga: mangas[index]);
      },
    );
  }
}

class _MangaCard extends StatelessWidget {
  final MangaModel manga;
  const _MangaCard({required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MangaDetailScreen(manga: manga)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: manga.coverUrl.isNotEmpty
                    ? Image.network(
                        manga.coverUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.deepPurple.withOpacity(0.3),
                        child: const Center(
                          child: Icon(Icons.menu_book,
                              color: Colors.deepPurple, size: 48),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${manga.totalChapters} chapters',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}