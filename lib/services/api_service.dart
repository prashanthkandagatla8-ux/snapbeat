import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../config/app_config.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers["X-SnapBeat-Build"] = AppConfig.buildNumber;
        try {
          final prefs = await SharedPreferences.getInstance();
          String? installId = prefs.getString("snapbeat_install_id");
          if (installId == null || installId.isEmpty) {
            installId = "sb_${DateTime.now().millisecondsSinceEpoch}";
            await prefs.setString("snapbeat_install_id", installId);
          }
          options.headers["X-SnapBeat-Install-Id"] = installId;
        } catch (_) {}
        handler.next(options);
      },
    ));
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
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
    bool preview = false,
    bool dropIt = false,
    bool enableBurst = true,
    bool enableTeaser = true,
    int? audioStart,
    int? audioEnd,
    String? titleText,
    bool? enableTitle,
    String? titleBg,
    int? titleDuration,
    String? titleFont,
    String? titleFontSize,
    String? titleStyle,
    String? titleFrame,
    String? titleAudio,
    String? renderType,
    String? entitlementToken,
    Function(double progress)? onProgress,
    Function(String status, String stage, int queuePosition, double progress)? onStatusUpdate,
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

    // Parameters (Added FIRST so reverse proxies and gateway inspect headers in the first 4KB)
    String frameValue = "portrait";
    if (aspectRatio == "1:1") frameValue = "square";
    if (aspectRatio == "16:9") frameValue = "landscape";

    formData.fields.add(const MapEntry("mode", "cult"));
    formData.fields.add(MapEntry("platform", Platform.isIOS ? "ios" : (Platform.isAndroid ? "android" : "mobile")));
    formData.fields.add(const MapEntry("client", "mobile"));
    final effectiveRenderType = renderType ?? (isInstant ? "instant" : "free_queue");
    formData.fields.add(MapEntry("render_type", effectiveRenderType));
    formData.fields.add(MapEntry("template", templateId));
    formData.fields.add(MapEntry("frame", frameValue));
    final String ql = quality.toLowerCase();
    // Send the literal values worker.py:748-753 matches on. "hd" is NOT in that
    // list and silently falls through to the 0.3333 scale, i.e. a 720p purchase
    // rendering at 360p. Verified live: quality="hd" -> 360x640, "720p" -> 720x1280.
    final String qualityParam = ql.contains("1080")
        ? "master"
        : (ql.contains("720") || ql.contains("hd") ? "720p" : "fast");
    formData.fields.add(MapEntry("quality", qualityParam));
    formData.fields.add(MapEntry("watermark", watermark.toString()));
    if (entitlementToken != null && entitlementToken.isNotEmpty) {
      formData.fields.add(MapEntry("entitlement_token", entitlementToken));
    }
    formData.fields.add(MapEntry("auto_arrange", autoArrange ? "true" : "false"));
    if (preview) {
      formData.fields.add(const MapEntry("preview", "true"));
    }
    formData.fields.add(MapEntry("drop_it", dropIt ? "true" : "false"));
    final double durationSec = (audioEnd != null && audioEnd > 0 && audioStart != null && audioEnd > audioStart)
        ? (audioEnd - audioStart).toDouble()
        : 60.0;
    formData.fields.add(MapEntry("output_seconds", durationSec.toStringAsFixed(1)));
    formData.fields.add(MapEntry("enable_burst", enableBurst ? "true" : "false"));
    formData.fields.add(const MapEntry("burst_effect", "auto"));
    formData.fields.add(const MapEntry("burst_min_run_length", "3"));
    formData.fields.add(MapEntry("enable_teaser", enableTeaser ? "true" : "false"));

    formData.fields.add(MapEntry('full_track', (audioEnd != null && audioEnd > 0 && audioStart != null && audioEnd > audioStart) ? 'false' : 'true'));
    if (audioStart != null && audioStart > 0) {
      formData.fields.add(MapEntry("audio_start", audioStart.toString()));
    }
    if (audioEnd != null && audioEnd > 0) {
      formData.fields.add(MapEntry("audio_end", audioEnd.toString()));
    }
    final effectiveTitleText = (titleText != null && titleText.trim().isNotEmpty) ? titleText.trim() : null;
    if (effectiveTitleText != null) {
      formData.fields.add(const MapEntry("enable_title", "true"));
      formData.fields.add(MapEntry("title_text", effectiveTitleText));
      formData.fields.add(MapEntry("title_bg", titleBg ?? "black"));
      formData.fields.add(MapEntry("title_duration", (titleDuration ?? 2).toString()));
      if (titleFont != null && titleFont.isNotEmpty) {
        formData.fields.add(MapEntry("title_font", titleFont));
      }
      if (titleFontSize != null && titleFontSize.isNotEmpty) {
        formData.fields.add(MapEntry("title_font_size", titleFontSize));
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

    // Attach music
    formData.files.add(MapEntry(
      "audio",
      await MultipartFile.fromFile(
        musicFile.path,
        filename: 'audio${p.extension(musicFile.path)}',
      ),
    ));

    // Attach photos under key 'photos' with unique indexed filenames to support duplicate photos
    for (int i = 0; i < photoFiles.length; i++) {
      final file = photoFiles[i];
      final ext = p.extension(file.path).isNotEmpty ? p.extension(file.path) : '.jpg';
      final indexedName = 'photo_${(i + 1).toString().padLeft(3, '0')}$ext';
      formData.files.add(MapEntry(
        "photos",
        await MultipartFile.fromFile(
          file.path,
          filename: indexedName,
        ),
      ));
    }

    if (onProgress != null) onProgress(0.1);

    // Submit Job to Gateway
    final submitResponse = await _dio.post(
      "/api/render/mobile",
      data: formData,
      options: Options(
        headers: (entitlementToken != null && entitlementToken.isNotEmpty)
            ? {"X-SnapBeat-Entitlement": entitlementToken}
            : null,
      ),
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

    // Poll for status with resilient background/reconnect retry
    int maxAttempts = 400;
    bool isCompleted = false;
    int consecutiveNetworkErrors = 0;

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      Response? statusResp;
      try {
        statusResp = await _dio.get("/api/render/status/$jobId");
        consecutiveNetworkErrors = 0;
      } on DioException catch (dioErr) {
        consecutiveNetworkErrors++;
        debugPrint("Status poll DioException ($consecutiveNetworkErrors): ${dioErr.type} ${dioErr.message}");
        // When user switches apps or device suspends connections, retry up to 15 times (~30s grace period)
        if (consecutiveNetworkErrors < 15) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        throw Exception("Network connection interrupted while switching apps. Please check internet and retry.");
      } catch (e) {
        consecutiveNetworkErrors++;
        if (consecutiveNetworkErrors < 10) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        rethrow;
      }

      if (statusResp.statusCode == 200 && statusResp.data is Map) {
        final sData = statusResp.data;
        final status = (sData["status"] ?? "").toString().toLowerCase();
        final stage = (sData["stage"] ?? "").toString();
        final queuePos = (sData["queue_position"] as num?)?.toInt() ?? 0;
        final rawProg = (sData["progress"] ?? 0) as num;
        
        double calcProg = 0.3 + (rawProg / 100.0) * 0.6; // 30% to 90%
        if (status == "queued") {
          calcProg = 0.3;
        }
        final finalProg = calcProg.clamp(0.0, 0.95);

        if (onProgress != null) {
          onProgress(finalProg);
        }
        if (onStatusUpdate != null) {
          onStatusUpdate(status, stage, queuePos, finalProg);
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

    // Download final video directly to disk with retry (streaming to prevent OOM crashes)
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanTemplate = templateId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final savePath = "${dir.path}/SnapBeat_${cleanTemplate}_$timestamp.mp4";

    bool downloadSuccess = false;
    for (int dAttempt = 1; dAttempt <= 3; dAttempt++) {
      try {
        final downloadResp = await _dio.download(
          "/api/render/download/$jobId?delete_after=true",
          savePath,
          onReceiveProgress: (received, total) {
            if (total > 0 && onProgress != null) {
              final prog = 0.95 + (received / total) * 0.05;
              onProgress(prog.clamp(0.95, 1.0));
            }
          },
        );

        if (downloadResp.statusCode == 200 && File(savePath).existsSync()) {
          downloadSuccess = true;
          // Notify server to clean up temporary upload folder and render artifacts immediately
          try {
            _dio.post("/api/render/cleanup/$jobId").then((_) {}).ignore();
          } catch (_) {}
          break;
        }
      } catch (e) {
        debugPrint("Download attempt $dAttempt failed: $e");
        if (dAttempt < 3) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          throw Exception("Failed to download rendered video. Please check your network connection.");
        }
      }
    }

    if (downloadSuccess && File(savePath).existsSync()) {
      if (onProgress != null) onProgress(1.0);
      return savePath;
    } else {
      throw Exception("Failed to download rendered video. Please verify storage permissions.");
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

