import 'package:flutter/material.dart';
import '../../models/manga_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../home/manga_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _firestoreService = FirestoreService();
  List<MangaModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _onSearch(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    final results = await _firestoreService.searchManga(value);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
        _hasSearched = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A3320)
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onSearch,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0D1F12),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search manga...',
              hintStyle: const TextStyle(color: Color(0xFF4A7A55)),
              border: InputBorder.none,
              filled: false,
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF00C853), size: 22),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF4A7A55), size: 20),
                      onPressed: () {
                        _controller.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            )
          : !_hasSearched
              ? _buildSearchPrompt()
              : _results.isEmpty
                  ? _buildNoResults()
                  : _buildResults(isDark),
    );
  }

  Widget _buildSearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C853).withValues(alpha: 0.2),
                  const Color(0xFF00E676).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.search_rounded,
                size: 40, color: Color(0xFF00C853)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for manga',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Type a title to get started',
            style: TextStyle(color: Color(0xFF4A7A55), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4A7A55).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: Color(0xFF4A7A55)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term',
            style: TextStyle(color: Color(0xFF4A7A55), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final manga = _results[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MangaDetailScreen(manga: manga)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132718) : Colors.white,
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
                        manga.coverUrl.isNotEmpty
                            ? Image.network(
                                manga.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) =>
                                    _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${manga.totalChapters} ch',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    manga.title,
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
                ),
              ],
            ),
          ),
        );
      },
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