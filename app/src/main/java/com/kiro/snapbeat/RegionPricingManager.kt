package com.kiro.snapbeat

import android.content.Context
import android.telephony.TelephonyManager
import java.util.Locale

data class StorePricing(
    val regionCode: String,
    val regionDisplayName: String,
    val currencySymbol: String,
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

    // Default is explicitly set to India ("IN") per user request
    const val DEFAULT_REGION = "IN"

    private val PRICING_MAP = mapOf(
        "IN" to StorePricing(
            regionCode = "IN",
            regionDisplayName = "🇮🇳 India (INR ₹)",
            currencySymbol = "₹",
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
        "US" to StorePricing(
            regionCode = "US",
            regionDisplayName = "🇺🇸 United States (USD $)",
            currencySymbol = "$",
            starterPrice = "$0.99",
            starterSubtitle = "Render up to 10 quick reels • ~10¢/credit",
            partyPrice = "$2.99",
            partySubtitle = "Full songs and event montages • ~8.5¢/credit",
            studioPrice = "$5.99",
            studioSubtitle = "Multiple full-length event recaps • ~7.5¢/credit",
            directorPrice = "$12.99",
            directorSubtitle = "Pro creators & power videographers • ~6.5¢/credit",
            proMonthlyPrice = "$2.99 / MO",
            proYearlyPrice = "$14.99 / YR",
            proYearlySavings = "SAVE 58% ($1.25/mo)"
        ),
        "GB" to StorePricing(
            regionCode = "GB",
            regionDisplayName = "🇬🇧 United Kingdom (GBP £)",
            currencySymbol = "£",
            starterPrice = "£0.89",
            starterSubtitle = "Render up to 10 quick reels • ~9p/credit",
            partyPrice = "£2.49",
            partySubtitle = "Full songs and event montages • ~7p/credit",
            studioPrice = "£4.99",
            studioSubtitle = "Multiple full-length event recaps • ~6p/credit",
            directorPrice = "£9.99",
            directorSubtitle = "Pro creators & power videographers • ~5p/credit",
            proMonthlyPrice = "£2.49 / MO",
            proYearlyPrice = "£12.99 / YR",
            proYearlySavings = "SAVE 58% (£1.08/mo)"
        ),
        "EU" to StorePricing(
            regionCode = "EU",
            regionDisplayName = "🇪🇺 European Union (EUR €)",
            currencySymbol = "€",
            starterPrice = "€0.99",
            starterSubtitle = "Render up to 10 quick reels • ~10c/credit",
            partyPrice = "€2.99",
            partySubtitle = "Full songs and event montages • ~8.5c/credit",
            studioPrice = "€5.99",
            studioSubtitle = "Multiple full-length event recaps • ~7.5c/credit",
            directorPrice = "€11.99",
            directorSubtitle = "Pro creators & power videographers • ~6c/credit",
            proMonthlyPrice = "€2.99 / MO",
            proYearlyPrice = "€14.99 / YR",
            proYearlySavings = "SAVE 58% (€1.25/mo)"
        )
    )

    fun getActiveRegion(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_REGION, DEFAULT_REGION) ?: DEFAULT_REGION
    }

    fun setActiveRegion(context: Context, regionCode: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_REGION, regionCode.uppercase()).apply()
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
        return PRICING_MAP[normalized] ?: PRICING_MAP[DEFAULT_REGION] ?: PRICING_MAP["IN"]!!
    }

    fun getSupportedRegions(): List<Pair<String, String>> {
        return listOf(
            "IN" to "🇮🇳 India (INR ₹)",
            "AUTO" to "🌐 Auto-Detect From Device",
            "US" to "🇺🇸 United States (USD $)",
            "GB" to "🇬🇧 United Kingdom (GBP £)",
            "EU" to "🇪🇺 European Union (EUR €)"
        )
    }
}
