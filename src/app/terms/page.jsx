export const metadata = {
  title: "Terms of Service — SnapBeat",
  description: "Terms of Service and Subscription Billing Terms for SnapBeat.",
};

export default function TermsPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 text-gray-300 space-y-6 bg-[#0c0d10] min-h-screen">
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline">← Back to Studio</a>
      <h1 className="text-3xl font-black text-white">Terms of Service</h1>
      <p className="text-xs text-gray-500">Last updated: {new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">1. Acceptance of Terms & Eligibility</h2>
        <p>
          By accessing or using SnapBeat (snapbeat.app), you agree to be bound by these Terms of Service. If you do not agree, you may not use the platform. You must be at least 13 years old (or the minimum legal age in your country) to use SnapBeat.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">2. Description of Services</h2>
        <p>
          SnapBeat provides an automated audio-visual rendering platform allowing users to generate beat-synced videos from photos and music.
        </p>
        <p>
          <strong>Free Tier:</strong> Includes unlimited standard queued renders in 720p resolution with a SnapBeat watermark.
        </p>
        <p>
          <strong>Pro Passes:</strong> Available as Weekly (₹99), Monthly (₹199), and Annual (₹999) subscriptions. Pro users receive 1080p Master exports, zero watermark, access to all templates, and priority queue slots.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">3. Acceptable Use Policy</h2>
        <p>
          You agree not to use SnapBeat to upload, generate, or distribute media that is illegal, harmful, threatening, abusive, harassing, defamatory, obscene, or infringing on any third party's intellectual property rights. We reserve the right to terminate accounts that violate this policy.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">4. Intellectual Property & DMCA Copyright Takedown</h2>
        <p>
          You retain all rights and ownership to the photos and audio you upload. You warrant that you have the necessary licenses or rights to use any music uploaded for rendering.
        </p>
        <p>
          SnapBeat respects the intellectual property rights of others. If you believe that your copyrighted work has been infringed upon, please submit a DMCA takedown notice to our designated agent at <a href="mailto:dmca@snapbeat.app" className="text-amber-400 hover:underline">dmca@snapbeat.app</a> with the necessary information as required by the DMCA.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">5. Billing, Subscriptions & Refund Terms</h2>
        <p>
          Subscriptions auto-renew unless canceled before the end of the current billing period. Due to the digital nature of video rendering compute resources, subscriptions are generally non-refundable once activated, unless a technical failure prevents service delivery. For billing inquiries or refund requests related to technical failures, contact <a href="mailto:support@snapbeat.app" className="text-amber-400 hover:underline">support@snapbeat.app</a>.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">6. Limitation of Liability</h2>
        <p>
          SnapBeat is provided on an "as is" and "as available" basis. In no event shall SnapBeat, its founders, or affiliates be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of or inability to use the platform.
        </p>
      </section>

      <section className="space-y-2 text-sm leading-relaxed">
        <h2 className="text-lg font-bold text-white">7. Governing Law</h2>
        <p>
          These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.
        </p>
      </section>
    </div>
  );
}
