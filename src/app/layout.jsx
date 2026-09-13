import "./globals.css";
import { AuthProvider } from "@/context/AuthContext";

export const metadata = {
  title: "SnapBeat Studio — AI Beat-Synced Video Reel Maker",
  description: "Create high-impact, beat-synced video reels from your photos in seconds with motion choreography and dynamic zooms.",
  icons: {
    icon: "/assets/images/snapbeat_app_icon.png",
    apple: "/assets/images/snapbeat_app_icon.png",
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
