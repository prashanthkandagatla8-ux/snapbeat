import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BeatTemplate {
  final String id;
  final String name;
  final String subtitle;
  final String emoji;
  final IconData icon;
  final bool isPro;

  const BeatTemplate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.icon,
    this.isPro = false,
  });

  static const List<BeatTemplate> allTemplates = [
    BeatTemplate(id: "mix", name: "Mix Templates", subtitle: "Cycles kinetic motion styles to the beat", emoji: "🔀", icon: Icons.shuffle_rounded, isPro: false),
    BeatTemplate(id: "pendulum", name: "Pendulum", subtitle: "Swinging cuts with mirrored borders", emoji: "🪞", icon: Icons.swap_horiz, isPro: false),
    BeatTemplate(id: "beat-cut", name: "Beat Cut", subtitle: "Classic snappy beat drop transitions", emoji: "⚡", icon: Icons.flash_on),
    BeatTemplate(id: "beat-bounce", name: "Bounce", subtitle: "Kinetic bassline scale bounces", emoji: "🏀", icon: Icons.sports_basketball, isPro: true),
    BeatTemplate(id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Dynamic optical punch-in zooms", emoji: "🎬", icon: Icons.movie, isPro: true),
    BeatTemplate(id: "beat-fade", name: "Fade", subtitle: "Silky crossfades for ambient beats", emoji: "🌊", icon: Icons.waves, isPro: true),
    BeatTemplate(id: "glide-pan", name: "Glide", subtitle: "Lateral gliding pan motion", emoji: "🛹", icon: Icons.trending_flat, isPro: true),
    BeatTemplate(id: "beat-pulse", name: "Pulse", subtitle: "Pulsing emotional sub-bass pump", emoji: "💓", icon: Icons.monitor_heart, isPro: true),
    BeatTemplate(id: "punch-cut", name: "Punch", subtitle: "High-impact rhythmic punch cuts", emoji: "🥊", icon: Icons.sports_mma, isPro: true),
    BeatTemplate(id: "reveal-tiles", name: "Reveal Boxes", subtitle: "Geometric box tile mosaic reveals", emoji: "🔲", icon: Icons.grid_view, isPro: true),
    BeatTemplate(id: "beat-slide", name: "Slide", subtitle: "Directional kinetic slide transitions", emoji: "➡️", icon: Icons.arrow_forward, isPro: true),
    BeatTemplate(id: "slow-drift", name: "Slow Drift", subtitle: "Atmospheric slow cinematic drift", emoji: "☁️", icon: Icons.cloud, isPro: true),
    BeatTemplate(id: "sway-ballad", name: "Sway", subtitle: "Gentle rhythmic swaying cadence", emoji: "🍃", icon: Icons.eco, isPro: true),
    BeatTemplate(id: "beat-whip", name: "Whip", subtitle: "High-velocity directional whip pans", emoji: "🌪️", icon: Icons.cyclone, isPro: true),
    BeatTemplate(id: "zoom-out-reveal", name: "Zoom Out", subtitle: "Expanding optical reveal zoom", emoji: "🔍", icon: Icons.zoom_out, isPro: true),
  ];
}

class PhotoItem {
  final String id;
  final String path;
  int order;

  PhotoItem({
    required this.id,
    required this.path,
    required this.order,
  });
}

class QueueJobItem {
  final String id;
  final String templateName;
  final String? customName;
  final String status; // QUEUED, PROCESSING, READY, FAILED
  final String? videoPath;
  final DateTime createdAt;
  final String quality;
  final double progress;
  final String? error;
  final int queuePosition;
  final String? stage;

  QueueJobItem({
    required this.id,
    required this.templateName,
    this.customName,
    required this.status,
    this.videoPath,
    required this.createdAt,
    this.quality = "540p",
    this.progress = 0.0,
    this.error,
    this.queuePosition = 0,
    this.stage,
  });

  String get displayName =>
      (customName != null && customName!.trim().isNotEmpty)
          ? customName!.trim()
          : (templateName.isNotEmpty ? "$templateName Reel" : "SnapBeat Reel");

  QueueJobItem copyWith({
    String? status,
    String? customName,
    String? videoPath,
    double? progress,
    String? error,
    int? queuePosition,
    String? stage,
  }) {
    return QueueJobItem(
      id: id,
      templateName: templateName,
      customName: customName ?? this.customName,
      status: status ?? this.status,
      videoPath: videoPath ?? this.videoPath,
      createdAt: createdAt,
      quality: quality,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      queuePosition: queuePosition ?? this.queuePosition,
      stage: stage ?? this.stage,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateName': templateName,
    'customName': customName,
    'status': status,
    'videoPath': videoPath,
    'createdAt': createdAt.toIso8601String(),
    'quality': quality,
    'progress': progress,
    'error': error,
    'queuePosition': queuePosition,
    'stage': stage,
  };

  factory QueueJobItem.fromJson(Map<String, dynamic> json) {
    return QueueJobItem(
      id: json['id']?.toString() ?? '',
      templateName: json['templateName']?.toString() ?? 'Unknown',
      customName: json['customName']?.toString(),
      status: json['status']?.toString() ?? 'UNKNOWN',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      quality: json['quality']?.toString() ?? 'fast',
      videoPath: json['videoPath']?.toString(),
      error: json['error']?.toString(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 0,
      stage: json['stage']?.toString(),
    );
  }

  Future<File?> getResolvedVideoFile() async {
    if (videoPath == null || videoPath!.isEmpty) return null;
    final direct = File(videoPath!);
    if (direct.existsSync()) return direct;
    final fileName = p.basename(videoPath!);
    final docsDir = await getApplicationDocumentsDirectory();
    final candidate = File(p.join(docsDir.path, fileName));
    if (candidate.existsSync()) return candidate;
    return null;
  }
}

