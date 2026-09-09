class BeatTemplate {
  final String id;
  final String name;
  final String subtitle;
  final String emoji;
  final bool isPro;

  const BeatTemplate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
    this.isPro = false,
  });

  static const List<BeatTemplate> allTemplates = [
    BeatTemplate(id: "beat-cut", name: "Beat Cut", subtitle: "Classic snappy beat drop transitions", emoji: "⚡"),
    BeatTemplate(id: "cine-zoom", name: "Cine Zoom", subtitle: "Dynamic optical punch-in zooms", emoji: "🎬", isPro: true),
    BeatTemplate(id: "whip", name: "Whip Glide", subtitle: "High-velocity directional whip pans", emoji: "🌪️", isPro: true),
    BeatTemplate(id: "bounce", name: "Bounce Beat", subtitle: "Kinetic bassline scale bounces", emoji: "🏀", isPro: true),
    BeatTemplate(id: "flash", name: "Flash Pulse", subtitle: "Luminous white strobe transients", emoji: "✨", isPro: true),
    BeatTemplate(id: "strobe", name: "Strobe Echo", subtitle: "Fast rhythmic flash cuts", emoji: "⚡", isPro: true),
    BeatTemplate(id: "heartbeat", name: "Heartbeat", subtitle: "Pulsing emotional sub-bass pump", emoji: "💓", isPro: true),
    BeatTemplate(id: "glitch", name: "Glitch Hop", subtitle: "RGB chromatic aberration jumps", emoji: "👾", isPro: true),
    BeatTemplate(id: "fade", name: "Smooth Fade", subtitle: "Silk crossfades for ambient beats", emoji: "🌊", isPro: true),
    BeatTemplate(id: "pan-right", name: "Pan Right", subtitle: "Continuous horizontal pan flow", emoji: "➡️", isPro: true),
    BeatTemplate(id: "tilt-up", name: "Tilt Up", subtitle: "Ascending vertical camera sweep", emoji: "⬆️", isPro: true),
    BeatTemplate(id: "ripple", name: "Ripple Wave", subtitle: "Fluid liquid distortion pulses", emoji: "💧", isPro: true),
    BeatTemplate(id: "hyper-zoom", name: "Hyper Zoom", subtitle: "Infinite continuous tunnel zoom", emoji: "🚀", isPro: true),
    BeatTemplate(id: "kaleido", name: "Kaleido", subtitle: "Prismatic mirrored party geometry", emoji: "🔮", isPro: true),
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
  final String status; // QUEUED, PROCESSING, READY, FAILED
  final String? videoPath;
  final DateTime createdAt;
  final String quality;

  QueueJobItem({
    required this.id,
    required this.templateName,
    required this.status,
    this.videoPath,
    required this.createdAt,
    this.quality = "1080p",
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateName': templateName,
    'status': status,
    'videoPath': videoPath,
    'createdAt': createdAt.toIso8601String(),
    'quality': quality,
  };

  factory QueueJobItem.fromJson(Map<String, dynamic> json) => QueueJobItem(
    id: json['id'] as String,
    templateName: json['templateName'] as String,
    status: json['status'] as String,
    videoPath: json['videoPath'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    quality: json['quality'] as String? ?? "1080p",
  );
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
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • Zero Watermark",
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
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • Zero Watermark",
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
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • Zero Watermark",
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
      proModeSubtitle: "Full Pro Mode • All 14 Templates • 1080p 60fps • Zero Watermark",
      starterPrice: "€0.99",
      partyPrice: "€2.99",
      studioPrice: "€5.99",
      directorPrice: "€11.99",
    ),
  };
}
