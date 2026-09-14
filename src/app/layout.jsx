import "./globals.css";
import { AuthProvider } from "@/context/AuthContext";
import GoogleAnalytics from "@/components/analytics/GoogleAnalytics";
import {
  SITE_URL,
  SITE_NAME,
  DEFAULT_OG_IMAGE,
  getWebApplicationSchema,
  getOrganizationSchema,
  getWebSiteSchema,
} from "@/lib/seo";

export const viewport = {
  themeColor: "#0c0d10",
  width: "device-width",
  initialScale: 1,
};

export const metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "Photo to Video Maker | Beat-Synced Reels | SnapBeat",
    template: `%s | ${SITE_NAME}`,
  },
  description:
    "Turn photos into beat-synced videos automatically with SnapBeat. Create stunning photo reels, slideshows, and music videos for Instagram, WhatsApp, and Shorts in seconds.",
  keywords: [
    "photo to video maker",
    "photo slideshow maker",
    "photo to music video",
    "beat sync video maker",
    "photo beat sync video maker",
    "photo reel maker",
    "instagram reel maker",
    "music video maker from photos",
    "create video from photos",
    "AI video maker from photos",
  ],
  alternates: {
    canonical: SITE_URL,
  },
  icons: {
    icon: "/icon.png",
    shortcut: "/icon.png",
    apple: "/icon.png",
  },
  openGraph: {
    title: "Photo to Video Maker | Beat-Synced Reels | SnapBeat",
    description:
      "Turn photos into beat-synced videos automatically with SnapBeat. Free online reel maker with AI beat detection, kinetic choreography, and music.",
    url: SITE_URL,
    siteName: SITE_NAME,
    images: [
      {
        url: DEFAULT_OG_IMAGE,
        width: 1200,
        height: 630,
        alt: "SnapBeat — AI Beat-Synced Photo to Video Maker",
      },
    ],
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "Photo to Video Maker | Beat-Synced Reels | SnapBeat",
    description:
      "Turn photos into beat-synced videos automatically with SnapBeat. Create reels, slideshows & music videos in seconds.",
    images: [DEFAULT_OG_IMAGE],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  other: {
    "google-adsense-account": "ca-pub-2850833794586490",
  },
};

export default function RootLayout({ children }) {
  const adSenseId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID || "ca-pub-2850833794586490";
  const webAppSchema = getWebApplicationSchema();
  const orgSchema = getOrganizationSchema();
  const webSiteSchema = getWebSiteSchema();

  return (
    <html lang="en" className="dark">
      <head>
        {/* Google AdSense Account Verification Meta Tag */}
        <meta name="google-adsense-account" content="ca-pub-2850833794586490" />

        {/* Global JSON-LD Structured Data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(webAppSchema) }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(orgSchema) }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(webSiteSchema) }}
        />

        {/* Google AdSense / Google Ad Manager Official High-Value Ad Engine */}
        {adSenseId && (
          <script
            async
            src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${adSenseId}`}
            crossOrigin="anonymous"
          />
        )}
      </head>
      <body className="min-h-screen bg-[#0c0d10] text-[#f1f1f1] flex flex-col antialiased selection:bg-[#ffc72c] selection:text-[#1c1303]">
        <GoogleAnalytics />
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
