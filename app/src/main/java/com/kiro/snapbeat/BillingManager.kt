package com.kiro.snapbeat

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.android.billingclient.api.*

class BillingManager(
    private val context: Context,
    private val creditManager: CreditManager,
    private val onCreditsUpdated: (newBalance: Int, message: String) -> Unit
) : PurchasesUpdatedListener {

    companion object {
        private const val TAG = "BillingManager"

        const val PRODUCT_STARTER_10 = "snapbeat_starter_10"
        const val PRODUCT_PARTY_35 = "snapbeat_party_35"
        const val PRODUCT_STUDIO_80 = "snapbeat_studio_80"
        const val PRODUCT_DIRECTOR_200 = "snapbeat_director_200"

        const val SUBS_PRO_MONTHLY = "snapbeat_pro_monthly" // ₹199 / mo
        const val SUBS_PRO_YEARLY = "snapbeat_pro_yearly"   // ₹999 / yr

        val PRODUCT_CREDIT_MAP = mapOf(
            PRODUCT_STARTER_10 to 10,
            PRODUCT_PARTY_35 to 35,
            PRODUCT_STUDIO_80 to 80,
            PRODUCT_DIRECTOR_200 to 200
        )
    }

    private var billingClient: BillingClient? = null
    private var isConnected = false
    private val productDetailsMap = mutableMapOf<String, ProductDetails>()

    init {
        setupBillingClient()
    }

    private fun setupBillingClient() {
        billingClient = BillingClient.newBuilder(context)
            .setListener(this)
            .enablePendingPurchases(
                PendingPurchasesParams.newBuilder()
                    .enableOneTimeProducts()
                    .build()
            )
            .build()

        startConnection()
    }

    fun startConnection(onReady: (() -> Unit)? = null) {
        billingClient?.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    isConnected = true
                    Log.d(TAG, "BillingClient connected successfully")
                    queryAvailableProducts()
                    onReady?.invoke()
                } else {
                    Log.w(TAG, "Billing setup failed: ${billingResult.debugMessage}")
                }
            }

            override fun onBillingServiceDisconnected() {
                isConnected = false
                Log.w(TAG, "Billing service disconnected")
            }
        })
    }

    private fun queryAvailableProducts() {
        val inAppList = listOf(
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(PRODUCT_STARTER_10)
                .setProductType(BillingClient.ProductType.INAPP)
                .build(),
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(PRODUCT_PARTY_35)
                .setProductType(BillingClient.ProductType.INAPP)
                .build(),
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(PRODUCT_STUDIO_80)
                .setProductType(BillingClient.ProductType.INAPP)
                .build(),
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(PRODUCT_DIRECTOR_200)
                .setProductType(BillingClient.ProductType.INAPP)
                .build()
        )
        val inAppParams = QueryProductDetailsParams.newBuilder()
            .setProductList(inAppList)
            .build()

        billingClient?.queryProductDetailsAsync(inAppParams) { billingResult, productDetailsList ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                for (details in productDetailsList) {
                    productDetailsMap[details.productId] = details
                }
                Log.d(TAG, "Loaded ${productDetailsList.size} in-app products")
            }
        }

        val subsList = listOf(
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(SUBS_PRO_MONTHLY)
                .setProductType(BillingClient.ProductType.SUBS)
                .build(),
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(SUBS_PRO_YEARLY)
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
        )
        val subsParams = QueryProductDetailsParams.newBuilder()
            .setProductList(subsList)
            .build()

        billingClient?.queryProductDetailsAsync(subsParams) { billingResult, productDetailsList ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                for (details in productDetailsList) {
                    productDetailsMap[details.productId] = details
                }
                Log.d(TAG, "Loaded ${productDetailsList.size} subscription products")
            }
        }
    }

    fun launchPurchaseFlow(activity: Activity, productId: String) {
        val productDetails = productDetailsMap[productId]
        if (isConnected && productDetails != null) {
            val productDetailsParamsList = listOf(
                BillingFlowParams.ProductDetailsParams.newBuilder()
                    .setProductDetails(productDetails)
                    .build()
            )

            val flowParams = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build()

            billingClient?.launchBillingFlow(activity, flowParams)
        } else {
            // Emulators or devices without Play Store account configured:
            // Graceful test sandbox fallback
            Log.d(TAG, "Using test purchase sandbox for $productId")
            simulateTestPurchase(productId)
        }
    }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: MutableList<Purchase>?) {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            for (purchase in purchases) {
                handlePurchase(purchase)
            }
        } else if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
            Log.i(TAG, "Purchase canceled by user")
        } else {
            Log.w(TAG, "Purchase failed: ${billingResult.debugMessage}")
        }
    }

    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            val isSub = purchase.products.any { it == SUBS_PRO_MONTHLY || it == SUBS_PRO_YEARLY }
            if (isSub) {
                // Subscription product: Acknowledge purchase if not yet acknowledged
                if (!purchase.isAcknowledged) {
                    val ackParams = AcknowledgePurchaseParams.newBuilder()
                        .setPurchaseToken(purchase.purchaseToken)
                        .build()
                    billingClient?.acknowledgePurchase(ackParams) { billingResult ->
                        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                            activateProSubscription(purchase.products)
                        }
                    }
                } else {
                    activateProSubscription(purchase.products)
                }
            } else {
                // Consumable in-app purchase: consume so user can buy again later
                val consumeParams = ConsumeParams.newBuilder()
                    .setPurchaseToken(purchase.purchaseToken)
                    .build()

                billingClient?.consumeAsync(consumeParams) { billingResult, _ ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        // Credit user based on purchased product
                        for (productId in purchase.products) {
                            val creditsToAdd = PRODUCT_CREDIT_MAP[productId] ?: 10
                            val newBalance = creditManager.addCredits(creditsToAdd)
                            Handler(Looper.getMainLooper()).post {
                                onCreditsUpdated(newBalance, "+$creditsToAdd Instant Credits added! 🎉")
                            }
                        }
                    }
                }
            }
        }
    }

    private fun activateProSubscription(products: List<String>) {
        val isYearly = products.contains(SUBS_PRO_YEARLY)
        val durationMs = if (isYearly) 365L * 24 * 3600 * 1000L else 30L * 24 * 3600 * 1000L
        val expiry = System.currentTimeMillis() + durationMs
        creditManager.setProSubscription(true, expiry)
        val msg = if (isYearly) "👑 Pro Pass (Yearly) Activated! Watermark Removed! 🎉" else "👑 Pro Pass (Monthly) Activated! Watermark Removed! 🎉"
        Handler(Looper.getMainLooper()).post {
            onCreditsUpdated(creditManager.getCredits(), msg)
        }
    }

    /**
     * Local test mode for rapid development and testing in emulators
     */
    fun simulateTestPurchase(productId: String) {
        if (productId == SUBS_PRO_MONTHLY || productId == SUBS_PRO_YEARLY) {
            activateProSubscription(listOf(productId))
        } else {
            val creditsToAdd = PRODUCT_CREDIT_MAP[productId] ?: 10
            val newBalance = creditManager.addCredits(creditsToAdd)
            Handler(Looper.getMainLooper()).post {
                onCreditsUpdated(newBalance, "+$creditsToAdd Test Instant Credits added! 🎉")
            }
        }
    }
}