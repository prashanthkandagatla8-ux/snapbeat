export const metadata = {
  title: "Privacy Policy — SnapBeat",
  description: "Privacy Policy for SnapBeat Studio and Mobile App.",
};

export default function PrivacyPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 text-gray-300 space-y-6">
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline">← Back to Studio</a>
      <h1 className="text-3xl font-black text-white">Privacy Policy for SnapBeat</h1>
      <p className="text-xs text-gray-500">Last updated: September 13, 2026</p>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">1. Introduction</h2>
        <p>
          SnapBeat ("we", "our", or "us") respects your privacy. This Privacy Policy explains how we collect, use, and safeguard your data when you use the SnapBeat mobile application and web studio at snapbeat.app.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">2. Information We Process</h2>
        <p>
          <strong>User Media (Photos & Audio):</strong> Photos and audio files uploaded for video generation are processed strictly to render your requested video reel. Media files are stored temporarily during rendering in isolated staging directories and automatically purged within 60 minutes after generation. We do not sell or train AI models on your photos.
        </p>
        <p>
          <strong>Payment Information:</strong> We do not store or process card numbers directly. Payments are handled securely by PCI-DSS certified payment processors (such as Razorpay / Stripe).
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">3. Data Security</h2>
        <p>
          All data transmitted between your browser or mobile device and our rendering servers is encrypted using standard HTTPS/TLS protocols.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">4. Contact Us</h2>
        <p>
          If you have questions about this policy, please contact us at support@snapbeat.app.
        </p>
      </section>
    </div>
  );
}
