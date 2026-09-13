/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
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
