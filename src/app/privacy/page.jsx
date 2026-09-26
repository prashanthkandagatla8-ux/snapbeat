export const metadata = {
  title: "Privacy Policy — SnapBeat",
  description: "Privacy Policy for SnapBeat Web and Mobile App.",
};

export default function PrivacyPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 text-gray-300 space-y-6 bg-[#0c0d10] min-h-screen">
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline">← Back to Studio</a>
      <h1 className="text-3xl font-black text-white">Privacy Policy for SnapBeat</h1>
      <p className="text-xs text-gray-500">Last updated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">1. Introduction</h2>
        <p>
          SnapBeat ("we", "our", or "us") respects your privacy. This Privacy Policy explains how we collect, use, and safeguard your data when you use the SnapBeat mobile application and web studio at snapbeat.app.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">2. Information We Process</h2>
        <p>
          <strong>User Media (Photos & Audio):</strong> Photos and audio files uploaded for video generation are processed strictly to render your requested video reel. Media files are stored temporarily during rendering in isolated staging directories and <strong>automatically purged within 60 minutes after generation</strong>. We do not sell or train AI models on your photos.
        </p>
        <p>
          <strong>Payment Information:</strong> We do not store or process card numbers directly. Payments are handled securely by PCI-DSS certified payment processors (such as Razorpay / Stripe).
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">3. Third-Party Advertising & Cookies (Google AdSense)</h2>
        <p>
          We use third-party advertising companies to serve ads when you visit our website. Google, as a third-party vendor, uses cookies to serve ads on our site.
        </p>
        <ul className="list-disc pl-5 space-y-1">
          <li>Third party vendors, including Google, use cookies to serve ads based on a user's prior visits to your website or other websites.</li>
          <li>Google's use of advertising cookies (such as the DoubleClick DART cookie) enables it and its partners to serve ads to our users based on their visit to our sites and/or other sites on the Internet.</li>
          <li>
            Users may opt out of personalized advertising by visiting{" "}
            <a href="https://www.google.com/settings/ads" target="_blank" rel="noopener noreferrer" className="text-amber-400 underline hover:text-amber-300">
              Google Ads Settings
            </a>.
          </li>
          <li>
            Alternatively, you can opt out of a third-party vendor's use of cookies for personalized advertising by visiting{" "}
            <a href="https://www.aboutads.info/choices/" target="_blank" rel="noopener noreferrer" className="text-amber-400 underline hover:text-amber-300">
              aboutads.info
            </a>.
          </li>
        </ul>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">4. GDPR Data Rights (EEA & UK Users)</h2>
        <p>If you are a resident of the European Economic Area (EEA) or the UK, you have the following data protection rights:</p>
        <ul className="list-disc pl-5 space-y-1">
          <li><strong>Right to Access:</strong> You can request copies of your personal data.</li>
          <li><strong>Right to Rectification:</strong> You can request correction of inaccurate data.</li>
          <li><strong>Right to Erasure:</strong> You can request deletion of your data (noting our 60-minute media auto-purge).</li>
          <li><strong>Right to Restrict Processing:</strong> You can request we restrict the processing of your data.</li>
          <li><strong>Right to Data Portability:</strong> You can request transfer of your data to another organization.</li>
        </ul>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">5. California Consumer Privacy Act (CCPA/CPRA)</h2>
        <p>If you are a California resident, you have the right to know what personal information is collected, used, shared, or sold. SnapBeat does not sell your personal information. You have the right to request deletion of your personal information and the right to non-discrimination for exercising your CCPA rights.</p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">6. Data Security</h2>
        <p>
          All data transmitted between your browser or mobile device and our rendering servers is encrypted using standard HTTPS/TLS protocols.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">7. Contact Us</h2>
        <p>
          If you have questions about this policy or wish to exercise your data rights, contact us at <a href="mailto:support@snapbeat.app" className="text-amber-400 hover:underline">support@snapbeat.app</a>.
        </p>
      </section>
    </div>
  );
}
