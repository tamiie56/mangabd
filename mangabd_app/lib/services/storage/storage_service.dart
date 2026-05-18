import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StorageService {
  static const String _cloudName = 'dbabkcit1';
  static const String _uploadPreset = 'mangabd_preset';

  Future<String?> _uploadImage(Uint8List imageBytes, String folder) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadCover(String mangaId, Uint8List imageBytes) async {
    return await _uploadImage(imageBytes, 'mangabd/covers');
  }

  Future<String?> uploadPage(
    String mangaId,
    String chapterId,
    int pageIndex,
    Uint8List imageBytes,
  ) async {
    return await _uploadImage(
        imageBytes, 'mangabd/chapters/$mangaId/$chapterId');
  }

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
}