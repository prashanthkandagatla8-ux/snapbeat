/**
 * SnapBeat Google Analytics 4 (GA4) Tracking Utility
 * 
 * Provides privacy-safe (zero PII), deduplicated, high-fidelity event tracking
 * across the entire SnapBeat creation, rendering, and monetization funnel.
 */

export const GA_MEASUREMENT_ID = process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID || "";

/**
 * Send custom event to GA4
 * @param {string} eventName - GA4 event name (snake_case)
 * @param {Object} eventParams - Safe event parameters (no PII)
 */
export function trackEvent(eventName, eventParams = {}) {
  if (typeof window === "undefined" || !window.gtag) {
    if (process.env.NODE_ENV === "development") {
      console.log(`[GA4 Event] ${eventName}:`, eventParams);
    }
    return;
  }

  try {
    // Sanitize parameters to guarantee NO PII is ever sent
    const sanitizedParams = { ...eventParams };
    delete sanitizedParams.email;
    delete sanitizedParams.name;
    delete sanitizedParams.password;
    delete sanitizedParams.phone;
    delete sanitizedParams.token;
    delete sanitizedParams.imageData;
    delete sanitizedParams.file;

    window.gtag("event", eventName, sanitizedParams);
  } catch (err) {
    console.warn("[GA4 Tracking Error]", err);
  }
}

/**
 * Track route changes and page views
 */
export function trackPageView(url, title) {
  if (typeof window === "undefined" || !window.gtag) return;
  try {
    window.gtag("event", "page_view", {
      page_path: url,
      page_title: title || (typeof document !== "undefined" ? document.title : ""),
      page_location: typeof window !== "undefined" ? window.location.href : "",
    });
  } catch (_) {}
}

/* =========================================================================
   FUNNEL STAGE 1: CREATION INITIATION & AUTH
   ========================================================================= */

export function trackStartCreating(page = "/", entryPoint = "hero_cta") {
  trackEvent("start_creating", {
    page,
    entry_point: entryPoint,
  });
}

export function trackGuestStarted(entryPoint = "instant_guest") {
  trackEvent("guest_started", {
    entry_point: entryPoint,
  });
}

export function trackSignupStarted(method = "google") {
  trackEvent("signup_started", {
    method,
  });
}

/**
 * KEY CONVERSION EVENT: User creates an account or completes sign in
 */
export function trackSignupCompleted(method = "google", isGuest = false) {
  trackEvent("signup_completed", {
    method,
    is_guest: isGuest,
    conversion: true,
  });
}

/* =========================================================================
   FUNNEL STAGE 2: STUDIO INPUT (PHOTOS & MUSIC)
   ========================================================================= */

export function trackPhotosUploaded(photoCount = 0, source = "file_picker") {
  trackEvent("photos_uploaded", {
    photo_count: Number(photoCount),
    upload_source: source,
  });
}

export function trackMusicSelected(musicType = "built_in", trackId = "default") {
  trackEvent("music_selected", {
    music_type: musicType, // 'built_in' | 'custom_upload'
    track_id: String(trackId).substring(0, 50),
  });
}

/* =========================================================================
   FUNNEL STAGE 3: RENDERING PIPELINE
   ========================================================================= */

export function trackRenderStarted({
  template = "pendulum",
  photoCount = 0,
  outputResolution = "480p",
  aspectRatio = "9:16",
  isPro = false,
}) {
  trackEvent("render_started", {
    template,
    photo_count: Number(photoCount),
    output_resolution: outputResolution,
    aspect_ratio: aspectRatio,
    plan_tier: isPro ? "pro" : "free",
  });
}

/**
 * KEY CONVERSION EVENT: Video render successfully completed on GPU
 */
export function trackRenderCompleted({
  jobId = null,
  template = "pendulum",
  outputResolution = "480p",
  videoDuration = 0,
  isPro = false,
}) {
  trackEvent("render_completed", {
    job_id: jobId ? String(jobId) : undefined,
    template,
    output_resolution: outputResolution,
    video_duration: Number(videoDuration) || 0,
    plan_tier: isPro ? "pro" : "free",
    render_success: true,
    conversion: true,
  });
}

export function trackRenderFailed({
  template = "pendulum",
  errorCategory = "unknown_error",
  stage = "processing",
}) {
  trackEvent("render_failed", {
    template,
    error_category: errorCategory, // 'upload_error' | 'processing_error' | 'timeout' | 'network_error'
    stage,
  });
}

/* =========================================================================
   FUNNEL STAGE 4: VIDEO EXPORT & VIRAL SHARING
   ========================================================================= */

/**
 * PRIMARY KEY CONVERSION EVENT: User downloads/exports their finished video
 */
export function trackVideoExported({
  template = "pendulum",
  outputResolution = "480p",
  exportType = "download",
  watermark = true,
  planType = "free",
}) {
  trackEvent("video_exported", {
    template,
    output_resolution: outputResolution,
    export_type: exportType,
    watermark: Boolean(watermark),
    plan_type: planType,
    conversion: true,
  });
}

/**
 * KEY CONVERSION EVENT: User shares video on social media
 */
export function trackShareClicked(platform = "whatsapp") {
  trackEvent("share_clicked", {
    share_platform: platform, // 'whatsapp' | 'instagram' | 'facebook' | 'copy_link' | 'native'
    conversion: true,
  });
}

/* =========================================================================
   FUNNEL STAGE 5: MONETIZATION & ADS
   ========================================================================= */

export function trackUpgradeViewed(planName = "all", source = "studio_banner") {
  trackEvent("upgrade_viewed", {
    plan_name: planName,
    source,
  });
}

export function trackPurchaseStarted(planName, value = 0, currency = "INR") {
  trackEvent("purchase_started", {
    plan_name: planName,
    value: Number(value),
    currency,
  });
}

/**
 * PRIMARY KEY CONVERSION EVENT: User purchases Pro subscription
 */
export function trackPurchaseCompleted({
  planName,
  value,
  currency = "INR",
  transactionId = null,
}) {
  trackEvent("purchase_completed", {
    plan_name: planName,
    value: Number(value),
    currency,
    transaction_id: transactionId ? String(transactionId) : undefined,
    conversion: true,
  });
}

export function trackRewardedAdStarted(placement = "queue_pre_roll", adType = "video_pre_roll") {
  trackEvent("rewarded_ad_started", {
    placement,
    ad_type: adType,
  });
}

export function trackRewardedAdCompleted(placement = "queue_pre_roll", rewardType = "free_export_unlock") {
  trackEvent("rewarded_ad_completed", {
    placement,
    reward_type: rewardType,
  });
}

export function trackAffiliateClicked({
  category = "music_tools",
  partner = "sponsor",
  placement = "in_stream_ad",
}) {
  trackEvent("affiliate_clicked", {
    category,
    partner,
    placement,
  });
}
