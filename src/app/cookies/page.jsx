export const metadata = {
  title: "Cookie Policy — SnapBeat",
  description: "Learn about how SnapBeat uses cookies.",
};

export default function CookiesPage() {
  return (
    <div className="max-w-3xl mx-auto px-6 py-12 text-gray-300 space-y-8 bg-[#0c0d10] min-h-screen">
      <nav className="text-xs font-bold mb-8">
        <a href="/" className="text-amber-400 hover:underline">Studio</a> <span className="text-gray-500">/</span> <span className="text-white">Cookie Policy</span>
      </nav>
      
      <h1 className="text-3xl font-black text-white">Cookie Policy</h1>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">What are cookies?</h2>
        <p className="text-sm leading-relaxed">
          Cookies are small text files that are placed on your computer or mobile device when you visit a website. They are widely used to make websites work, or work more efficiently, as well as to provide information to the owners of the site.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">How SnapBeat Uses Cookies</h2>
        <p className="text-sm leading-relaxed">We use cookies in the following categories:</p>
        <ul className="list-disc pl-5 space-y-2 text-sm">
          <li><strong>Strictly Necessary Cookies:</strong> These are essential for you to browse the website and use its features, such as accessing secure areas of the site (e.g., session and authentication cookies).</li>
          <li><strong>Performance & Analytics Cookies:</strong> We use Google Analytics 4 to collect information about how visitors use our website, which helps us improve the site's performance and user experience.</li>
          <li><strong>Advertising Cookies (Google AdSense & DoubleClick DART):</strong> These cookies are used to deliver advertisements more relevant to you and your interests. They are also used to limit the number of times you see an advertisement as well as help measure the effectiveness of the advertising campaign.</li>
        </ul>
      </section>

      <section className="space-y-4 bg-gray-900 p-6 rounded-xl border border-gray-800">
        <h2 className="text-xl font-bold text-white">Google AdSense Disclosures</h2>
        <p className="text-sm leading-relaxed">
          We use Google AdSense to serve ads on our site. Google, as a third-party vendor, uses cookies to serve ads on SnapBeat.
        </p>
        <ul className="list-disc pl-5 space-y-2 text-sm">
          <li>Third party vendors, including Google, use cookies to serve ads based on a user's prior visits to your website or other websites.</li>
          <li>Google's use of advertising cookies enables it and its partners to serve ads to our users based on their visit to our sites and/or other sites on the Internet.</li>
          <li>Users may opt out of personalized advertising by visiting <a href="https://www.google.com/settings/ads" target="_blank" rel="noopener noreferrer" className="text-amber-400 underline hover:text-amber-300">Google Ads Settings</a>.</li>
          <li>Alternatively, you can opt out of a third-party vendor's use of cookies for personalized advertising by visiting <a href="https://www.aboutads.info/choices/" target="_blank" rel="noopener noreferrer" className="text-amber-400 underline hover:text-amber-300">aboutads.info</a>.</li>
        </ul>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-bold text-white">Browser Cookie Controls</h2>
        <p className="text-sm leading-relaxed">
          You can set your browser to refuse all or some browser cookies, or to alert you when websites set or access cookies. For more information on how to manage cookies in your specific browser, please consult your browser's help documentation:
        </p>
        <ul className="list-disc pl-5 space-y-1 text-sm">
          <li><a href="https://support.google.com/chrome/answer/95647" target="_blank" rel="noopener noreferrer" className="text-amber-400 hover:underline">Google Chrome</a></li>
          <li><a href="https://support.apple.com/guide/safari/manage-cookies-and-website-data-sfri11471/mac" target="_blank" rel="noopener noreferrer" className="text-amber-400 hover:underline">Apple Safari</a></li>
          <li><a href="https://support.mozilla.org/en-US/kb/enhanced-tracking-protection-firefox-desktop" target="_blank" rel="noopener noreferrer" className="text-amber-400 hover:underline">Mozilla Firefox</a></li>
          <li><a href="https://support.microsoft.com/en-us/microsoft-edge/delete-cookies-in-microsoft-edge-63947406-40ac-c3b8-57b9-2a946a29ae09" target="_blank" rel="noopener noreferrer" className="text-amber-400 hover:underline">Microsoft Edge</a></li>
        </ul>
      </section>
    </div>
  );
}
