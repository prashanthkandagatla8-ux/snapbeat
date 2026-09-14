import { SITE_URL } from "@/lib/seo";

export default function sitemap() {
  const now = new Date();

  const routes = [
    { path: "", changeFrequency: "daily", priority: 1.0 },
    { path: "/photo-to-video", changeFrequency: "weekly", priority: 0.95 },
    { path: "/photo-slideshow-maker", changeFrequency: "weekly", priority: 0.9 },
    { path: "/photo-to-music-video", changeFrequency: "weekly", priority: 0.9 },
    { path: "/beat-sync-video-maker", changeFrequency: "weekly", priority: 0.9 },
    { path: "/photo-reel-maker", changeFrequency: "weekly", priority: 0.9 },
    { path: "/instagram-reel-maker", changeFrequency: "weekly", priority: 0.85 },
    { path: "/birthday-video-maker", changeFrequency: "weekly", priority: 0.85 },
    { path: "/wedding-video-maker", changeFrequency: "weekly", priority: 0.85 },
    { path: "/anniversary-video-maker", changeFrequency: "weekly", priority: 0.8 },
    { path: "/baby-video-maker", changeFrequency: "weekly", priority: 0.8 },
    { path: "/travel-reel-maker", changeFrequency: "weekly", priority: 0.8 },
    { path: "/telugu-birthday-video-maker", changeFrequency: "weekly", priority: 0.85 },
    { path: "/telugu-photo-video-maker", changeFrequency: "weekly", priority: 0.85 },
    { path: "/ganesh-chaturthi-video-maker", changeFrequency: "weekly", priority: 0.8 },
    { path: "/diwali-video-maker", changeFrequency: "weekly", priority: 0.8 },
    { path: "/templates", changeFrequency: "weekly", priority: 0.85 },
    { path: "/blog", changeFrequency: "weekly", priority: 0.8 },
    { path: "/blog/how-to-make-video-from-photos", changeFrequency: "monthly", priority: 0.75 },
    { path: "/blog/how-to-sync-photos-to-music", changeFrequency: "monthly", priority: 0.75 },
    { path: "/blog/best-photo-reel-ideas", changeFrequency: "monthly", priority: 0.75 },
    { path: "/terms", changeFrequency: "monthly", priority: 0.3 },
    { path: "/privacy", changeFrequency: "monthly", priority: 0.3 },
  ];

  return routes.map((route) => ({
    url: `${SITE_URL}${route.path}`,
    lastModified: now,
    changeFrequency: route.changeFrequency,
    priority: route.priority,
  }));
}
