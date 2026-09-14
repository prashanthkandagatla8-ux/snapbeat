const fs = require("fs");
const path = require("path");

const pages = [
  {
    dir: "photo-to-video",
    title: "Free Photo to Video Maker with Music",
    description:
      "Convert photos into beat-synced videos and reels online for free. AI beat detection, 14 kinetic camera motion styles, and instant 1080p MP4 exports.",
    path: "/photo-to-video",
    h1: "Free Photo to Video Maker with Music",
    tagline: "INSTANT AI PHOTO TO VIDEO CONVERTER",
    valueProposition:
      "SnapBeat transforms your still photo collections into rhythmically synchronized short-form videos. Simply upload your pictures, select your favorite music track, and let our AI engine automatically match transitions to the beat.",
    keywords: [
      "photo to video maker",
      "turn photos into video",
      "photo video with song",
      "online video maker from photos",
      "free photo video converter",
    ],
    templates: [
      { id: "pendulum", name: "Pendulum", subtitle: "Swinging rhythmic cuts with mirrored borders", emoji: "🪞" },
      { id: "beat-cut", name: "Beat Cut", subtitle: "Snappy transitions synced directly to kick drums", emoji: "⚡" },
      { id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Optical crash zooms on high-energy beat drops", emoji: "🎬" },
    ],
    faqs: [
      {
        question: "Is SnapBeat free to use?",
        answer:
          "Yes! SnapBeat offers 100% free unlimited video renders with instant guest access during our public beta. No account or credit card required.",
      },
      {
        question: "How many photos can I add to a video?",
        answer:
          "You can add between 2 and 20 photos per video reel. Our sequencer allows you to arrange, shuffle, and auto-order them effortlessly.",
      },
      {
        question: "Can I upload my own songs?",
        answer:
          "Absolutely. You can choose from our curated built-in soundtracks or upload your own MP3, WAV, or AAC audio files with precision audio trimming.",
      },
    ],
    related: [
      { name: "Photo Slideshow Maker", path: "/photo-slideshow-maker", desc: "Create cinematic slideshows with smooth pacing." },
      { name: "Beat Sync Video Maker", path: "/beat-sync-video-maker", desc: "Automated waveform beat-matching." },
      { name: "Instagram Reel Maker", path: "/instagram-reel-maker", desc: "9:16 vertical reels optimized for social media." },
    ],
  },
  {
    dir: "photo-slideshow-maker",
    title: "Photo Slideshow Maker with Music & Motion",
    description:
      "Create cinematic photo slideshows with background music and kinetic motion transitions. Free online tool with automated timing and aspect ratio support.",
    path: "/photo-slideshow-maker",
    h1: "Photo Slideshow Maker with Music & Motion",
    tagline: "CINEMATIC PHOTO SLIDESHOWS IN SECONDS",
    valueProposition:
      "Say goodbye to boring, static slideshows. SnapBeat combines audio onset detection with 14 kinetic camera movements to turn your cherished memories into fluid, professional video montages.",
    keywords: [
      "photo slideshow maker",
      "slideshow maker with music",
      "picture slideshow with songs",
      "online slideshow creator",
      "make slideshow from photos",
    ],
    templates: [
      { id: "slow-drift", name: "Slow Drift", subtitle: "Atmospheric slow cinematic drift for emotional memories", emoji: "☁️" },
      { id: "beat-fade", name: "Fade", subtitle: "Silky smooth crossfades for ambient acoustic songs", emoji: "🌊" },
      { id: "sway-ballad", name: "Sway", subtitle: "Gentle cadence matching acoustic guitar chords", emoji: "🍃" },
    ],
    faqs: [
      {
        question: "What makes SnapBeat different from traditional slideshow makers?",
        answer:
          "Unlike rigid slideshow creators that simply switch photos every 3 seconds, SnapBeat analyzes acoustic drops and tempo variations in your music to dynamically choreograph transitions.",
      },
      {
        question: "What aspect ratios are supported?",
        answer:
          "SnapBeat supports 9:16 Portrait (Reels, TikTok, Shorts), 1:1 Square (Instagram Posts), and 16:9 Landscape (YouTube, TV screens).",
      },
      {
        question: "Can I reorder photos in the slideshow?",
        answer:
          "Yes, our visual Photo Bay allows you to drag-and-drop to reorder, shuffle randomly, or automatically organize your photos.",
      },
    ],
    related: [
      { name: "Photo to Video Maker", path: "/photo-to-video", desc: "Turn photos into beat-synced videos." },
      { name: "Photo to Music Video", path: "/photo-to-music-video", desc: "Music videos from your photo memories." },
      { name: "Templates Hub", path: "/templates", desc: "Explore all 14 kinetic motion styles." },
    ],
  },
  {
    dir: "photo-to-music-video",
    title: "Make Music Videos from Photos Automatically",
    description:
      "Create viral music videos from still photos. SnapBeat uses AI beat detection to synchronize image cuts and kinetic transitions with your music track.",
    path: "/photo-to-music-video",
    h1: "Make Music Videos from Photos Automatically",
    tagline: "AI-POWERED PHOTO MUSIC VIDEO STUDIO",
    valueProposition:
      "Bring your favorite soundtrack to life with still pictures. SnapBeat pairs intelligent audio onset analysis with dynamic optical zooms, lateral glides, and snappy cuts to produce broadcast-grade music videos.",
    keywords: [
      "photo to music video",
      "make music video from photos",
      "picture music video maker",
      "sync photos to music",
      "music video slideshow",
    ],
    templates: [
      { id: "beat-cut", name: "Beat Cut", subtitle: "Rapid rhythmic cuts aligned to kick drums", emoji: "⚡" },
      { id: "punch-cut", name: "Punch", subtitle: "High-impact kinetic punches on music drops", emoji: "🥊" },
      { id: "beat-whip", name: "Whip", subtitle: "High-velocity directional whip pan transitions", emoji: "🌪️" },
    ],
    faqs: [
      {
        question: "How does SnapBeat sync photos to the music?",
        answer:
          "Our audio engine performs spectral flux onset detection to identify rhythmic peaks, snares, and drops in the audio waveform, aligning every transition with musical precision.",
      },
      {
        question: "What audio formats can I upload?",
        answer:
          "SnapBeat accepts MP3, WAV, M4A, and AAC files. You can trim the exact start and end points using our interactive tape deck waveform.",
      },
      {
        question: "Is video export quality full 1080p?",
        answer:
          "Yes! SnapBeat renders high-bitrate MP4 files with crisp audio encoding for seamless uploading across all major streaming and social platforms.",
      },
    ],
    related: [
      { name: "Beat Sync Video Maker", path: "/beat-sync-video-maker", desc: "Automatic rhythmic audio alignment." },
      { name: "Photo Reel Maker", path: "/photo-reel-maker", desc: "High-energy reels for social media." },
      { name: "Instagram Reel Maker", path: "/instagram-reel-maker", desc: "Vertical videos ready for Instagram." },
    ],
  },
  {
    dir: "beat-sync-video-maker",
    title: "AI Beat Sync Video Maker | Sync Photos to Rhythm",
    description:
      "Automated AI beat sync video maker. Detect audio transients, sync photo cuts to kicks and drops, and export high-energy reels with 14 camera styles.",
    path: "/beat-sync-video-maker",
    h1: "AI Beat Sync Video Maker",
    tagline: "MATHEMATICALLY SYNCHRONIZED VISUALS",
    valueProposition:
      "Eliminate hours of manual keyframing. SnapBeat automatically scans your audio waveform for kicks, claps, and bass drops, cutting your photos in perfect rhythmic synchronization.",
    keywords: [
      "beat sync video maker",
      "sync video to beat",
      "ai beat sync",
      "music beat synced slideshow",
      "beat synced photo video",
    ],
    templates: [
      { id: "beat-bounce", name: "Bounce", subtitle: "Kinetic bassline scale bounces", emoji: "🏀" },
      { id: "punch-cut", name: "Punch", subtitle: "Slam into beat drops with maximum impact", emoji: "🥊" },
      { id: "beat-cut", name: "Beat Cut", subtitle: "Snappy rhythmic transitions on audio transients", emoji: "⚡" },
    ],
    faqs: [
      {
        question: "What is AI beat synchronization?",
        answer:
          "Beat synchronization uses digital signal processing to calculate audio onset envelopes and tempo (BPM), triggering visual transitions at the exact millisecond musical peaks occur.",
      },
      {
        question: "Do I need video editing experience?",
        answer:
          "None at all. Just add your photos and pick a song. SnapBeat handles 100% of the choreography, timeline pacing, and rendering automatically.",
      },
      {
        question: "Can I customize the video speed?",
        answer:
          "The video speed naturally adapts to the BPM of your chosen soundtrack — high-energy songs produce fast cuts, while downtempo beats trigger gentle, dreamy motion.",
      },
    ],
    related: [
      { name: "Photo to Music Video", path: "/photo-to-music-video", desc: "Music videos from your photo memories." },
      { name: "Instagram Reel Maker", path: "/instagram-reel-maker", desc: "Reels optimized for social algorithms." },
      { name: "Templates Hub", path: "/templates", desc: "Browse all 14 motion choreography presets." },
    ],
  },
  {
    dir: "photo-reel-maker",
    title: "Photo Reel Maker for Social Media (Free)",
    description:
      "Create viral photo reels for Instagram, TikTok, and YouTube Shorts. Automated beat matching, vertical 9:16 layout, and kinetic camera choreography.",
    path: "/photo-reel-maker",
    h1: "Photo Reel Maker for Social Media",
    tagline: "GROW YOUR ENGAGEMENT WITH KINETIC REELS",
    valueProposition:
      "Social media algorithms favor video over static photos. SnapBeat transforms your photo dumps and camera roll highlights into engaging 9:16 reels that keep viewers watching and looping.",
    keywords: [
      "photo reel maker",
      "make reels from photos",
      "photo dump reel maker",
      "tiktok photo video maker",
      "reel maker online free",
    ],
    templates: [
      { id: "pendulum", name: "Pendulum", subtitle: "Dynamic mirrored border pans designed for vertical screens", emoji: "🪞" },
      { id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Optical crash zooms that captivate viewers", emoji: "🎬" },
      { id: "glide-pan", name: "Glide", subtitle: "Sleek lateral gliding pan motion", emoji: "🛹" },
    ],
    faqs: [
      {
        question: "Why are photo reels performing well on social media?",
        answer:
          "Short-form platforms prioritize high retention and loop rates. Beat-synced photo reels combine compelling photography with rhythmic music, encouraging repeated views.",
      },
      {
        question: "What is the optimal video length for reels?",
        answer:
          "Reels between 7 and 15 seconds typically achieve the highest completion and replay rates. SnapBeat allows you to trim your music to the most viral section.",
      },
      {
        question: "Are videos exported without watermarks?",
        answer:
          "Free users receive high-quality renders with a subtle watermark. Upgrading to a SnapBeat Pro pass (₹99/week or ₹199/month) unlocks 100% watermark-free 1080p master exports.",
      },
    ],
    related: [
      { name: "Instagram Reel Maker", path: "/instagram-reel-maker", desc: "Specialized Instagram reel creator." },
      { name: "Travel Reel Maker", path: "/travel-reel-maker", desc: "Cinematic vacation and travel montages." },
      { name: "Birthday Video Maker", path: "/birthday-video-maker", desc: "Celebration tributes and birthday reels." },
    ],
  },
  {
    dir: "instagram-reel-maker",
    title: "Instagram Reel Maker from Photos | Free & Fast",
    description:
      "Make viral Instagram reels from photos with music. Instant 9:16 vertical exports, beat-synced cuts, and trending motion styles designed for IG growth.",
    path: "/instagram-reel-maker",
    h1: "Instagram Reel Maker from Photos",
    tagline: "OPTIMIZED FOR INSTAGRAM ALGORITHMS",
    valueProposition:
      "Turn your best photo dumps into high-retention Instagram reels. SnapBeat automates beat synchronization, frame cropping, and kinetic transitions so you can post stunning content in seconds.",
    keywords: [
      "instagram reel maker",
      "instagram reel from photos",
      "make ig reels with photos",
      "photo dump to reel",
      "instagram slideshow reel",
    ],
    templates: [
      { id: "beat-cut", name: "Beat Cut", subtitle: "Snappy cuts that boost viewer watch time", emoji: "⚡" },
      { id: "beat-bounce", name: "Bounce", subtitle: "Kinetic bassline bounce for trending audios", emoji: "🏀" },
      { id: "reveal-tiles", name: "Reveal Boxes", subtitle: "Modern mosaic box reveals", emoji: "🔲" },
    ],
    faqs: [
      {
        question: "Does SnapBeat export in native 9:16 resolution?",
        answer:
          "Yes, SnapBeat renders in 1080x1920 (9:16 portrait) with smart subject centering, ensuring your video fills mobile screens edge-to-edge.",
      },
      {
        question: "Can I add opening title cards for Instagram?",
        answer:
          "Yes! SnapBeat Pro features customizable retro and modern title cards to announce themes like Summer Dump 2026 or Birthday Recap.",
      },
      {
        question: "How quickly can I export an Instagram reel?",
        answer:
          "Our dedicated GPU cluster encodes and renders finished MP4 videos in typically under 45 seconds.",
      },
    ],
    related: [
      { name: "Photo Reel Maker", path: "/photo-reel-maker", desc: "Multi-platform short-form video creator." },
      { name: "Travel Reel Maker", path: "/travel-reel-maker", desc: "Vibrant vacation and trip montages." },
      { name: "Photo to Music Video", path: "/photo-to-music-video", desc: "Full music synchronization for pictures." },
    ],
  },
  {
    dir: "birthday-video-maker",
    title: "Birthday Photo Video Maker with Music & Wishes",
    description:
      "Create touching birthday photo video slideshows with celebration music. Free online birthday reel maker with kinetic motion and custom title cards.",
    path: "/birthday-video-maker",
    h1: "Birthday Photo Video Maker with Music",
    tagline: "CELEBRATE MEMORIES WITH KINETIC MOTION",
    valueProposition:
      "Give the gift of cherished memories. SnapBeat transforms childhood throwbacks, party snapshots, and family memories into a heartwarming birthday tribute video synced to festive music.",
    keywords: [
      "birthday video maker",
      "birthday photo video with song",
      "birthday slideshow with music",
      "happy birthday reel maker",
      "birthday photo montage",
    ],
    templates: [
      { id: "pendulum", name: "Pendulum", subtitle: "Elegant mirrored swings honoring special years", emoji: "🪞" },
      { id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Spotlight important smiles and celebration moments", emoji: "🎬" },
      { id: "slow-drift", name: "Slow Drift", subtitle: "Emotional retrospective drifting motion", emoji: "☁️" },
    ],
    faqs: [
      {
        question: "Can I add birthday songs to the video?",
        answer:
          "Yes, you can upload popular birthday tracks or choose from our built-in celebration soundtrack library.",
      },
      {
        question: "Can I share the birthday video directly on WhatsApp?",
        answer:
          "Yes! SnapBeat generates standard MP4 video files that can be shared instantly as WhatsApp Statuses, Instagram Stories, or private messages.",
      },
      {
        question: "Can I make birthday videos for friends and family?",
        answer:
          "Absolutely! Create unlimited videos for your kids, partner, parents, or best friends.",
      },
    ],
    related: [
      { name: "Telugu Birthday Video Maker", path: "/telugu-birthday-video-maker", desc: "Birthday reels in Telugu with regional songs." },
      { name: "Anniversary Video Maker", path: "/anniversary-video-maker", desc: "Romantic anniversary slideshows." },
      { name: "Baby Video Maker", path: "/baby-video-maker", desc: "Milestone videos for baby birthdays." },
    ],
  },
  {
    dir: "wedding-video-maker",
    title: "Wedding Photo Video Maker & Cinematic Slideshows",
    description:
      "Transform wedding and engagement photography into breathtaking cinematic video slideshows. Emotional music sync, graceful motion, and 1080p exports.",
    path: "/wedding-video-maker",
    h1: "Wedding Photo Video Maker",
    tagline: "CINEMATIC ELEGANCE FOR YOUR SPECIAL DAY",
    valueProposition:
      "Your wedding day deserves more than static albums. SnapBeat turns your ceremony portraits, bridal preparations, and reception dances into a fluid cinematic film set to your romantic song.",
    keywords: [
      "wedding photo video maker",
      "wedding slideshow with music",
      "marriage photo video maker",
      "wedding photo reel",
      "cinematic wedding video maker",
    ],
    templates: [
      { id: "slow-drift", name: "Slow Drift", subtitle: "Dreamy slow drift for bridal portraits", emoji: "☁️" },
      { id: "beat-fade", name: "Fade", subtitle: "Gentle dissolve transitions matching romantic ballads", emoji: "🌊" },
      { id: "sway-ballad", name: "Sway", subtitle: "Graceful cadence for first dance photos", emoji: "🍃" },
    ],
    faqs: [
      {
        question: "Is SnapBeat suitable for professional wedding photographers?",
        answer:
          "Yes! Photographers use SnapBeat to deliver quick-turnaround social media teaser reels to clients within 24 hours of the wedding.",
      },
      {
        question: "Can I output in widescreen for TV displays?",
        answer:
          "Yes, SnapBeat supports 16:9 Landscape mode, perfect for screening at receptions or viewing on living room smart TVs.",
      },
      {
        question: "Can I add custom couple names to the video?",
        answer:
          "Yes, SnapBeat Pro allows you to include elegant title card typography with the couple’s names and wedding date.",
      },
    ],
    related: [
      { name: "Anniversary Video Maker", path: "/anniversary-video-maker", desc: "Celebrate relationship milestones." },
      { name: "Photo Slideshow Maker", path: "/photo-slideshow-maker", desc: "General cinematic slideshows." },
      { name: "Templates Hub", path: "/templates", desc: "Choose elegant motion presets." },
    ],
  },
  {
    dir: "anniversary-video-maker",
    title: "Romantic Anniversary Photo Video Maker",
    description:
      "Celebrate your love story with a romantic anniversary photo video. Sync years of memories to your favorite love song with cinematic motion presets.",
    path: "/anniversary-video-maker",
    h1: "Romantic Anniversary Photo Video Maker",
    tagline: "HONOR YOUR LOVE STORY IN MOTION",
    valueProposition:
      "Celebrate 1 year or 50 years of shared love. Gather your favorite trips, anniversaries, and everyday moments, and let SnapBeat weave them into a poignant anniversary tribute video.",
    keywords: [
      "anniversary video maker",
      "anniversary photo video with song",
      "romantic photo slideshow",
      "love video maker from photos",
      "wedding anniversary reel",
    ],
    templates: [
      { id: "slow-drift", name: "Slow Drift", subtitle: "Timeless gentle motion for love stories", emoji: "☁️" },
      { id: "sway-ballad", name: "Sway", subtitle: "Warm acoustic cadence for romantic songs", emoji: "🍃" },
      { id: "pendulum", name: "Pendulum", subtitle: "Mirrored elegance reflecting years together", emoji: "🪞" },
    ],
    faqs: [
      {
        question: "What photos work best for an anniversary video?",
        answer:
          "A chronological mix of then and now photos — from your early dates to recent vacations — creates the most meaningful emotional journey.",
      },
      {
        question: "Can I use a custom song that means a lot to us?",
        answer:
          "Yes! Simply upload your special song file and use our audio trimmer to select the chorus or emotional climax.",
      },
      {
        question: "Is it easy to send to my partner?",
        answer:
          "Yes, once rendered, you can download the video directly to your phone or laptop to surprise your partner.",
      },
    ],
    related: [
      { name: "Wedding Video Maker", path: "/wedding-video-maker", desc: "Relive wedding ceremony memories." },
      { name: "Birthday Video Maker", path: "/birthday-video-maker", desc: "Celebrate special milestones." },
      { name: "Photo to Music Video", path: "/photo-to-music-video", desc: "Sync love songs with photo memories." },
    ],
  },
  {
    dir: "baby-video-maker",
    title: "Baby Photo Video & Milestone Reel Maker",
    description:
      "Preserve monthly milestones and baby memories in beautiful beat-synced videos. Fast, simple, and free online baby photo slideshow creator.",
    path: "/baby-video-maker",
    h1: "Baby Photo Video & Milestone Reel Maker",
    tagline: "CAPTURE PRECIOUS BABY MILESTONES",
    valueProposition:
      "Babies grow in the blink of an eye. Gather monthly milestone photos, first steps, and funny smiles into a heartwarming baby milestone video that grandparents and family will treasure forever.",
    keywords: [
      "baby video maker",
      "baby photo video with song",
      "baby milestone slideshow",
      "baby first year video maker",
      "newborn photo video",
    ],
    templates: [
      { id: "slow-drift", name: "Slow Drift", subtitle: "Soft, gentle motion for peaceful newborn shots", emoji: "☁️" },
      { id: "beat-bounce", name: "Bounce", subtitle: "Playful kinetic bounce for energetic toddler fun", emoji: "🏀" },
      { id: "beat-fade", name: "Fade", subtitle: "Smooth transitions across monthly milestones", emoji: "🌊" },
    ],
    faqs: [
      {
        question: "How can I organize monthly milestone photos (Months 1 to 12)?",
        answer:
          "Upload your 12 milestone photos and use our visual Photo Bay to ensure they are sequenced chronologically from birth to the first birthday.",
      },
      {
        question: "Is baby content secure and private?",
        answer:
          "Yes. Your uploaded photos and rendered videos are processed securely on isolated GPU servers with zero public exposure.",
      },
      {
        question: "Can I create videos for baby showers or gender reveals?",
        answer:
          "Yes! SnapBeat is perfect for baby shower countdowns, gender reveal teasers, and 1st birthday parties.",
      },
    ],
    related: [
      { name: "Birthday Video Maker", path: "/birthday-video-maker", desc: "First birthday celebration videos." },
      { name: "Photo Slideshow Maker", path: "/photo-slideshow-maker", desc: "Family photo slideshow creator." },
      { name: "Templates Hub", path: "/templates", desc: "Explore all motion presets." },
    ],
  },
  {
    dir: "travel-reel-maker",
    title: "Travel Photo Reel Maker with Cinematic Motion",
    description:
      "Transform vacation photos and trip memories into viral travel reels. AI beat sync, dynamic optical transitions, and vertical 9:16 exports.",
    path: "/travel-reel-maker",
    h1: "Travel Photo Reel Maker",
    tagline: "BRING YOUR ADVENTURES TO LIFE",
    valueProposition:
      "Don’t let your vacation photos get buried in your camera roll. Turn city explorations, beach sunsets, and mountain hikes into high-octane travel reels set to energetic beats in seconds.",
    keywords: [
      "travel reel maker",
      "vacation photo video maker",
      "travel slideshow with music",
      "travel video from photos",
      "holiday photo reel",
    ],
    templates: [
      { id: "beat-cut", name: "Beat Cut", subtitle: "Fast cuts showcasing destination highlights", emoji: "⚡" },
      { id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Optical crash zooms into breathtaking landscapes", emoji: "🎬" },
      { id: "beat-whip", name: "Whip", subtitle: "Directional whip pans connecting scenic vistas", emoji: "🌪️" },
    ],
    faqs: [
      {
        question: "How many travel photos should I include in a reel?",
        answer:
          "For a snappy 15-second travel montage, 8 to 15 photos work wonderfully to keep the pace vibrant and engaging.",
      },
      {
        question: "What soundtrack styles work best for travel reels?",
        answer:
          "Upbeat electronic, tropical house, or chill lo-fi beats create the perfect wanderlust atmosphere.",
      },
      {
        question: "Can I export in 9:16 for Instagram and TikTok?",
        answer:
          "Yes, SnapBeat defaults to 9:16 vertical orientation, optimized for smartphone screens.",
      },
    ],
    related: [
      { name: "Instagram Reel Maker", path: "/instagram-reel-maker", desc: "Reels optimized for Instagram feed." },
      { name: "Photo Reel Maker", path: "/photo-reel-maker", desc: "Create viral social reels." },
      { name: "Templates Hub", path: "/templates", desc: "Browse all 14 kinetic camera styles." },
    ],
  },
  {
    dir: "telugu-birthday-video-maker",
    title: "Telugu Birthday Photo Video Maker (తెలుగు బర్త్‌డే రీల్స్)",
    description:
      "Create Telugu birthday photo videos with songs online. Add Telugu mass beat songs, birthday wishes, and kinetic motion effects. ఉచితంగా వీడియో చేయండి.",
    path: "/telugu-birthday-video-maker",
    h1: "Telugu Birthday Photo Video Maker (తెలుగు బర్త్‌డే రీల్స్)",
    tagline: "తెలుగు బర్త్‌డే ఫోటో వీడియో మేకర్",
    valueProposition:
      "మీ స్నేహితులు మరియు కుటుంబ సభ్యుల పుట్టినరోజుల కోసం అదిరిపోయే తెలుగు బర్త్‌డే రీల్స్ మరియు వీడియోలు చేయండి. మాస్ బీట్స్, డిజే సాంగ్స్ మరియు సినీ స్టైల్ కెమెరా మోషన్స్ తో క్షణాల్లో వీడియో రెడీ!",
    keywords: [
      "telugu birthday video maker",
      "telugu birthday photo video with songs",
      "birthday video maker telugu online",
      "telugu photo video maker",
      "birthday wishes video in telugu",
    ],
    templates: [
      { id: "punch-cut", name: "Punch (మాస్ పంచ్)", subtitle: "మాస్ బీట్స్ మరియు డీజే డ్రాప్స్ కి అదిరిపోయే కట్స్", emoji: "🥊" },
      { id: "cinematic-zoom", name: "Cinematic Zoom (హీరో జూమ్)", subtitle: "సినిమాటిక్ హీరోయిక్ జూమ్ ఎఫెక్ట్స్", emoji: "🎬" },
      { id: "beat-cut", name: "Beat Cut (ఫాస్ట్ బీట్)", subtitle: "డ్రమ్స్ మరియు ధోల్ బీట్స్ కి సూపర్ కట్స్", emoji: "⚡" },
    ],
    faqs: [
      {
        question: "ఈ వెబ్‌సైట్ లో తెలుగు బర్త్‌డే పాటలు వాడవచ్చా?",
        answer:
          "అవును! మీరు మీకు నచ్చిన తెలుగు బర్త్‌డే సాంగ్స్, మాస్ బీట్స్ లేదా డీజే పాటలను సులభంగా అప్‌లోడ్ చేసి వాడవచ్చు.",
      },
      {
        question: "వాట్సాప్ స్టేటస్ కి సరిపోయేలా వీడియో వస్తుందా?",
        answer:
          "ఖచ్చితంగా! SnapBeat 9:16 సైజ్ లో హై క్వాలిటీ MP4 వీడియో ఇస్తుంది. మీరు నేరుగా వాట్సాప్ స్టేటస్ లేదా ఇన్‌స్టాగ్రామ్ రీల్స్ లో పెట్టుకోవచ్చు.",
      },
      {
        question: "వీడియో చేయడానికి డబ్బులు కట్టాలా?",
        answer:
          "లేదు, SnapBeat లో పబ్లిక్ బీటా సందర్భంగా అన్‌లిమిటెడ్ వీడియో రెండరింగ్ పూర్తిగా ఉచితం.",
      },
    ],
    related: [
      { name: "Telugu Photo Video Maker", path: "/telugu-photo-video-maker", desc: "తెలుగు ఫోటో వీడియో మేకర్ సాంగ్స్ తో." },
      { name: "Birthday Video Maker", path: "/birthday-video-maker", desc: "All birthday video styles." },
      { name: "Ganesh Chaturthi Video Maker", path: "/ganesh-chaturthi-video-maker", desc: "వినాయక చవితి భక్తి వీడియోలు." },
    ],
  },
  {
    dir: "telugu-photo-video-maker",
    title: "Telugu Photo Video Maker with Songs (తెలుగు ఫోటో వీడియోలు)",
    description:
      "Online Telugu photo to video maker with music. Sync photos to Telugu hit songs with automatic beat detection and cinematic transitions.",
    path: "/telugu-photo-video-maker",
    h1: "Telugu Photo Video Maker with Songs",
    tagline: "పాటలతో తెలుగు ఫోటో వీడియోలు తయారు చేయండి",
    valueProposition:
      "మీ ఫేవరెట్ తెలుగు పాటలకు మీ ఫోటోలను సింక్ చేసి అద్భుతమైన వీడియోలు మరియు రీల్స్ తయారు చేసుకోండి. ఎలాంటి ఎడిటింగ్ అనుభవం అవసరం లేకుండా క్షణాల్లో రెండర్ చేయండి.",
    keywords: [
      "telugu photo video maker",
      "telugu photo to video with song",
      "telugu songs video maker with photos",
      "photo video maker online telugu",
      "telugu reel maker",
    ],
    templates: [
      { id: "pendulum", name: "Pendulum (పెండ్యులమ్)", subtitle: "స్టైలిష్ మిర్రర్ బార్డర్ స్వింగ్ కట్స్", emoji: "🪞" },
      { id: "slow-drift", name: "Slow Drift (మెలోడీ డ్రిఫ్ట్)", subtitle: "తెలుగు మెలోడీ పాటలకు అనువైన స్లో మోషన్", emoji: "☁️" },
      { id: "beat-cut", name: "Beat Cut (బీట్ కట్స్)", subtitle: "తీన్‌మార్ మరియు ఫాస్ట్ సాంగ్స్ కి అదిరిపోయే కట్స్", emoji: "⚡" },
    ],
    faqs: [
      {
        question: "తెలుగు పాటలతో ఫోటో వీడియో ఎలా చేయాలి?",
        answer:
          "1) మీ ఫోటోలను అప్‌లోడ్ చేయండి. 2) మీకు నచ్చిన తెలుగు పాటను ఎంచుకోండి. 3) స్టైల్ ఎంచుకుని రెండర్ బటన్ నొక్కండి. నిమిషంలో మీ వీడియో సిద్ధం!",
      },
      {
        question: "నా ఫోన్ లో ఉన్న తెలుగు సాంగ్స్ అప్‌లోడ్ చేయవచ్చా?",
        answer:
          "అవును, మీ డివైస్ లో ఉన్న ఏ MP3 లేదా ఆడియో ఫైల్ అయినా నేరుగా అప్‌లోడ్ చేయవచ్చు.",
      },
      {
        question: "వీడియో డౌన్‌లోడ్ చేసుకోవడం ఉచితమేనా?",
        answer:
          "అవును, SnapBeat లో ఎలాంటి దాగి ఉన్న ఛార్జీలు లేకుండా నేరుగా వీడియో MP4 డౌన్‌లోడ్ చేసుకోవచ్చు.",
      },
    ],
    related: [
      { name: "Telugu Birthday Video Maker", path: "/telugu-birthday-video-maker", desc: "తెలుగు బర్త్‌డే స్పెషల్ వీడియోలు." },
      { name: "Beat Sync Video Maker", path: "/beat-sync-video-maker", desc: "Automatic beat sync studio." },
      { name: "Instagram Reel Maker", path: "/instagram-reel-maker", desc: "Vertical video maker." },
    ],
  },
  {
    dir: "ganesh-chaturthi-video-maker",
    title: "Ganesh Chaturthi Photo Video Maker (వినాయక చవితి రీల్స్)",
    description:
      "Create devotional Ganesh Chaturthi festival photo videos with dhol tasha and aarti songs. Celebrate Vinayaka Chavithi with festive kinetic video reels.",
    path: "/ganesh-chaturthi-video-maker",
    h1: "Ganesh Chaturthi Photo Video Maker",
    tagline: "వినాయక చవితి పండుగ రీల్స్ & భక్తి వీడియోలు",
    valueProposition:
      "Celebrate the divine arrival of Lord Ganesha. Combine pooja photos, pandal decorations, and immersion celebrations with energetic dhol tasha beats into breathtaking festival reels.",
    keywords: [
      "ganesh chaturthi video maker",
      "vinayaka chavithi photo video",
      "ganpati photo video with song",
      "ganesh festival reel maker",
      "dhol tasha video maker",
    ],
    templates: [
      { id: "punch-cut", name: "Punch (Dhol Tasha Punch)", subtitle: "Slamming transitions synced to pounding dhol beats", emoji: "🥊" },
      { id: "cinematic-zoom", name: "Cinematic Zoom (Murti Zoom)", subtitle: "Grand zooms highlighting Ganesh idol details", emoji: "🎬" },
      { id: "beat-cut", name: "Beat Cut (Visarjan Rhythm)", subtitle: "Energetic cuts for festive dance celebrations", emoji: "⚡" },
    ],
    faqs: [
      {
        question: "Can I use Dhol Tasha or Ganpati Aarti songs?",
        answer:
          "Yes! Upload high-energy Dhol Tasha tracks, traditional aartis, or Bollywood devotional anthems to match your pandal photos.",
      },
      {
        question: "Can I make videos for our residential colony or mandal?",
        answer:
          "Yes! Many Ganesh mandals and families use SnapBeat to create social media recaps of their 10-day festivities.",
      },
      {
        question: "Is it mobile friendly?",
        answer:
          "Yes, SnapBeat works smoothly on Android, iPhone, tablets, and desktop browsers.",
      },
    ],
    related: [
      { name: "Diwali Video Maker", path: "/diwali-video-maker", desc: "Festival of lights photo video creator." },
      { name: "Telugu Photo Video Maker", path: "/telugu-photo-video-maker", desc: "Telugu regional video maker." },
      { name: "Photo to Music Video", path: "/photo-to-music-video", desc: "Sync music to festival celebrations." },
    ],
  },
  {
    dir: "diwali-video-maker",
    title: "Diwali Festival Photo Video Maker with Music",
    description:
      "Make sparkling Diwali festival photo videos with music. Combine family diwali celebrations, rangoli, diyas, and fireworks into cinematic video reels.",
    path: "/diwali-video-maker",
    h1: "Diwali Festival Photo Video Maker with Music",
    tagline: "ILLUMINATE YOUR FESTIVAL MEMORIES",
    valueProposition:
      "Light up your social media with sparkling Diwali memories. Turn festive family gatherings, glowing diyas, beautiful rangoli designs, and firework celebrations into a vibrant festival video.",
    keywords: [
      "diwali video maker",
      "diwali photo video with song",
      "diwali slideshow maker",
      "deepavali photo video",
      "happy diwali reel maker",
    ],
    templates: [
      { id: "cinematic-zoom", name: "Cinematic Zoom", subtitle: "Dynamic zooms into glowing diyas and sparklers", emoji: "🎬" },
      { id: "beat-bounce", name: "Bounce", subtitle: "Playful kinetic motion for family celebration songs", emoji: "🏀" },
      { id: "slow-drift", name: "Slow Drift", subtitle: "Atmospheric warmth for candlelit family gatherings", emoji: "☁️" },
    ],
    faqs: [
      {
        question: "Can I add traditional Diwali and celebration tracks?",
        answer:
          "Yes, upload your favorite festive melodies or pick from SnapBeat’s high-energy celebration sound tracks.",
      },
      {
        question: "Can I send Diwali video greetings to loved ones on WhatsApp?",
        answer:
          "Yes! Download the finished MP4 reel directly to your device and send personalized Deepavali video greetings to friends and family.",
      },
      {
        question: "Does SnapBeat support low-light Diwali night photos?",
        answer:
          "Yes, our rendering engine preserves the deep shadows and warm highlights of your diya and firecracker photography.",
      },
    ],
    related: [
      { name: "Ganesh Chaturthi Video Maker", path: "/ganesh-chaturthi-video-maker", desc: "Ganesh festival videos." },
      { name: "Birthday Video Maker", path: "/birthday-video-maker", desc: "Celebration tributes." },
      { name: "Photo Reel Maker", path: "/photo-reel-maker", desc: "Create viral festive reels." },
    ],
  },
];

pages.forEach((p) => {
  const filePath = path.join(__dirname, "..", "src", "app", p.dir, "page.jsx");
  const code = `import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: ${JSON.stringify(p.title)},
  description: ${JSON.stringify(p.description)},
  path: ${JSON.stringify(p.path)},
  keywords: ${JSON.stringify(p.keywords)},
});

export default function ${p.dir
    .split("-")
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join("")}Page() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: ${JSON.stringify(p.title.split("|")[0].split("(")[0].trim())}, path: ${JSON.stringify(p.path)} },
  ];

  const howItWorks = [
    {
      step: "01",
      title: "Upload Photos",
      desc: "Add between 2 and 20 photos from your phone or camera. Reorder, shuffle, or auto-arrange in our tactile Photo Bay.",
    },
    {
      step: "02",
      title: "Pick Music & Motion",
      desc: "Choose a soundtrack or upload your own audio. Select one of 14 kinetic camera choreography presets.",
    },
    {
      step: "03",
      title: "Export Beat-Synced Video",
      desc: "Our GPU cluster analyzes acoustic drop points and renders a high-definition MP4 reel in seconds.",
    },
  ];

  const benefits = [
    {
      title: "Automated AI Beat Detection",
      desc: "No manual timeline editing. Our audio engine calculates exact acoustic transients and drop points.",
    },
    {
      title: "14 Kinetic Camera Styles",
      desc: "From snappy beat cuts and bassline bounces to cinematic zooms, slow drifts, and mirrored pendulums.",
    },
    {
      title: "All Social Formats",
      desc: "Export in 9:16 Portrait for Reels, Shorts, and TikTok; 1:1 Square for feeds; or 16:9 Landscape for TV.",
    },
    {
      title: "Instant 1-Click Guest Access",
      desc: "Zero signup friction. Jump straight into the workstation and export your reel in seconds.",
    },
    {
      title: "High-Speed GPU Renders",
      desc: "Powered by high-performance cloud GPUs for fast sub-minute video encoding and instant delivery.",
    },
    {
      title: "Free Unlimited Creation",
      desc: "Enjoy 100% free unlimited video renders during our open public beta period.",
    },
  ];

  const faqs = ${JSON.stringify(p.faqs, null, 4)};

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      getWebApplicationSchema(),
      getBreadcrumbSchema(breadcrumbs),
      getFaqSchema(faqs),
    ],
  };

  return (
    <SeoLandingPage
      title=${JSON.stringify(p.title)}
      h1=${JSON.stringify(p.h1)}
      tagline=${JSON.stringify(p.tagline)}
      valueProposition=${JSON.stringify(p.valueProposition)}
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={${JSON.stringify(p.templates, null, 6)}}
      benefits={benefits}
      faqs={faqs}
      relatedPages={${JSON.stringify(p.related, null, 6)}}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
`;

  fs.writeFileSync(filePath, code, "utf8");
  console.log("Created: " + filePath);
});
console.log("Successfully generated all 15 SEO Landing Pages!");
