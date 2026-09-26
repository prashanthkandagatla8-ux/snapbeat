"use client";

import { useState } from 'react';

export default function ContactPage() {
  const [formData, setFormData] = useState({ name: '', email: '', category: 'Support', subject: '', message: '' });
  const [status, setStatus] = useState('');

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "ContactPage",
    "name": "Contact SnapBeat Support",
    "description": "Get in touch with the SnapBeat team for support, billing, or partnerships."
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setStatus('Sending...');
    // Simulate API call
    setTimeout(() => {
      setStatus('Message sent successfully! We will get back to you within 24-48 business hours.');
      setFormData({ name: '', email: '', category: 'Support', subject: '', message: '' });
    }, 1000);
  };

  return (
    <div className="max-w-4xl mx-auto px-6 py-12 text-gray-300 space-y-10 bg-[#0c0d10] min-h-screen">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <a href="/" className="text-amber-400 text-xs font-bold hover:underline mb-8 block">← Back to Studio</a>
      
      <section className="text-center space-y-4">
        <h1 className="text-4xl font-black text-white">Contact Us</h1>
        <p className="text-gray-400">We're here to help. Reach out to the right team below.</p>
      </section>

      <div className="grid md:grid-cols-2 gap-12">
        <section className="space-y-6">
          <div className="space-y-2">
            <h2 className="text-xl font-bold text-white">Direct Email</h2>
            <p className="text-sm">
              <strong className="text-amber-400">Support:</strong> support@snapbeat.app<br/>
              <strong className="text-amber-400">Business & Partnerships:</strong> team@snapbeat.app
            </p>
          </div>
          
          <div className="space-y-2">
            <h2 className="text-xl font-bold text-white">Response SLA</h2>
            <p className="text-sm">We aim to respond to all inquiries within <strong>24-48 business hours</strong>.</p>
          </div>

          <div className="space-y-4">
            <h2 className="text-xl font-bold text-white border-b border-gray-800 pb-2">Quick Help & FAQ</h2>
            <div className="space-y-2 text-sm">
              <details className="cursor-pointer group">
                <summary className="font-semibold text-amber-400">How fast are render speeds?</summary>
                <p className="mt-2 text-gray-400 pl-4">Pro users enjoy priority queue slots with renders typically completing under 10 seconds. Free tier speeds depend on server load.</p>
              </details>
              <details className="cursor-pointer group">
                <summary className="font-semibold text-amber-400">How do I download my video?</summary>
                <p className="mt-2 text-gray-400 pl-4">Once rendering is complete, a "Download" button will appear on the final preview screen.</p>
              </details>
              <details className="cursor-pointer group">
                <summary className="font-semibold text-amber-400">What audio formats are supported?</summary>
                <p className="mt-2 text-gray-400 pl-4">We support MP3, WAV, and AAC formats for custom audio uploads.</p>
              </details>
            </div>
          </div>
        </section>

        <section className="bg-gray-900 p-6 rounded-xl border border-gray-800">
          <h2 className="text-2xl font-bold text-white mb-6">Send us a message</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Name</label>
              <input type="text" required className="w-full bg-gray-800 border border-gray-700 rounded-md p-2 text-white" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Email</label>
              <input type="email" required className="w-full bg-gray-800 border border-gray-700 rounded-md p-2 text-white" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Category</label>
              <select className="w-full bg-gray-800 border border-gray-700 rounded-md p-2 text-white" value={formData.category} onChange={e => setFormData({...formData, category: e.target.value})}>
                <option>Support</option>
                <option>Bug Report</option>
                <option>Billing</option>
                <option>Partnership</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Subject</label>
              <input type="text" required className="w-full bg-gray-800 border border-gray-700 rounded-md p-2 text-white" value={formData.subject} onChange={e => setFormData({...formData, subject: e.target.value})} />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Message</label>
              <textarea required rows="4" className="w-full bg-gray-800 border border-gray-700 rounded-md p-2 text-white" value={formData.message} onChange={e => setFormData({...formData, message: e.target.value})}></textarea>
            </div>
            <button type="submit" className="w-full bg-amber-500 hover:bg-amber-400 text-gray-900 font-bold py-2 px-4 rounded transition-colors">Submit</button>
            {status && <p className="text-sm text-center mt-4 text-amber-400">{status}</p>}
          </form>
        </section>
      </div>
    </div>
  );
}
