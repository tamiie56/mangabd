import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/manga_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../../services/storage/storage_service.dart';

class EditMangaScreen extends StatefulWidget {
  final MangaModel manga;
  const EditMangaScreen({super.key, required this.manga});

  @override
  State<EditMangaScreen> createState() => _EditMangaScreenState();
}

class _EditMangaScreenState extends State<EditMangaScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final List<String> _allGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama',
    'Fantasy', 'Horror', 'Romance', 'Sci-Fi',
    'Slice of Life', 'Thriller',
  ];
  late List<String> _selectedGenres;
  bool _isLoading = false;
  Uint8List? _newCoverBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.manga.title);
    _descriptionController =
        TextEditingController(text: widget.manga.description);
    _selectedGenres = List.from(widget.manga.genres);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _newCoverBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    setState(() => _isLoading = true);

    String coverUrl = widget.manga.coverUrl;
    if (_newCoverBytes != null) {
      coverUrl =
          await StorageService().uploadCoverImageBytes(
                  widget.manga.id, _newCoverBytes!) ??
              coverUrl;
    }

    await FirestoreService().updateManga(widget.manga.id, {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'genres': _selectedGenres,
      'coverUrl': coverUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Manga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickCover,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colorScheme.primary, width: 2),
                  ),
                  child: _newCoverBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _newCoverBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : widget.manga.coverUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.manga.coverUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    color: colorScheme.primary,
                                    size: 40),
                                const SizedBox(height: 8),
                                const Text('Change Cover',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12)),
                              ],
                            ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Title',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter manga title',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter manga description',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Genres',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allGenres.map((genre) {
                final selected = _selectedGenres.contains(genre);
                return GestureDetector(
                  onTap: () => setState(() {
                    selected
                        ? _selectedGenres.remove(genre)
                        : _selectedGenres.add(genre);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}