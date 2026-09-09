package com.kiro.snapbeat

import android.content.Context
import android.telephony.TelephonyManager
import java.util.Locale
import java.util.TimeZone

data class StorePricing(
    val regionCode: String,
    val regionDisplayName: String,
    val currencySymbol: String,
    val removeWatermarkPrice: String,
    val removeWatermarkSubtitle: String,
    val proModePrice: String,
    val proModeSubtitle: String,
    val starterPrice: String,
    val starterSubtitle: String,
    val partyPrice: String,
    val partySubtitle: String,
    val studioPrice: String,
    val studioSubtitle: String,
    val directorPrice: String,
    val directorSubtitle: String,
    val proMonthlyPrice: String,
    val proYearlyPrice: String,
    val proYearlySavings: String
)

object RegionPricingManager {

    private const val PREFS_NAME = "snapbeat_region_prefs"
    private const val KEY_REGION = "user_configured_region"

    // Default is explicitly kept as USD ($) for global Play Store users
    const val DEFAULT_REGION = "US"

    private val PRICING_MAP = mapOf(
        "US" to StorePricing(
            regionCode = "US",
            regionDisplayName = "🇺🇸 United States (USD $)",
            currencySymbol = "$",
            removeWatermarkPrice = "$0.99",
            removeWatermarkSubtitle = "Permanently remove watermarks on all renders",
            proModePrice = "$1.99",
            proModeSubtitle = "Full Pro Mode • All Templates • 1080p Master • No Watermark",
            starterPrice = "$0.99",
            starterSubtitle = "Render up to 10 quick reels • ~10¢/credit",
            partyPrice = "$2.99",
            partySubtitle = "Full songs and event montages • ~8.5¢/credit",
            studioPrice = "$5.99",
            studioSubtitle = "Multiple full-length event recaps • ~7.5¢/credit",
            directorPrice = "$12.99",
            directorSubtitle = "Pro creators & power videographers • ~6.5¢/credit",
            proMonthlyPrice = "$1.99 / MO",
            proYearlyPrice = "$9.99 / YR",
            proYearlySavings = "SAVE 58% ($0.83/mo)"
        ),
        "IN" to StorePricing(
            regionCode = "IN",
            regionDisplayName = "🇮🇳 India (INR ₹)",
            currencySymbol = "₹",
            removeWatermarkPrice = "₹99",
            removeWatermarkSubtitle = "Permanently remove watermarks on all renders",
            proModePrice = "₹199",
            proModeSubtitle = "Full Pro Mode • All Templates • 1080p Master • No Watermark",
            starterPrice = "₹79",
            starterSubtitle = "Render up to 10 quick reels • ~₹8/credit",
            partyPrice = "₹249",
            partySubtitle = "Full songs and event montages • ~₹7/credit",
            studioPrice = "₹499",
            studioSubtitle = "Multiple full-length event recaps • ~₹6/credit",
            directorPrice = "₹999",
            directorSubtitle = "Pro creators & power videographers • ~₹5/credit",
            proMonthlyPrice = "₹199 / MO",
            proYearlyPrice = "₹999 / YR",
            proYearlySavings = "SAVE 58% (₹83/mo)"
        ),
        "GB" to StorePricing(
            regionCode = "GB",
            regionDisplayName = "🇬🇧 United Kingdom (GBP £)",
            currencySymbol = "£",
            removeWatermarkPrice = "£0.89",
            removeWatermarkSubtitle = "Permanently remove watermarks on all renders",
            proModePrice = "£1.89",
            proModeSubtitle = "Full Pro Mode • All Templates • 1080p Master • No Watermark",
            starterPrice = "£0.89",
            starterSubtitle = "Render up to 10 quick reels • ~9p/credit",
            partyPrice = "£2.49",
            partySubtitle = "Full songs and event montages • ~7p/credit",
            studioPrice = "£4.99",
            studioSubtitle = "Multiple full-length event recaps • ~6p/credit",
            directorPrice = "£9.99",
            directorSubtitle = "Pro creators & power videographers • ~5p/credit",
            proMonthlyPrice = "£1.89 / MO",
            proYearlyPrice = "£8.99 / YR",
            proYearlySavings = "SAVE 58% (£0.75/mo)"
        ),
        "EU" to StorePricing(
            regionCode = "EU",
            regionDisplayName = "🇪🇺 European Union (EUR €)",
            currencySymbol = "€",
            removeWatermarkPrice = "€0.99",
            removeWatermarkSubtitle = "Permanently remove watermarks on all renders",
            proModePrice = "€1.99",
            proModeSubtitle = "Full Pro Mode • All Templates • 1080p Master • No Watermark",
            starterPrice = "€0.99",
            starterSubtitle = "Render up to 10 quick reels • ~10c/credit",
            partyPrice = "€2.99",
            partySubtitle = "Full songs and event montages • ~8.5c/credit",
            studioPrice = "€5.99",
            studioSubtitle = "Multiple full-length event recaps • ~7.5c/credit",
            directorPrice = "€11.99",
            directorSubtitle = "Pro creators & power videographers • ~6c/credit",
            proMonthlyPrice = "€1.99 / MO",
            proYearlyPrice = "€9.99 / YR",
            proYearlySavings = "SAVE 58% (€0.83/mo)"
        )
    )

    fun getActiveRegion(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (prefs.contains(KEY_REGION)) {
            val saved = prefs.getString(KEY_REGION, null)
            if (!saved.isNullOrEmpty()) return saved
        }
        // Auto-detect based on device country / locale / timezone
        return detectDeviceRegion(context)
    }

    fun setActiveRegion(context: Context, regionCode: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_REGION, regionCode.uppercase()).apply()
    }

    fun clearActiveRegionOverride(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().remove(KEY_REGION).apply()
    }

    fun detectDeviceRegion(context: Context): String {
        try {
            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            val netCountry = tm?.networkCountryIso?.uppercase()
            if (!netCountry.isNullOrEmpty() && netCountry.length == 2) {
                return normalizeRegion(netCountry)
            }
            val simCountry = tm?.simCountryIso?.uppercase()
            if (!simCountry.isNullOrEmpty() && simCountry.length == 2) {
                return normalizeRegion(simCountry)
            }
            val localeCountry = Locale.getDefault().country?.uppercase()
            if (!localeCountry.isNullOrEmpty() && localeCountry.length == 2) {
                return normalizeRegion(localeCountry)
            }
            // Check Indian TimeZone (IST / Asia/Kolkata / Asia/Calcutta / rawOffset 19800000 ms)
            val tz = TimeZone.getDefault()
            val tzId = tz.id.lowercase()
            if (tzId.contains("kolkata") || tzId.contains("calcutta") || tz.rawOffset == 19800000) {
                return "IN"
            }
        } catch (e: Exception) {
            // fallback
        }
        return DEFAULT_REGION
    }

    private fun normalizeRegion(code: String): String {
        if (code == "IN") return "IN"
        if (code == "GB" || code == "UK") return "GB"
        if (code in listOf("DE", "FR", "IT", "ES", "NL", "BE", "AT", "PT", "IE", "FI", "GR")) return "EU"
        if (code == "US") return "US"
        return code
    }

    fun getPricing(regionCode: String): StorePricing {
        val normalized = normalizeRegion(regionCode)
        return PRICING_MAP[normalized] ?: PRICING_MAP[DEFAULT_REGION] ?: PRICING_MAP["US"]!!
    }

    fun getSupportedRegions(): List<Pair<String, String>> {
        return listOf(
            "US" to "🇺🇸 United States (USD $) [Default]",
            "IN" to "🇮🇳 India (INR ₹)",
            "AUTO" to "🌐 Auto-Detect From Device",
            "GB" to "🇬🇧 United Kingdom (GBP £)",
            "EU" to "🇪🇺 European Union (EUR €)"
        )
    }
}
