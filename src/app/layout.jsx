import "./globals.css";

export const metadata = {
  title: "SnapBeat Studio — AI Beat-Synced Video Reel Maker",
  description: "Create high-impact, beat-synced video reels from your photos in seconds with motion choreography and dynamic zooms.",
  icons: {
    icon: "/favicon.ico",
  },
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-[#0e1117] text-white flex flex-col antialiased selection:bg-amber-500 selection:text-black">
        {children}
      </body>
    </html>
  );
}
