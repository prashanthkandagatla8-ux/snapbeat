# SnapBeat Web ⚡

The full-featured, zero-build web application for **SnapBeat**.

Create rhythm-synced videos from photos and music directly in your browser.

---

## Features
- **100% Feature Parity with Android App**:
  - Full song playback or custom Start & End dual range trimming.
  - Bundled sample track (Funk Smooth Party) ready with 1 click.
  - Polaroid photo stack with drag-and-drop & 1-tap `◀` and `▶` reordering.
  - All 22 animated beat-cut templates (Bounce, Cine Zoom, Glide, Mosaic, Pendulum, Reveal, Spiral, Whip, etc.).
  - "💥 Drop It" burst montage on bass drops.
  - Aspect Ratio selection (9:16 Shorts/Reels, 16:9 YouTube, 1:1 Instagram).
  - Professional Title Card Designer with an **interactive live canvas preview**!
  - Real-time rendering progress bar and embedded HTML5 video preview player with 1-click MP4 download.
- **Dark & Light Themes**: Seamless retro-pop theme switcher with local storage memory.
- **Zero Build Tooling Required**: Pure HTML5, CSS3, and ES6 JavaScript. No `npm install` or webpack build needed!

---

## Running Locally

You can run this web app with any local static HTTP server:

```bash
# Python 3 built-in server:
python -m http.server 3000

# Or using Node.js:
npx serve .
```

Then open `http://localhost:3000` in your web browser.

---

## Free Web Hosting Deployment

This folder is 100% static and can be deployed with 1 click to any free static host:

### Option 1: Netlify (Drag & Drop)
1. Go to [netlify.com](https://app.netlify.com/drop).
2. Drag and drop this `SnapBeat-Web` folder into the upload box.
3. Your web app is instantly live with a free HTTPS URL!

### Option 2: Vercel
```bash
npx vercel
```
Follow prompts &mdash; deployed in seconds.

### Option 3: GitHub Pages
1. Push this folder to a GitHub repository.
2. Go to **Settings &rarr; Pages**.
3. Set Source to `Deploy from a branch (main / root)`.
4. Click Save.

### Option 4: Cloudflare Pages
1. Go to Cloudflare Dashboard &rarr; **Workers & Pages &rarr; Create application &rarr; Pages**.
2. Connect your GitHub repository or upload folder.
3. Build output directory: `.` (root).

---

## Connecting to Backend
Click **Server Config** in the top-right header to specify your backend URL:
- Local Server: `http://localhost:8772`
- Gateway: `https://your-gateway.onrender.com`
- Dedicated VPS: `http://your-server-ip:8772`
