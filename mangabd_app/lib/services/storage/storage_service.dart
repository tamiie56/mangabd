import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadCoverImage(String mangaId, File file) async {
    try {
      final ref = _storage.ref().child('covers/$mangaId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadChapterPage(
      String mangaId, String chapterId, String pageId, File file) async {
    try {
      final ref =
          _storage.ref().child('chapters/$mangaId/$chapterId/$pageId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadProfilePhoto(String userId, File file) async {
    try {
      final ref = _storage.ref().child('profiles/$userId.jpg');
      await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadProfilePhotoBytes(
      String userId, Uint8List bytes) async {
    try {
      final ref = _storage.ref().child('profiles/$userId.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      return;
    }
  }
}