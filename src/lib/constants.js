export const TEMPLATES = [
  { id: "pendulum", name: "Pendulum", subtitle: "Swinging cuts with mirrored borders", emoji: "🪞", isPro: false },
  { id: "beat-cut", name: "Beat Cut", subtitle: "Classic snappy beat drop transitions", emoji: "⚡", isPro: false },
  { id: "beat-bounce", name: "Bounce", subtitle: "Kinetic bassline scale bounces", emoji: "🏀", isPro: true },
  { id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Dynamic optical punch-in zooms", emoji: "🎬", isPro: true },
  { id: "beat-fade", name: "Fade", subtitle: "Silky crossfades for ambient beats", emoji: "🌊", isPro: true },
  { id: "glide-pan", name: "Glide", subtitle: "Lateral gliding pan motion", emoji: "🛹", isPro: true },
  { id: "beat-pulse", name: "Pulse", subtitle: "Pulsing emotional sub-bass pump", emoji: "💓", isPro: true },
  { id: "punch-cut", name: "Punch", subtitle: "High-impact rhythmic punch cuts", emoji: "🥊", isPro: true },
  { id: "reveal-tiles", name: "Reveal Boxes", subtitle: "Geometric box tile mosaic reveals", emoji: "🔲", isPro: true },
  { id: "beat-slide", name: "Slide", subtitle: "Directional kinetic slide transitions", emoji: "➡️", isPro: true },
  { id: "slow-drift", name: "Slow Drift", subtitle: "Atmospheric slow cinematic drift", emoji: "☁️", isPro: true },
  { id: "sway-ballad", name: "Sway", subtitle: "Gentle rhythmic swaying cadence", emoji: "🍃", isPro: true },
  { id: "beat-whip", name: "Whip", subtitle: "High-velocity directional whip pans", emoji: "🌪️", isPro: true },
  { id: "zoom-out-reveal", name: "Zoom Out", subtitle: "Expanding optical reveal zoom", emoji: "🔍", isPro: true },
];

export const PRICING_PLANS = [
  {
    id: "weekly",
    name: "Weekly Pass",
    price: 99,
    period: "7 days",
    description: "Great for weekend creators & one-off events",
    badge: null,
    features: [
      "Unlimited 1080p Master Renders",
      "No Watermark on any export",
      "All 14 Pro Templates unlocked",
      "Custom Title Card branding",
      "7 Days Full Access"
    ]
  },
  {
    id: "monthly",
    name: "Monthly Pro",
    price: 199,
    period: "30 days",
    description: "Our most popular plan for active creators",
    badge: "MOST POPULAR",
    features: [
      "Unlimited 1080p Master Renders",
      "No Watermark on any export",
      "All 14 Pro Templates unlocked",
      "Priority Queue slot allocation",
      "Custom Fonts & Border styling",
      "30 Days Full Access"
    ]
  },
  {
    id: "annual",
    name: "Annual Studio",
    price: 999,
    period: "365 days",
    description: "Best value for agencies & power creators",
    badge: "SAVE 58%",
    features: [
      "Everything in Monthly Pro",
      "VIP Early Access to Video Renders",
      "Highest Queue Priority",
      "Full Commercial Use License",
      "365 Days Full Access"
    ]
  }
];

export const ASPECT_RATIOS = [
  { id: "9:16", label: "9:16 Reel / Story", frameValue: "portrait", icon: "📱" },
  { id: "1:1", label: "1:1 Square Post", frameValue: "square", icon: "⏹️" },
  { id: "16:9", label: "16:9 Landscape Video", frameValue: "landscape", icon: "🖥️" },
];

export const TITLE_FONTS = [
  { id: "great_vibes", label: "Great Vibes (Cursive)" },
  { id: "cinzel", label: "Cinzel (Cinematic Serif)" },
  { id: "montserrat", label: "Montserrat (Modern Bold)" },
  { id: "bebas_neue", label: "Bebas Neue (Impact Headline)" },
  { id: "playfair", label: "Playfair Display (Luxury)" },
];

export const DEFAULT_SERVER_URL = "http://34.93.112.240";
