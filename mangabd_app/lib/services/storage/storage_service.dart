import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StorageService {
  static const String _uploadPreset = 'mangabd_preset';
  static const String _cloudName = 'dbabkcit1';
  static const String _imageBaseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
  static const String _videoBaseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/video/upload';

  Future<String?> uploadCoverImageBytes(
      String mangaId, Uint8List bytes) async {
    try {
      final uri = Uri.parse(_imageBaseUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = 'covers/$mangaId'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$mangaId.jpg',
        ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadChapterPageBytes(
      String mangaId, String chapterId, String pageId, Uint8List bytes) async {
    try {
      final uri = Uri.parse(_imageBaseUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = 'chapters/$mangaId/$chapterId/$pageId'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$pageId.jpg',
        ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadProfilePhotoBytes(
      String userId, Uint8List bytes) async {
    try {
      final uri = Uri.parse(_imageBaseUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = 'profiles/$userId'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$userId.jpg',
        ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadChatMediaBytes(
      Uint8List bytes, String extension, bool isVideo) async {
    try {
      final uri = Uri.parse(isVideo ? _videoBaseUrl : _imageBaseUrl);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final folder = isVideo ? 'chat/videos' : 'chat/images';
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = '$folder/$timestamp'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'chat_media.$extension',
        ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    } catch (e) {
      return null;
    }
  }
}