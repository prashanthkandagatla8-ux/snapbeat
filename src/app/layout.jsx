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
    icon: "/assets/images/snapbeat_app_icon.png",
    shortcut: "/assets/images/snapbeat_app_icon.png",
    apple: "/assets/images/snapbeat_app_icon.png",
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
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-[#c2b8a5] text-[#2b2b2d] flex flex-col antialiased selection:bg-[#ffc72c] selection:text-[#2b2820]">
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
