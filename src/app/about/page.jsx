export const metadata = {
  title: "About Us — SnapBeat",
  description: "Learn about SnapBeat, the kinetic rhythm-synced video platform.",
};

export default function AboutPage() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "SnapBeat",
    "url": "https://snapbeat.app",
    "logo": "https://snapbeat.app/logo.png",
    "foundingDate": "2024",
    "founders": [
      {
        "@type": "Person",
        "name": "Prashanth Kumar"
      }
    ],
    "address": {
      "@type": "PostalAddress",
      "addressLocality": "Bangalore",
      "addressCountry": "IN"
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-6 py-12 text-gray-300 space-y-10 bg-[#0c0d10] min-h-screen">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline mb-8 block">← Back to Studio</a>
      
      <section className="text-center space-y-4">
        <h1 className="text-4xl md:text-5xl font-black text-white">About SnapBeat</h1>
        <p className="text-xl text-amber-400 font-medium">The Kinetic Rhythm-Synced Video Platform</p>
      </section>

      <section className="space-y-4">
        <h2 className="text-2xl font-bold text-white border-b border-gray-800 pb-2">Our Story & Mission</h2>
        <p className="leading-relaxed">
          Founded in Bangalore, India by Prashanth Kumar and a team of audio engineers, SnapBeat was born out of a desire to democratize rhythm-synced visual creation. We believe that producing high-quality, beat-matched videos shouldn't require steep learning curves or expensive desktop software.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-2xl font-bold text-white border-b border-gray-800 pb-2">The Audio-Visual Engine</h2>
        <p className="leading-relaxed">
          Under the hood, SnapBeat is powered by a custom-built technical architecture. We utilize Librosa-inspired acoustic transient detection and spectral flux analysis to pinpoint precise beat drops and rhythm changes. This data is fed into our cloud GPU cluster, which drives dynamic camera choreography and visual effects to create seamlessly synced video reels in seconds.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-2xl font-bold text-white border-b border-gray-800 pb-2">Privacy & Content Integrity</h2>
        <p className="leading-relaxed">
          We respect your privacy and the integrity of your content. SnapBeat employs zero user photo training—meaning your images are never used to train AI models. Furthermore, to ensure data security, all uploaded media is subject to a strict 60-minute automated storage purging policy after your video is generated.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-2xl font-bold text-white border-b border-gray-800 pb-2">The Team & Values</h2>
        <p className="leading-relaxed">
          Our core values are engineering excellence, accessibility, and creator respect. We strive to provide a platform that is not only powerful and reliable but also intuitive for users of all skill levels, while always maintaining the utmost respect for the creators and their original content.
        </p>
      </section>
    </div>
  );
}
