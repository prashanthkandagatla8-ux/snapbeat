export const metadata = {
  title: "Privacy Policy — SnapBeat",
  description: "Privacy Policy for SnapBeat Web and Mobile App.",
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
        <h2 className="text-lg font-bold text-white">3. Third-Party Advertising & Cookies (Google AdSense)</h2>
        <p>
          We use third-party advertising companies (such as Google AdSense) to serve ads when you visit our website. Google, as a third-party vendor, uses cookies to serve ads on our site. Google's use of advertising cookies (such as the DoubleClick DART cookie) enables it and its partners to serve ads to our users based on their visit to our site and/or other sites on the Internet.
        </p>
        <p>
          Users may opt out of personalized advertising by visiting{" "}
          <a
            href="https://www.google.com/settings/ads"
            target="_blank"
            rel="noopener noreferrer"
            className="text-amber-400 underline hover:text-amber-300"
          >
            Google Ads Settings
          </a>{" "}
          or by visiting{" "}
          <a
            href="https://www.aboutads.info/choices/"
            target="_blank"
            rel="noopener noreferrer"
            className="text-amber-400 underline hover:text-amber-300"
          >
            aboutads.info
          </a>.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">4. Affiliate Disclosure</h2>
        <p>
          SnapBeat participates in various affiliate marketing programs, including the Amazon Associates Program. As an Amazon Associate, SnapBeat earns from qualifying purchases made through links on our site. These links do not increase the price you pay, but provide support for our development and server rendering cluster.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">5. Data Security</h2>
        <p>
          All data transmitted between your browser or mobile device and our rendering servers is encrypted using standard HTTPS/TLS protocols.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">6. Contact Us</h2>
        <p>
          If you have questions about this policy or wish to request data deletion, contact us at support@snapbeat.app.
        </p>
      </section>
    </div>
  );
}
