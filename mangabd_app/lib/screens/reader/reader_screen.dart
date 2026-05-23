import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/manga_model.dart';
import '../../models/chapter_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../../utils/auth_provider.dart';

class ReaderScreen extends StatefulWidget {
  final MangaModel manga;
  final ChapterModel chapter;

  const ReaderScreen({
    super.key,
    required this.manga,
    required this.chapter,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  bool _tracked = false;
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeController.forward();
    _trackRead();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _trackRead() async {
    if (_tracked) return;
    _tracked = true;
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      await _firestoreService.incrementChaptersRead(auth.user!.uid);
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            widget.chapter.pageUrls.isEmpty
                ? const Center(
                    child: Text(
                      'No pages available',
                      style: TextStyle(color: Color(0xFF4A7A55)),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.chapter.pageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.chapter.pageUrls[index],
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 400,
                            color: const Color(0xFF0D1F12),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF00C853),
                                      strokeWidth: 3,
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Page ${index + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFF4A7A55),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        errorBuilder: (ctx, err, st) => Container(
                          height: 200,
                          color: const Color(0xFF132718),
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded,
                                color: Color(0xFF4A7A55), size: 48),
                          ),
                        ),
                      );
                    },
                  ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.manga.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853)
                                      .withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Ch.${widget.chapter.chapterNumber} — ${widget.chapter.title}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}