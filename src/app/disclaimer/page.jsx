export const metadata = {
  title: "Disclaimer — SnapBeat",
  description: "Legal and usage disclaimers for SnapBeat.",
};

export default function DisclaimerPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 text-gray-300 space-y-8 bg-[#0c0d10] min-h-screen">
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline mb-8 block">← Back to Studio</a>
      
      <h1 className="text-3xl font-black text-white">Legal Disclaimers</h1>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">User-Generated Content & Media Ownership</h2>
        <p className="text-sm leading-relaxed">
          Users retain full copyright and ownership rights to all original photos and assets they upload to SnapBeat. By using SnapBeat, you certify that you possess the necessary rights, licenses, and permissions for any media you upload.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">Audio Licensing & Fair Use</h2>
        <p className="text-sm leading-relaxed">
          SnapBeat provides built-in tracks that are properly licensed for use within the platform. However, if you choose to upload custom audio tracks, you are solely responsible for ensuring your use complies with relevant copyright laws and fair use doctrines. SnapBeat does not grant licenses for user-uploaded audio.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">Service Availability & Compute Limits</h2>
        <p className="text-sm leading-relaxed">
          SnapBeat's AI rendering relies on a cloud GPU cluster. While we strive for maximum uptime, service availability, rendering speeds, and processing SLAs are provided "as is" and may be subject to fluctuation based on server load and maintenance. We do not guarantee uninterrupted access to the rendering engine.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">Third-Party Advertising Disclosure</h2>
        <p className="text-sm leading-relaxed">
          SnapBeat displays third-party advertisements served by Google AdSense. The presence of these advertisements does not constitute an endorsement, guarantee, or warranty by SnapBeat of the products, services, or claims made in the ads. We are not responsible for the content of external websites linked through these advertisements.
        </p>
      </section>
    </div>
  );
}
