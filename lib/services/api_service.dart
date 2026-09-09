import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://72.60.201.218:8000",
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Future<String> renderReel({
    required File musicFile,
    required List<File> photoFiles,
    required String templateId,
    required String aspectRatio,
    required String quality,
    required bool watermark,
    int? audioStart,
    int? audioEnd,
    String? titleText,
    String? titleBg,
    int? titleDuration,
    Function(double progress)? onProgress,
  }) async {
    final formData = FormData();

    // Attach music
    formData.files.add(MapEntry(
      "music",
      await MultipartFile.fromFile(
        musicFile.path,
        filename: musicFile.path.split(Platform.pathSeparator).last,
      ),
    ));

    // Attach photos
    for (int i = 0; i < photoFiles.length; i++) {
      final file = photoFiles[i];
      formData.files.add(MapEntry(
        "photo_$i",
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    // Parameters
    formData.fields.add(MapEntry("template", templateId));
    formData.fields.add(MapEntry("aspect_ratio", aspectRatio));
    formData.fields.add(MapEntry("quality", quality));
    formData.fields.add(MapEntry("watermark", watermark.toString()));

    if (audioStart != null && audioStart > 0) {
      formData.fields.add(MapEntry("audio_start", audioStart.toString()));
    }
    if (audioEnd != null && audioEnd > 0) {
      formData.fields.add(MapEntry("audio_end", audioEnd.toString()));
    }
    if (titleText != null && titleText.trim().isNotEmpty) {
      formData.fields.add(MapEntry("title_text", titleText.trim()));
      formData.fields.add(MapEntry("title_bg", titleBg ?? "black"));
      formData.fields.add(MapEntry("title_duration", (titleDuration ?? 2).toString()));
    }

    // Output destination
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final savePath = "${dir.path}/reel_$timestamp.mp4";

    await _dio.post(
      "/render",
      data: formData,
      options: Options(responseType: ResponseType.bytes),
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          onProgress(sent / total * 0.7); // 70% of visual progress is upload
        }
      },
    ).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        final file = File(savePath);
        await file.writeAsBytes(response.data as List<int>);
        if (onProgress != null) onProgress(1.0);
      } else {
        throw Exception("Server returned status ${response.statusCode}");
      }
    });

    return savePath;
  }
}
