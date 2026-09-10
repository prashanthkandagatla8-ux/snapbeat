import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://34.93.112.240",
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
    bool isInstant = false,
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
      "audio",
      await MultipartFile.fromFile(
        musicFile.path,
        filename: "audio.mp3",
      ),
    ));

    // Attach photos under key 'photos'
    for (final file in photoFiles) {
      formData.files.add(MapEntry(
        "photos",
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    // Parameters
    String frameValue = "portrait";
    if (aspectRatio == "1:1") frameValue = "square";
    if (aspectRatio == "16:9") frameValue = "landscape";

    formData.fields.add(MapEntry("template", templateId));
    formData.fields.add(MapEntry("frame", frameValue));
    formData.fields.add(MapEntry("quality", quality.toLowerCase().contains("1080") ? "master" : "fast"));
    formData.fields.add(MapEntry("watermark", watermark.toString()));
    formData.fields.add(MapEntry("render_type", isInstant ? "instant" : "free_queue"));

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

    if (onProgress != null) onProgress(0.1);

    // Submit Job to Gateway
    final submitResponse = await _dio.post(
      "/api/render/mobile",
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          onProgress(0.1 + (sent / total) * 0.2); // 10% to 30% for upload
        }
      },
    );

    if (submitResponse.statusCode != 200 || submitResponse.data == null) {
      throw Exception("Gateway returned status ${submitResponse.statusCode}");
    }

    final data = submitResponse.data is Map ? submitResponse.data : Map<String, dynamic>.from(submitResponse.data as Map);
    final String jobId = (data["job_id"] ?? data["composite_id"] ?? "").toString();
    if (jobId.isEmpty) {
      throw Exception("No job ID received from server gateway");
    }

    // Poll for status
    int maxAttempts = 400;
    bool isCompleted = false;
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      final statusResp = await _dio.get("/api/render/status/$jobId");
      if (statusResp.statusCode == 200 && statusResp.data is Map) {
        final sData = statusResp.data;
        final status = (sData["status"] ?? "").toString().toLowerCase();
        final rawProg = (sData["progress"] ?? 0) as num;
        
        if (onProgress != null) {
          double calcProg = 0.3 + (rawProg / 100.0) * 0.6; // 30% to 90%
          onProgress(calcProg.clamp(0.0, 0.95));
        }

        if (status == "done" || status == "completed" || status == "success") {
          isCompleted = true;
          break;
        } else if (status == "failed") {
          final rawErr = (sData["error"] ?? "").toString();
          throw Exception(_cleanServerError(rawErr));
        }
      }
    }

    if (!isCompleted) {
      throw Exception("Processing timed out waiting for studio queue. Please retry.");
    }

    if (onProgress != null) onProgress(0.95);

    // Download final video
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final savePath = "${dir.path}/snapbeat_$timestamp.mp4";

    final downloadResp = await _dio.get(
      "/api/render/download/$jobId?delete_after=true",
      options: Options(responseType: ResponseType.bytes),
    );

    if (downloadResp.statusCode == 200 && downloadResp.data != null) {
      final file = File(savePath);
      await file.writeAsBytes(downloadResp.data as List<int>);
      if (onProgress != null) onProgress(1.0);
      return savePath;
    } else {
      throw Exception("Failed to download rendered video: status ${downloadResp.statusCode}");
    }
  }

  String _cleanServerError(String raw) {
    if (raw.isEmpty) return "Master studio reported an unknown processing issue.";
    if (raw.contains("FileNotFoundError") || raw.contains("no longer available")) {
      return "The selected template preset is currently not available on the rendering engine.";
    }
    if (raw.contains("Timeout") || raw.contains("timed out")) {
      return "Processing timed out on the studio engine. Please retry.";
    }
    if (raw.contains("CUDA") || raw.contains("Out of Memory") || raw.contains("OOM")) {
      return "Studio GPU memory busy. Please try with fewer photos or try again in a moment.";
    }
    if (raw.contains("audio") || raw.contains("corrupt")) {
      return "Audio file format could not be decoded by the beat analyzer.";
    }
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isNotEmpty) {
      final lastLine = lines.last;
      if (lastLine.contains(':')) {
        return lastLine.split(':').last.trim();
      }
      return lastLine;
    }
    return "The master rendering engine encountered a processing error.";
  }
}

