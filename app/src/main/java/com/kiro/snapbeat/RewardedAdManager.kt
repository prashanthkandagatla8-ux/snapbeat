package com.kiro.snapbeat

import android.app.Activity
import android.content.Context
import android.util.Log
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback

class RewardedAdManager(private val context: Context) {

    companion object {
        private const val TAG = "RewardedAdManager"
        // Official Google Sample AdMob Test Rewarded Ad Unit ID
        const val AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"
    }

    private var rewardedAd: RewardedAd? = null
    private var isLoading = false

    init {
        try {
            MobileAds.initialize(context) { status ->
                Log.d(TAG, "Google Mobile Ads initialized")
                loadRewardedAd()
            }
        } catch (e: Exception) {
            Log.w(TAG, "MobileAds initialization failed: ")
        }
    }

    fun loadRewardedAd() {
        if (isLoading || rewardedAd != null) return
        isLoading = true

        val adRequest = AdRequest.Builder().build()
        RewardedAd.load(
            context,
            AD_UNIT_ID,
            adRequest,
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedAd = ad
                    isLoading = false
                    Log.d(TAG, "Rewarded ad loaded successfully")
                }

                override fun onAdFailedToLoad(loadAdError: LoadAdError) {
                    rewardedAd = null
                    isLoading = false
                    Log.w(TAG, "Rewarded ad failed to load: ")
                }
            }
        )
    }

    fun isAdReady(): Boolean = rewardedAd != null

    /**
     * Shows the rewarded ad to unlock free video download/delivery.
     * Enforces watching the complete ad to unlock.
     */
    fun showRewardedAd(
        activity: Activity,
        onUnlocked: () -> Unit,
        onIncompleteOrFailed: (String) -> Unit = {}
    ) {
        val ad = rewardedAd
        if (ad != null) {
            var rewardEarned = false

            ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() {
                    rewardedAd = null
                    loadRewardedAd()
                    if (rewardEarned) {
                        onUnlocked()
                    } else {
                        onIncompleteOrFailed("Ad was closed before completion. Please watch the full ad to unlock your video.")
                    }
                }

                override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                    Log.w(TAG, "Ad failed to show: ${adError.message}")
                    rewardedAd = null
                    loadRewardedAd()
                    // Fallback to unlocking if ad service has an internal display failure
                    onUnlocked()
                }
            }

            ad.show(activity) { rewardItem ->
                Log.d(TAG, "User completed rewarded ad: ${rewardItem.type} ${rewardItem.amount}")
                rewardEarned = true
            }
        } else {
            Log.i(TAG, "Ad not ready yet; attempting reload")
            loadRewardedAd()
            onIncompleteOrFailed("Sponsor video is loading. Please wait a moment and try again.")
        }
    }
}
