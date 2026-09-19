import 'package:flutter/material.dart';

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
    this.quality = "720p",
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
}

class RegionPricing {
  final String regionCode;
  final String regionDisplayName;
  final String currencySymbol;
  final String removeWatermarkPrice;
  final String removeWatermarkSubtitle;
  final String proModePrice;
  final String proModeSubtitle;
  final String starterPrice;
  final String partyPrice;
  final String studioPrice;
  final String directorPrice;

  const RegionPricing({
    required this.regionCode,
    required this.regionDisplayName,
    required this.currencySymbol,
    required this.removeWatermarkPrice,
    required this.removeWatermarkSubtitle,
    required this.proModePrice,
    required this.proModeSubtitle,
    required this.starterPrice,
    required this.partyPrice,
    required this.studioPrice,
    required this.directorPrice,
  });

  static const Map<String, RegionPricing> regions = {
    "IN": RegionPricing(
      regionCode: "IN",
      regionDisplayName: "🇮🇳 India (INR ₹)",
      currencySymbol: "₹",
      removeWatermarkPrice: "₹99",
      removeWatermarkSubtitle: "Permanently remove watermarks on all renders",
      proModePrice: "₹199",
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • No Watermark",
      starterPrice: "₹79",
      partyPrice: "₹249",
      studioPrice: "₹499",
      directorPrice: "₹999",
    ),
    "US": RegionPricing(
      regionCode: "US",
      regionDisplayName: r"🇺🇸 United States (USD $)",
      currencySymbol: r"$",
      removeWatermarkPrice: r"$0.99",
      removeWatermarkSubtitle: "Permanently remove watermarks on all renders",
      proModePrice: r"$1.99",
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • No Watermark",
      starterPrice: r"$0.99",
      partyPrice: r"$2.99",
      studioPrice: r"$5.99",
      directorPrice: r"$12.99",
    ),
    "GB": RegionPricing(
      regionCode: "GB",
      regionDisplayName: "🇬🇧 United Kingdom (GBP £)",
      currencySymbol: "£",
      removeWatermarkPrice: "£0.89",
      removeWatermarkSubtitle: "Permanently remove watermarks on all renders",
      proModePrice: "£1.89",
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • No Watermark",
      starterPrice: "£0.89",
      partyPrice: "£2.49",
      studioPrice: "£4.99",
      directorPrice: "£9.99",
    ),
    "EU": RegionPricing(
      regionCode: "EU",
      regionDisplayName: "🇪🇺 European Union (EUR €)",
      currencySymbol: "€",
      removeWatermarkPrice: "€0.99",
      removeWatermarkSubtitle: "Permanently remove watermarks on all renders",
      proModePrice: "€1.99",
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • No Watermark",
      starterPrice: "€0.99",
      partyPrice: "€2.99",
      studioPrice: "€5.99",
      directorPrice: "€11.99",
    ),
  };
}
