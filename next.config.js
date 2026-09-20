/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    NEXT_PUBLIC_GOOGLE_CLIENT_ID: "826942667807-7ii2t4fu8nt956lqcjodnjm29kg7t1rg.apps.googleusercontent.com",
  },
  async rewrites() {
    return [
      {
        source: '/api/health',
        destination: 'https://api.snapbeat.app/api/health',
      },
      {
        source: '/api/render/:path*',
        destination: 'https://api.snapbeat.app/api/render/:path*',
      },
      {
        source: '/api/v2/:path*',
        destination: 'https://api.snapbeat.app/api/v2/:path*',
      },
      {
        source: '/outputs/:path*',
        destination: 'https://api.snapbeat.app/outputs/:path*',
      },
    ];
  },
  async redirects() {
    return [
      {
        source: '/join',
        destination: 'https://groups.google.com/g/snapbeat-testers',
        permanent: true,
      },
      {
        source: '/beta',
        destination: 'https://play.google.com/apps/testing/com.kiro.snapbeat',
        permanent: true,
      },
    ];
  },
};

module.exports = nextConfig;
