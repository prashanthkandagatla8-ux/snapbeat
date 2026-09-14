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
  other: {
    "google-adsense-account": "ca-pub-2850833794586490",
  },
};
export default function RootLayout({ children }) {
  const adSenseId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID || "ca-pub-2850833794586490";

  return (
    <html lang="en" className="dark">
      <head>
        {/* Google AdSense Account Verification Meta Tag */}
        <meta name="google-adsense-account" content="ca-pub-2850833794586490" />

        {/* Google AdSense / Google Ad Manager Official High-Value Ad Engine */}
        {adSenseId && (
          <script
            async
            src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${adSenseId}`}
            crossOrigin="anonymous"
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
