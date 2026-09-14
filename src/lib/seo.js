/**
 * SnapBeat Central SEO Utility
 * Generates canonical metadata, Open Graph cards, Twitter metadata,
 * and JSON-LD structured data schemas for search engine indexability.
 */

export const SITE_URL = "https://www.snapbeat.app";
export const SITE_NAME = "SnapBeat";
export const DEFAULT_OG_IMAGE = `${SITE_URL}/assets/images/snapbeat_hero_art.png`;

/**
 * Construct standard Next.js metadata object
 */
export function buildPageMetadata({
  title,
  description,
  path = "",
  keywords = [],
  ogImage = DEFAULT_OG_IMAGE,
  type = "website",
}) {
  const canonicalUrl = `${SITE_URL}${path}`;

  return {
    title: `${title} | ${SITE_NAME}`,
    description,
    keywords: [
      "photo to video maker",
      "beat sync video maker",
      "photo reel maker",
      "instagram reel maker",
      "photo slideshow with music",
      ...keywords,
    ],
    alternates: {
      canonical: canonicalUrl,
    },
    openGraph: {
      title: `${title} | ${SITE_NAME}`,
      description,
      url: canonicalUrl,
      siteName: SITE_NAME,
      images: [
        {
          url: ogImage,
          width: 1200,
          height: 630,
          alt: title,
        },
      ],
      type,
    },
    twitter: {
      card: "summary_large_image",
      title: `${title} | ${SITE_NAME}`,
      description,
      images: [ogImage],
    },
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        "max-video-preview": -1,
        "max-image-preview": "large",
        "max-snippet": -1,
      },
    },
  };
}

/**
 * Generate JSON-LD schema for WebApplication
 */
export function getWebApplicationSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    name: "SnapBeat",
    url: SITE_URL,
    description:
      "Automated AI beat-synced photo-to-video reel maker. Transform your photo memories into rhythmically synchronized short-form videos with motion choreography.",
    applicationCategory: "MultimediaApplication",
    operatingSystem: "Web, iOS, Android, macOS, Windows",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "INR",
      category: "FreeTier",
    },
    browserRequirements: "Requires HTML5, WebGL, Modern Browser",
    featureList: [
      "AI audio onset beat detection",
      "14 kinetic motion choreography presets",
      "Photo to MP4 reel export in 9:16, 1:1, 16:9",
      "Instant 1-click guest access without signup",
      "Watermark-free 1080p master renders for Pro users",
    ],
  };
}

/**
 * Generate JSON-LD schema for Organization
 */
export function getOrganizationSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "SnapBeat Studio",
    url: SITE_URL,
    logo: `${SITE_URL}/assets/images/snapbeat_logo.png`,
    sameAs: [],
  };
}

/**
 * Generate JSON-LD schema for WebSite with search
 */
export function getWebSiteSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: "SnapBeat",
    url: SITE_URL,
  };
}

/**
 * Generate JSON-LD schema for Breadcrumbs
 */
export function getBreadcrumbSchema(items = []) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: item.name,
      item: `${SITE_URL}${item.path}`,
    })),
  };
}

/**
 * Generate JSON-LD schema for FAQPage
 */
export function getFaqSchema(faqs = []) {
  if (!faqs || faqs.length === 0) return null;
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.answer,
      },
    })),
  };
}

/**
 * Generate JSON-LD schema for Article / Blog post
 */
export function getArticleSchema({
  title,
  description,
  path,
  datePublished,
  dateModified,
  image = DEFAULT_OG_IMAGE,
}) {
  return {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: title,
    description,
    image,
    datePublished,
    dateModified: dateModified || datePublished,
    author: {
      "@type": "Organization",
      name: "SnapBeat Editorial Team",
      url: SITE_URL,
    },
    publisher: {
      "@type": "Organization",
      name: "SnapBeat",
      logo: {
        "@type": "ImageObject",
        url: `${SITE_URL}/assets/images/snapbeat_logo.png`,
      },
    },
    mainEntityOfPage: {
      "@type": "WebPage",
      "@id": `${SITE_URL}${path}`,
    },
  };
}
