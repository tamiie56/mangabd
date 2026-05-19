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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _controller,
          onChanged: _onSearch,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Search manga...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      _onSearch('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasSearched
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Search for manga',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Type a title to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No results found',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final manga = _results[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MangaDetailScreen(manga: manga),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: manga.coverUrl.isNotEmpty
                                        ? Image.network(
                                            manga.coverUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) => Container(
                                              color: colorScheme.primary
                                                  .withOpacity(0.2),
                                              child: Center(
                                                child: Icon(
                                                    Icons.menu_book,
                                                    color: colorScheme
                                                        .primary,
                                                    size: 48),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: colorScheme.primary
                                                .withOpacity(0.2),
                                            child: Center(
                                              child: Icon(
                                                  Icons.menu_book,
                                                  color:
                                                      colorScheme.primary,
                                                  size: 48),
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        manga.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${manga.totalChapters} chapters',
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}