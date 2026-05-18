import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload cover image
  Future<String?> uploadCover(String mangaId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('covers/$mangaId.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload chapter page
  Future<String?> uploadPage(
    String mangaId,
    String chapterId,
    int pageIndex,
    Uint8List imageBytes,
  ) async {
    try {
      final ref = _storage
          .ref()
          .child('chapters/$mangaId/$chapterId/page_$pageIndex.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload multiple pages
  Future<List<String>> uploadPages(
    String mangaId,
    String chapterId,
    List<Uint8List> pages,
  ) async {
    List<String> urls = [];
    for (int i = 0; i < pages.length; i++) {
      final url = await uploadPage(mangaId, chapterId, i, pages[i]);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  // Delete cover
  Future<void> deleteCover(String mangaId) async {
    try {
      await _storage.ref().child('covers/$mangaId.jpg').delete();
    } catch (e) {
      return;
    }
  }
}