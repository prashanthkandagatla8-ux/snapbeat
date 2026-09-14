import "./globals.css";
import { AuthProvider } from "@/context/AuthContext";

export const viewport = {
  themeColor: "#2b2820",
  width: "device-width",
  initialScale: 1,
};

export const metadata = {
  metadataBase: new URL("https://snapbeat.app"),
  title: "SnapBeat Studio — AI Beat-Synced Video Reel Maker",
  description: "Create high-impact, beat-synced video reels from your photos in seconds with motion choreography and dynamic zooms.",
  icons: {
    icon: "/icon.png",
    shortcut: "/icon.png",
    apple: "/icon.png",
  },
  openGraph: {
    title: "SnapBeat Studio — AI Beat-Synced Video Reel Maker",
    description: "Tactile Audio-Visual Reel Maker. High-impact, beat-synced video reels from photos in seconds.",
    url: "https://snapbeat.app",
    siteName: "SnapBeat Studio",
    images: [
      {
        url: "/assets/images/snapbeat_logo.png",
        width: 1200,
        height: 630,
        alt: "SnapBeat Studio",
      },
    ],
    type: "website",
  },
};

export default function RootLayout({ children }) {
  const adSenseId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;
  const monetagScriptUrl = process.env.NEXT_PUBLIC_MONETAG_SCRIPT_URL;

  return (
    <html lang="en" className="dark">
      <head>
        {/* HYBRID AD NETWORK 1: Google AdSense / Google Ad Manager */}
        {adSenseId && (
          <script
            async
            src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${adSenseId}`}
            crossOrigin="anonymous"
          />
        )}

        {/* HYBRID AD NETWORK 2: Monetag In-Stream & Rewarded Interstitial Tag */}
        {monetagScriptUrl && (
          <script
            async
            src={monetagScriptUrl}
          />
        )}
      </head>
      <body className="min-h-screen bg-[#1a1c1e] text-[#f1f1f1] flex flex-col antialiased selection:bg-[#ffc72c] selection:text-[#1c1303]">
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
