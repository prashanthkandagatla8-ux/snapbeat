export const metadata = {
  title: "Terms of Service — SnapBeat",
  description: "Terms of Service and Subscription Billing Terms for SnapBeat.",
};

export default function TermsPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 text-gray-300 space-y-6">
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline">← Back to Studio</a>
      <h1 className="text-3xl font-black text-white">Terms of Service</h1>
      <p className="text-xs text-gray-500">Last updated: September 13, 2026</p>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">1. Service Description</h2>
        <p>
          SnapBeat provides an automated audio-visual rendering platform allowing users to generate beat-synced videos from photos and music.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">2. Free & Pro Subscription Plans</h2>
        <p>
          <strong>Free Tier:</strong> Includes unlimited standard queued renders in 720p resolution with a SnapBeat watermark.
        </p>
        <p>
          <strong>Pro Passes:</strong> Available as Weekly (₹99 / 7 days), Monthly (₹199 / 30 days), and Annual (₹999 / 365 days). Pro users receive 1080p Master exports, zero watermark, all templates, and priority queue slots.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">3. Intellectual Property</h2>
        <p>
          You retain all rights and ownership to the photos and audio you upload. You warrant that you have the necessary licenses or rights to use any music uploaded for rendering.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">4. Refund Policy</h2>
        <p>
          Due to the digital nature of video rendering compute resources, subscriptions are generally non-refundable once activated, unless a technical failure prevents service delivery. Contact support@snapbeat.app for billing inquiries.
        </p>
      </section>
    </div>
  );
}
