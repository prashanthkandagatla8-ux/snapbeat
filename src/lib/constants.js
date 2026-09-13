export const SOUND_TRACKS = [
  {
    id: "little_do_you_know",
    title: "Little Do You Know",
    genre: "Cinematic / Emotional Beat",
    bpm: "74 BPM",
    vibe: "Atmospheric piano chords and emotive slow-burn rhythm for storytelling",
    assetPath: "/assets/audio/little_do_you_know.mp3",
    durationSeconds: 154.0,
    fileName: "little_do_you_know.mp3",
  },
  {
    id: "funk_smooth_party",
    title: "Funk Smooth Party",
    genre: "Nu-Funk / Retro",
    bpm: "124 BPM",
    vibe: "Upbeat 1970s funk groove with brass hits and dynamic breaks",
    assetPath: "/assets/audio/funk_smooth_party.mp3",
    durationSeconds: 58.0,
    fileName: "funk_smooth_party.mp3",
  },
  {
    id: "urban_boom_bap",
    title: "Urban Boom Bap",
    genre: "Hip-Hop / Rap",
    bpm: "92 BPM",
    vibe: "Punchy 46-second classic boom-bap rhythm with crisp snare snaps",
    assetPath: "/assets/audio/urban_boom_bap.mp3",
    durationSeconds: 46.0,
    fileName: "urban_boom_bap.mp3",
  },
  {
    id: "percussion_drive",
    title: "Percussion Drive",
    genre: "Acoustic / Stomp",
    bpm: "110 BPM",
    vibe: "Organic stomps, handclaps, and rhythmic cajon builds",
    assetPath: "/assets/audio/percussion_drive.mp3",
    durationSeconds: 62.0,
    fileName: "percussion_drive.mp3",
  },
  {
    id: "chill_vlog_beat",
    title: "Chill Vlog Hip-Hop",
    genre: "Lo-Fi / Vlog",
    bpm: "88 BPM",
    vibe: "Mellow electric keys and relaxing sunny beats for aesthetic reels",
    assetPath: "/assets/audio/chill_vlog_beat.mp3",
    durationSeconds: 78.0,
    fileName: "chill_vlog_beat.mp3",
  },
  {
    id: "sweet_life_chill",
    title: "Sweet Life Lounge",
    genre: "Downtempo / Chill",
    bpm: "100 BPM",
    vibe: "Deep synth basslines and stylish luxury lounge vibes",
    assetPath: "/assets/audio/sweet_life_chill.mp3",
    durationSeconds: 83.0,
    fileName: "sweet_life_chill.mp3",
  },
  {
    id: "action_stinger",
    title: "Action Stinger (18s)",
    genre: "Dynamic / Short",
    bpm: "128 BPM",
    vibe: "Fast-paced 18s hype track tailor-made for rapid beat transitions",
    assetPath: "/assets/audio/action_stinger.mp3",
    durationSeconds: 18.0,
    fileName: "action_stinger.mp3",
  },
  {
    id: "celebration_anthem",
    title: "Celebration Anthem",
    genre: "Festive / Pop",
    bpm: "120 BPM",
    vibe: "Joyful celebration fanfare and driving rhythm for party reels",
    assetPath: "/assets/audio/celebration_anthem.mp3",
    durationSeconds: 106.0,
    fileName: "celebration_anthem.mp3",
  },
  {
    id: "heavy_bass_dubstep",
    title: "Heavy Bass Dubstep",
    genre: "Bass / Dubstep",
    bpm: "140 BPM",
    vibe: "High-energy electronic drop with heavy sub-bass wobble",
    assetPath: "/assets/audio/heavy_bass_dubstep.mp3",
    durationSeconds: 126.0,
    fileName: "heavy_bass_dubstep.mp3",
  },
];

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
