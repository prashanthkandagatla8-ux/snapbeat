package com.kiro.snapbeat

import android.content.Context
import java.util.UUID

class CreditManager(context: Context) {

    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    companion object {
        private const val PREFS_NAME = "snapbeat_credit_ledger_v1"
        private const val KEY_CREDITS = "user_credit_balance"
        private const val KEY_DEVICE_ID = "anonymous_device_id"
        private const val KEY_INITIALIZED = "welcome_credits_granted"
        private const val KEY_PRO_ACTIVE = "snapbeat_pro_active"
        private const val KEY_PRO_EXPIRY = "snapbeat_pro_expiry_ms"
        private const val KEY_WATERMARK_REMOVED = "snapbeat_watermark_removed"
        private const val KEY_PRO_MODE_ENABLED = "snapbeat_pro_mode_enabled"
        const val DEFAULT_WELCOME_CREDITS = 2
    }

    init {
        // Grant 2 Welcome Credits on first install
        if (!prefs.getBoolean(KEY_INITIALIZED, false)) {
            prefs.edit()
                .putInt(KEY_CREDITS, DEFAULT_WELCOME_CREDITS)
                .putBoolean(KEY_INITIALIZED, true)
                .putString(KEY_DEVICE_ID, UUID.randomUUID().toString())
                .apply()
        }
    }

    fun getDeviceId(): String {
        var id = prefs.getString(KEY_DEVICE_ID, null)
        if (id.isNullOrEmpty()) {
            id = UUID.randomUUID().toString()
            prefs.edit().putString(KEY_DEVICE_ID, id).apply()
        }
        return id
    }

    fun getCredits(): Int {
        return prefs.getInt(KEY_CREDITS, 0)
    }

    @Synchronized
    fun addCredits(amount: Int): Int {
        val current = getCredits()
        val newTotal = current + amount
        prefs.edit().putInt(KEY_CREDITS, newTotal).apply()
        return newTotal
    }

    @Synchronized
    fun deductCredits(amount: Int): Boolean {
        val current = getCredits()
        if (current >= amount) {
            prefs.edit().putInt(KEY_CREDITS, current - amount).apply()
            return true
        }
        return false
    }

    /**
     * Fair duration and quality calculator:
     * - <= 30s (Stories, Shorts, TikTok): 1 credit
     * - 31s - 60s (Standard Reel): 2 credits
     * - 61s - 120s (2m Clip): 3 credits
     * - 121s - 210s (3.5m Full Song): 5 credits
     * - 211s - 300s (5m Event Recap): 8 credits
     * - > 300s (Full Event Montage up to 10m+): 15 credits
     * - isMasterQuality adds 1 credit
     */
    fun calculateRequiredCredits(durationSeconds: Int, isMasterQuality: Boolean = false): Int {
        val safeDuration = maxOf(1, durationSeconds)
        val base = when {
            safeDuration <= 30 -> 1
            safeDuration <= 60 -> 2
            safeDuration <= 120 -> 3
            safeDuration <= 210 -> 5
            safeDuration <= 300 -> 8
            else -> 15
        }
        return if (isMasterQuality) base + 1 else base
    }

    /**
     * Pro Pass Subscription Management (₹199/mo or ₹999/yr)
     * - Removes watermarks on all renders
     * - Removes all ads permanently
     * - Unlimited renders on VPS queue
     */
    fun isProSubscriber(): Boolean {
        val active = prefs.getBoolean(KEY_PRO_ACTIVE, false)
        if (!active) return false
        val expiry = prefs.getLong(KEY_PRO_EXPIRY, 0L)
        if (expiry > 0 && System.currentTimeMillis() > expiry) {
            // Expired
            setProSubscription(false, 0L)
            return false
        }
        return true
    }

    fun setProSubscription(active: Boolean, expiryEpochMs: Long = 0L) {
        prefs.edit()
            .putBoolean(KEY_PRO_ACTIVE, active)
            .putLong(KEY_PRO_EXPIRY, expiryEpochMs)
            .apply()
        if (active) {
            setWatermarkRemoved(true)
            setProModeEnabled(true)
        }
    }

    fun isWatermarkRemoved(): Boolean {
        return prefs.getBoolean(KEY_WATERMARK_REMOVED, false) || isProModeEnabled() || isProSubscriber()
    }

    fun setWatermarkRemoved(removed: Boolean) {
        prefs.edit().putBoolean(KEY_WATERMARK_REMOVED, removed).apply()
    }

    fun isProModeEnabled(): Boolean {
        return prefs.getBoolean(KEY_PRO_MODE_ENABLED, false) || isProSubscriber()
    }

    fun setProModeEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_PRO_MODE_ENABLED, enabled).apply()
        if (enabled) {
            setWatermarkRemoved(true)
        }
    }

    /**
     * Watermark policy:
     * - Watermark removed / Pro enabled: NO watermark
     * - Instant Serverless (credits): NO watermark
     * - Free VPS Queue (non-pro / watermark active): YES, branded SnapBeat badge
     */
    fun shouldWatermark(isInstant: Boolean): Boolean {
        if (isInstant || isWatermarkRemoved()) return false
        return true
    }

    /**
     * Ad policy:
     * - Instant Serverless renders skip ads.
     * - Free VPS queue renders view rewarded ad.
     */
    fun shouldShowAd(isInstant: Boolean): Boolean {
        return !isInstant
    }
}