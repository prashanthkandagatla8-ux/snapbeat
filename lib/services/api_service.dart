import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://34.93.112.240",
      connectTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(minutes: 3),
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
    bool autoArrange = true,
    int? audioStart,
    int? audioEnd,
    String? titleText,
    bool? enableTitle,
    String? titleBg,
    int? titleDuration,
    String? titleFont,
    String? titleStyle,
    String? titleFrame,
    String? titleAudio,
    Function(double progress)? onProgress,
  }) async {
    if (!musicFile.existsSync()) {
      throw Exception('Music file not found. Please re-select your track.');
    }
    for (final file in photoFiles) {
      if (!file.existsSync()) {
        throw Exception('A photo file was not found. Please re-select your photos.');
      }
    }
    if (photoFiles.length < 2) {
      throw Exception('Please select at least 2 photos to create a reel.');
    }

    final formData = FormData();

    // Attach music
    formData.files.add(MapEntry(
      "audio",
      await MultipartFile.fromFile(
        musicFile.path,
        filename: 'audio${p.extension(musicFile.path)}',
      ),
    ));

    // Attach photos under key 'photos'
    for (final file in photoFiles) {
      formData.files.add(MapEntry(
        "photos",
        await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
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
    formData.fields.add(MapEntry("auto_arrange", autoArrange ? "true" : "false"));

    formData.fields.add(MapEntry('full_track', (audioEnd != null && audioEnd > 0 && audioStart != null && audioEnd > audioStart) ? 'false' : 'true'));
    if (audioStart != null && audioStart > 0) {
      formData.fields.add(MapEntry("audio_start", audioStart.toString()));
    }
    if (audioEnd != null && audioEnd > 0) {
      formData.fields.add(MapEntry("audio_end", audioEnd.toString()));
    }
    final effectiveTitleText = (titleText != null && titleText.trim().isNotEmpty) ? titleText.trim() : (enableTitle == true ? 'SNAPBEAT' : null);
    if (effectiveTitleText != null) {
      formData.fields.add(MapEntry("title_text", effectiveTitleText));
      formData.fields.add(MapEntry("title_bg", titleBg ?? "black"));
      formData.fields.add(MapEntry("title_duration", (titleDuration ?? 2).toString()));
      if (titleFont != null && titleFont.isNotEmpty) {
        formData.fields.add(MapEntry("title_font", titleFont));
      }
      if (titleStyle != null && titleStyle.isNotEmpty) {
        formData.fields.add(MapEntry("title_style", titleStyle));
      }
      if (titleFrame != null && titleFrame.isNotEmpty) {
        formData.fields.add(MapEntry("title_frame", titleFrame));
      }
      if (titleAudio != null && titleAudio.isNotEmpty) {
        formData.fields.add(MapEntry("title_audio", titleAudio));
      }
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

    if (submitResponse.data is! Map) {
      throw Exception('Server returned invalid response. Please try again.');
    }
    final data = submitResponse.data as Map<String, dynamic>;
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

    // Download final video directly to disk (streaming to prevent OOM crashes)
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanTemplate = templateId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final savePath = "${dir.path}/SnapBeat_${cleanTemplate}_$timestamp.mp4";

    final downloadResp = await _dio.download(
      "/api/render/download/$jobId",
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          final prog = 0.95 + (received / total) * 0.05;
          onProgress(prog.clamp(0.95, 1.0));
        }
      },
    );

    if (downloadResp.statusCode == 200 && File(savePath).existsSync()) {
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

