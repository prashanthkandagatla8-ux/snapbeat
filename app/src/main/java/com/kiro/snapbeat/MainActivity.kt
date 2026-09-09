package com.kiro.snapbeat

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.Toast
import android.widget.MediaController
import android.media.MediaMetadataRetriever
import android.widget.SeekBar
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.kiro.snapbeat.databinding.ActivityMainBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.asRequestBody
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.TimeUnit
import android.text.Editable
import android.text.TextWatcher
import android.widget.AdapterView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.ItemTouchHelper
import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import androidx.core.content.ContextCompat
import androidx.core.view.WindowInsetsControllerCompat
import android.Manifest
import android.content.pm.PackageManager
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var creditManager: CreditManager
    private lateinit var billingManager: BillingManager
    private lateinit var rewardedAdManager: RewardedAdManager
    private var selectedMusicUri: Uri? = null
    private var selectedPhotos = mutableListOf<Uri>()
    private lateinit var photoOrderAdapter: PhotoOrderAdapter
    private var lastVideoUri: android.net.Uri? = null
    private val unlockedVideoUris = mutableSetOf<String>()
    private var audioDurationSeconds: Int = 0
    private var audioStartSeconds: Int = 0
    private var audioEndSeconds: Int = 0
    private var isFullTrack: Boolean = true
    enum class NavPage {
        AUTO,
        PRO,
        QUEUE
    }
    private var currentNavPage: NavPage = NavPage.AUTO
    private var isDarkMode: Boolean = true
    private val KEY_DARK_MODE = "is_dark_mode_enabled"
    private val PREFS_NAME = "snapbeat_prefs"
    private val KEY_PRIVACY_ACCEPTED = "privacy_policy_accepted_v1"
    private val PRIVACY_POLICY_URL = "https://github.com/prashanthkandagatla8-ux/snapbeat/blob/android/PRIVACY_POLICY.md"

    private val KEY_CACHED_SERVER_URL = "cached_server_url"
    private val KEY_CACHED_VPS_URL = "cached_vps_url"
    private val KEY_CACHED_SERVERLESS_URL = "cached_serverless_url"
    private val REMOTE_CONFIG_URL = "https://raw.githubusercontent.com/prashanthkandagatla8-ux/snapbeat/main/config.json"

    private fun getVpsUrl(): String {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val vps = prefs.getString(KEY_CACHED_VPS_URL, null)
        if (!vps.isNullOrBlank()) return vps
        val cached = prefs.getString(KEY_CACHED_SERVER_URL, null)
        return if (!cached.isNullOrBlank()) cached else BuildConfig.SERVER_URL
    }

    private fun getServerlessUrl(): String {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val serverless = prefs.getString(KEY_CACHED_SERVERLESS_URL, null)
        return if (!serverless.isNullOrBlank()) serverless else getVpsUrl()
    }

    private fun getServerUrl(): String = getVpsUrl()

    private fun fetchRemoteConfig() {
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val request = Request.Builder()
                    .url(REMOTE_CONFIG_URL)
                    .header("Cache-Control", "no-cache")
                    .build()
                client.newCall(request).execute().use { response ->
                    if (response.isSuccessful) {
                        val body = response.body?.string() ?: return@use
                        val json = JSONObject(body)
                        val vpsUrl = json.optString("vps_url", "").trim().trimEnd('/')
                        val serverlessUrl = json.optString("serverless_url", "").trim().trimEnd('/')
                        val remoteUrl = json.optString("server_url", "").trim().trimEnd('/')
                        val editor = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
                        if (vpsUrl.isNotEmpty()) editor.putString(KEY_CACHED_VPS_URL, vpsUrl)
                        if (serverlessUrl.isNotEmpty()) editor.putString(KEY_CACHED_SERVERLESS_URL, serverlessUrl)
                        if (remoteUrl.isNotEmpty()) editor.putString(KEY_CACHED_SERVER_URL, remoteUrl)
                        editor.apply()
                    }
                }
            } catch (e: Exception) {
                // Graceful fallback to cached or BuildConfig.SERVER_URL
            }
        }
    }

    private val templates = arrayOf(
        "Beat Cut",
        "Bounce",
        "Cine Zoom",
        "Fade",
        "Glide",
        "Pendulum",
        "Pulse",
        "Punch",
        "Reveal Boxes",
        "Slide",
        "Slow Drift",
        "Sway",
        "Whip",
        "Zoom Out"
    )
    private val aspectRatios = arrayOf("Portrait (9:16)", "Landscape (16:9)", "Square (1:1)")
    private val titleFonts = arrayOf("Bold Blockbuster (Impact)", "Elegant Serif (Georgia)", "Modern Minimal (Clean)", "Vintage Typewriter", "Casual Retro (Playful)")
    private val titleStyles = arrayOf("Classic Yellow Drop-Shadow", "Neon Glow (Electric Cyan)", "3D Retro Arcade Extrusion", "Cinematic All-Caps", "Badge Tag Container")
    private val titleFrames = arrayOf("None (Borderless)", "Cinematic Box Border", "Viewfinder Camera Corners", "Retro Double Border", "Film Letterbox Bars")

    // Single ItemTouchHelper instance — attached once, never duplicated
    private var itemTouchHelper: ItemTouchHelper? = null

    private lateinit var queueJobManager: QueueJobManager
    private lateinit var queueJobAdapter: QueueJobAdapter
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(5, TimeUnit.MINUTES)
        .writeTimeout(5, TimeUnit.MINUTES)
        .readTimeout(5, TimeUnit.MINUTES)
        .build()

    private val musicPicker = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        uri?.let {
            selectedMusicUri = it
            binding.tvMusicStatus.text = "1 tape selected"
            
            // Get audio duration and show trim slider
            try {
                val retriever = MediaMetadataRetriever()
                retriever.setDataSource(this@MainActivity, selectedMusicUri)
                val durationMs = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
                retriever.release()
                audioDurationSeconds = (durationMs / 1000).toInt()
                audioStartSeconds = 0
                audioEndSeconds = audioDurationSeconds
                isFullTrack = true

                if (audioDurationSeconds > 3) {
                    binding.audioTrimContainer.visibility = View.VISIBLE
                    binding.rbAudioFull.isChecked = true
                    binding.layoutTrimSliders.visibility = View.GONE

                    binding.seekAudioStart.max = audioDurationSeconds
                    binding.seekAudioStart.progress = 0

                    binding.seekAudioEnd.max = audioDurationSeconds
                    binding.seekAudioEnd.progress = audioDurationSeconds

                    updateAudioTrimLabels()
                }
            } catch (e: Exception) {
                // If metadata fails, skip trim UI
            }
        }
    }

    private val photosPicker = registerForActivityResult(ActivityResultContracts.GetMultipleContents()) { uris ->
        if (uris.isNotEmpty()) {
            selectedPhotos.clear()
            selectedPhotos.addAll(uris.take(60))
            val count = selectedPhotos.size
            binding.tvPhotosStatus.text = "$count photos loaded (Max 60)"
            refreshPhotoOrder()
            updatePhotoArrangementVisibility()
        }
    }

    private val notificationPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            startBackgroundRenderQueue()
        } else {
            Toast.makeText(this, "Notification permission needed for alerts", Toast.LENGTH_SHORT).show()
            startBackgroundRenderQueue()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        fetchRemoteConfig()

        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Theme toggle setup (Light / Dark mode)
        isDarkMode = prefs.getBoolean(KEY_DARK_MODE, true)
        applyTheme(isDarkMode)

        binding.layoutThemeToggle.setOnClickListener {
            isDarkMode = !isDarkMode
            prefs.edit().putBoolean(KEY_DARK_MODE, isDarkMode).apply()
            applyTheme(isDarkMode)
        }

        // 3-Mode Segmented Navigation Bar (AUTO, PRO, QUEUE)
        binding.tabNavAuto.setOnClickListener {
            switchNavPage(NavPage.AUTO)
        }
        binding.tabNavPro.setOnClickListener {
            switchNavPage(NavPage.PRO)
        }
        binding.tabNavQueue.setOnClickListener {
            switchNavPage(NavPage.QUEUE)
        }
        switchNavPage(NavPage.AUTO)

        val spinnerListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                updateLiveTitlePreview()
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
        binding.spinnerTitleFont.onItemSelectedListener = spinnerListener
        binding.spinnerTitleStyle.onItemSelectedListener = spinnerListener
        binding.spinnerTitleFrame.onItemSelectedListener = spinnerListener

        val previewWatcher = object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                updateLiveTitlePreview()
            }
            override fun afterTextChanged(s: Editable?) {}
        }
        binding.etTitleText.addTextChangedListener(previewWatcher)
        binding.etTitleBgColor.addTextChangedListener(previewWatcher)

        // Title card toggle (default off, controls hidden until switched on)
        binding.switchEnableTitleCard.setOnCheckedChangeListener { _, isChecked ->
            binding.layoutTitleCardControls.visibility = if (isChecked) View.VISIBLE else View.GONE
            if (isChecked) {
                updateLiveTitlePreview()
            }
        }

        // Custom aspect ratio toggle (default off, 9:16 portrait)
        binding.switchCustomAspectRatio.setOnCheckedChangeListener { _, isChecked ->
            binding.spinnerAspectRatio.visibility = if (isChecked) View.VISIBLE else View.GONE
            binding.tvAspectRatioDesc.text = if (isChecked) "Custom ratio active" else "Default: 9:16 Portrait (Reels/Shorts/TikTok)"
        }

        // Custom video quality toggle (default off, optimized fast ~5 MB)
        binding.switchCustomQuality.setOnCheckedChangeListener { _, isChecked ->
            binding.rgVideoQuality.visibility = if (isChecked) View.VISIBLE else View.GONE
            binding.tvQualityDesc.text = if (isChecked) "Custom quality selection active" else "Default: Optimized (Fast Download ~5 MB)"
            updateDynamicRenderCost()
        }

        binding.tvPrivacyPolicyLink.setOnClickListener {
            showFullPrivacyPolicyDialog()
        }

        // Google Play Mandated Prominent Disclosure for Media Processing
        if (!prefs.getBoolean(KEY_PRIVACY_ACCEPTED, false)) {
            showProminentPrivacyDisclosureDialog()
        }

        // Audio Trim controls
        binding.rgAudioLength.setOnCheckedChangeListener { _, checkedId ->
            if (checkedId == R.id.rbAudioFull) {
                isFullTrack = true
                binding.layoutTrimSliders.visibility = View.GONE
                updateDynamicRenderCost()
            } else {
                isFullTrack = false
                binding.layoutTrimSliders.visibility = View.VISIBLE
                updateAudioTrimLabels()
            }
        }

        binding.seekAudioStart.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) {
                    audioStartSeconds = progress
                    if (audioStartSeconds >= audioEndSeconds - 2) {
                        audioEndSeconds = minOf(audioDurationSeconds, audioStartSeconds + 3)
                        binding.seekAudioEnd.progress = audioEndSeconds
                    }
                    updateAudioTrimLabels()
                }
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        binding.seekAudioEnd.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) {
                    audioEndSeconds = progress
                    if (audioEndSeconds <= audioStartSeconds + 2) {
                        audioStartSeconds = maxOf(0, audioEndSeconds - 3)
                        binding.seekAudioStart.progress = audioStartSeconds
                    }
                    updateAudioTrimLabels()
                }
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        // Set up the RecyclerView + ItemTouchHelper ONCE in onCreate
        setupPhotoOrderRecyclerView()

        binding.rgArrangement.setOnCheckedChangeListener { _, _ ->
            updatePhotoArrangementVisibility()
        }

        binding.btnSelectMusic.setOnClickListener {
            musicPicker.launch("audio/*")
        }

        binding.btnSampleMusic.setOnClickListener {
            loadSampleMusicTrack()
        }

        binding.btnSelectPhotos.setOnClickListener {
            photosPicker.launch("image/*")
        }

        // Credit & Billing System
        creditManager = CreditManager(this)
        rewardedAdManager = RewardedAdManager(this)
        billingManager = BillingManager(this, creditManager) { _, msg ->
            updateCreditBalanceUI()
            updateWatermarkUI()
            Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
        }
        updateCreditBalanceUI()
        updateWatermarkUI()

        binding.layoutCreditMeter.setOnClickListener {
            showCreditStoreDialog(getRequiredCredits())
        }

        binding.rgVideoQuality.setOnCheckedChangeListener { _, _ ->
            updateDynamicRenderCost()
        }

        // Single Unified Action Button
        binding.btnUnifiedRender.setOnClickListener {
            if (selectedMusicUri == null || selectedPhotos.isEmpty()) {
                Toast.makeText(this, "Please pick actual music and photos first!", Toast.LENGTH_LONG).show()
                return@setOnClickListener
            }
            showRenderChoiceDialog()
        }

        // Initialize Queue History Ledger & Adapter
        queueJobManager = QueueJobManager(this)
        setupQueueRecyclerView()

        binding.btnQueueNewVideo.setOnClickListener {
            switchNavPage(NavPage.AUTO)
        }
        binding.btnQueueNewVideoEmpty.setOnClickListener {
            switchNavPage(NavPage.AUTO)
        }
        binding.btnClearQueue.setOnClickListener {
            showClearQueueConfirmationDialog()
        }

        setupQueueObserver()

        binding.btnRetry.setOnClickListener {
            binding.btnRetry.visibility = View.GONE
            uploadAndRender()
        }

        // Title background mode - show/hide color input
        binding.rgTitleBg.setOnCheckedChangeListener { _, checkedId ->
            binding.etTitleBgColor.visibility = if (checkedId == R.id.rbBgColor) View.VISIBLE else View.GONE
            updateLiveTitlePreview()
        }

        // Title duration slider
        binding.seekTitleDuration.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                binding.tvTitleDuration.text = "${progress}s"
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        updateLiveTitlePreview()
    }

    private fun getRequiredCredits(): Int {
        if (!::creditManager.isInitialized) return 1
        val duration = if (isFullTrack) {
            if (audioDurationSeconds > 0) audioDurationSeconds else 30
        } else {
            maxOf(1, audioEndSeconds - audioStartSeconds)
        }
        val isMaster = (currentNavPage == NavPage.PRO) && binding.switchCustomQuality.isChecked && binding.rbQualityMaster.isChecked
        return creditManager.calculateRequiredCredits(duration, isMaster)
    }

    private fun updateDynamicRenderCost() {
        if (!::creditManager.isInitialized) return
        val count = creditManager.getCredits()
        val label = if (count == 1) "CREDIT" else "CREDITS"
        binding.tvCreditBalance.text = "$count $label"
    }

    private fun updateWatermarkUI() {
        // Status handled in render dialog and queue
    }

    private fun updateCreditBalanceUI() {
        if (!::creditManager.isInitialized) return
        val count = creditManager.getCredits()
        val label = if (count == 1) "CREDIT" else "CREDITS"
        binding.tvCreditBalance.text = "$count $label"
    }

    private fun showCreditStoreDialog(requiredCredits: Int = 0) {
        val dialogView = layoutInflater.inflate(R.layout.dialog_credit_store, null)
        val dialog = androidx.appcompat.app.AlertDialog.Builder(this)
            .setView(dialogView)
            .create()

        val tvStoreBalance = dialogView.findViewById<android.widget.TextView>(R.id.tvStoreBalance)
        val tvRequiredNotice = dialogView.findViewById<android.widget.TextView>(R.id.tvRequiredNotice)
        val tvStoreRegion = dialogView.findViewById<android.widget.TextView>(R.id.tvStoreRegion)
        val btnChangeRegion = dialogView.findViewById<android.view.View>(R.id.btnChangeRegion)

        val btnSubMonthly = dialogView.findViewById<android.view.View>(R.id.btnSubMonthly)
        val tvPriceSubMonthly = dialogView.findViewById<android.widget.TextView>(R.id.tvPriceSubMonthly)
        val btnSubYearly = dialogView.findViewById<android.view.View>(R.id.btnSubYearly)
        val tvPriceSubYearly = dialogView.findViewById<android.widget.TextView>(R.id.tvPriceSubYearly)
        val tvSubYearlySavings = dialogView.findViewById<android.widget.TextView>(R.id.tvSubYearlySavings)

        val btnPackStarter = dialogView.findViewById<android.view.View>(R.id.btnPackStarter)
        val btnBuyStarter = dialogView.findViewById<androidx.appcompat.widget.AppCompatButton>(R.id.btnBuyStarter)
        val tvSubtitleStarter = dialogView.findViewById<android.widget.TextView>(R.id.tvSubtitleStarter)

        val btnPackParty = dialogView.findViewById<android.view.View>(R.id.btnPackParty)
        val btnBuyParty = dialogView.findViewById<androidx.appcompat.widget.AppCompatButton>(R.id.btnBuyParty)
        val tvSubtitleParty = dialogView.findViewById<android.widget.TextView>(R.id.tvSubtitleParty)

        val btnPackStudio = dialogView.findViewById<android.view.View>(R.id.btnPackStudio)
        val btnBuyStudio = dialogView.findViewById<androidx.appcompat.widget.AppCompatButton>(R.id.btnBuyStudio)
        val tvSubtitleStudio = dialogView.findViewById<android.widget.TextView>(R.id.tvSubtitleStudio)

        val btnPackDirector = dialogView.findViewById<android.view.View>(R.id.btnPackDirector)
        val btnBuyDirector = dialogView.findViewById<androidx.appcompat.widget.AppCompatButton>(R.id.btnBuyDirector)
        val tvSubtitleDirector = dialogView.findViewById<android.widget.TextView>(R.id.tvSubtitleDirector)

        val btnCloseStore = dialogView.findViewById<android.view.View>(R.id.btnCloseStore)

        val balance = creditManager.getCredits()
        tvStoreBalance.text = "Balance: $balance"

        if (requiredCredits > balance) {
            tvRequiredNotice.visibility = android.view.View.VISIBLE
            tvRequiredNotice.text = "⚠️ Instant render requires $requiredCredits credits. Your balance: $balance credits. Top up below or use the Free Queue!"
        } else {
            tvRequiredNotice.visibility = android.view.View.GONE
        }

        fun refreshStorePricesUI() {
            val activeRegion = RegionPricingManager.getActiveRegion(this)
            val pricing = RegionPricingManager.getPricing(activeRegion)

            tvStoreRegion?.text = "📍 Region: ${pricing.regionDisplayName} ▾"

            // Subscriptions: use Google Play price if returned, else regional fallback
            tvPriceSubMonthly?.text = billingManager.getFormattedPrice(BillingManager.SUBS_PRO_MONTHLY) ?: pricing.proMonthlyPrice
            tvPriceSubYearly?.text = billingManager.getFormattedPrice(BillingManager.SUBS_PRO_YEARLY) ?: pricing.proYearlyPrice
            tvSubYearlySavings?.text = pricing.proYearlySavings

            // Credit Packs:
            btnBuyStarter?.text = billingManager.getFormattedPrice(BillingManager.PRODUCT_STARTER_10) ?: pricing.starterPrice
            tvSubtitleStarter?.text = pricing.starterSubtitle

            btnBuyParty?.text = billingManager.getFormattedPrice(BillingManager.PRODUCT_PARTY_35) ?: pricing.partyPrice
            tvSubtitleParty?.text = pricing.partySubtitle

            btnBuyStudio?.text = billingManager.getFormattedPrice(BillingManager.PRODUCT_STUDIO_80) ?: pricing.studioPrice
            tvSubtitleStudio?.text = pricing.studioSubtitle

            btnBuyDirector?.text = billingManager.getFormattedPrice(BillingManager.PRODUCT_DIRECTOR_200) ?: pricing.directorPrice
            tvSubtitleDirector?.text = pricing.directorSubtitle
        }

        refreshStorePricesUI()

        // When Play Store products load, refresh prices in real time
        billingManager.onProductsQueried = {
            if (dialog.isShowing) {
                refreshStorePricesUI()
            }
        }
        dialog.setOnDismissListener {
            billingManager.onProductsQueried = null
        }

        btnChangeRegion?.setOnClickListener {
            val supported = RegionPricingManager.getSupportedRegions()
            val labels = supported.map { it.second }.toTypedArray()
            androidx.appcompat.app.AlertDialog.Builder(this)
                .setTitle("Select Currency & Region")
                .setItems(labels) { _, which ->
                    val (code, _) = supported[which]
                    if (code == "AUTO") {
                        RegionPricingManager.clearActiveRegionOverride(this)
                        val detected = RegionPricingManager.detectDeviceRegion(this)
                        Toast.makeText(this, "Auto-detected region: $detected", Toast.LENGTH_SHORT).show()
                    } else {
                        RegionPricingManager.setActiveRegion(this, code)
                    }
                    refreshStorePricesUI()
                }
                .show()
        }

        btnSubMonthly?.setOnClickListener {
            billingManager.launchPurchaseFlow(this, BillingManager.SUBS_PRO_MONTHLY)
            dialog.dismiss()
        }
        btnSubYearly?.setOnClickListener {
            billingManager.launchPurchaseFlow(this, BillingManager.SUBS_PRO_YEARLY)
            dialog.dismiss()
        }

        btnPackStarter.setOnClickListener {
            billingManager.launchPurchaseFlow(this, BillingManager.PRODUCT_STARTER_10)
            dialog.dismiss()
        }
        btnPackParty.setOnClickListener {
            billingManager.launchPurchaseFlow(this, BillingManager.PRODUCT_PARTY_35)
            dialog.dismiss()
        }
        btnPackStudio.setOnClickListener {
            billingManager.launchPurchaseFlow(this, BillingManager.PRODUCT_STUDIO_80)
            dialog.dismiss()
        }
        btnPackDirector.setOnClickListener {
            billingManager.launchPurchaseFlow(this, BillingManager.PRODUCT_DIRECTOR_200)
            dialog.dismiss()
        }
        btnCloseStore.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun showSponsorUnlockDialog(videoUriStr: String) {
        val dialogView = layoutInflater.inflate(R.layout.dialog_sponsor_unlock, null)
        val dialog = androidx.appcompat.app.AlertDialog.Builder(this)
            .setView(dialogView)
            .create()

        val tvTitle = dialogView.findViewById<android.widget.TextView>(R.id.tvSponsorTitle)
        val tvDesc = dialogView.findViewById<android.widget.TextView>(R.id.tvSponsorDesc)
        val btnWatch = dialogView.findViewById<androidx.appcompat.widget.AppCompatButton>(R.id.btnWatchSponsorAd)
        val btnCancel = dialogView.findViewById<androidx.appcompat.widget.AppCompatButton>(R.id.btnCancelUnlock)

        dialogView.setBackgroundColor(Color.parseColor("#1C1B19"))
        tvTitle?.setTextColor(Color.parseColor("#FFE14D"))
        tvDesc?.setTextColor(Color.parseColor("#FFFCF5"))
        btnWatch?.setBackgroundResource(R.drawable.btn_retro_yellow)
        btnWatch?.setTextColor(Color.parseColor("#1A1A1A"))
        btnCancel?.setTextColor(Color.parseColor("#888888"))

        btnWatch.setOnClickListener {
            btnWatch.isEnabled = false
            rewardedAdManager.showRewardedAd(
                activity = this,
                onUnlocked = {
                    btnWatch.isEnabled = true
                    unlockedVideoUris.add(videoUriStr)
                    dialog.dismiss()
                    Toast.makeText(this, "Video unlocked! Enjoy your SnapBeat 🎬", Toast.LENGTH_SHORT).show()
                    val intent = Intent(this, PreviewActivity::class.java).apply {
                        putExtra(PreviewActivity.EXTRA_VIDEO_URI, videoUriStr)
                    }
                    startActivity(intent)
                },
                onIncompleteOrFailed = { reason ->
                    btnWatch.isEnabled = true
                    Toast.makeText(this, reason, Toast.LENGTH_LONG).show()
                }
            )
        }

        btnCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun updateAudioTrimLabels() {
        binding.tvAudioStart.text = "Start Time: ${formatTime(audioStartSeconds)}"
        binding.tvAudioEnd.text = "End Time: ${formatTime(audioEndSeconds)}"
        val duration = maxOf(0, audioEndSeconds - audioStartSeconds)
        binding.tvAudioRange.text = "Start: ${formatTime(audioStartSeconds)}  |  End: ${formatTime(audioEndSeconds)}  (Duration: ${formatTime(duration)})"
        updateDynamicRenderCost()
    }

    private fun updateLiveTitlePreview() {
        val title = binding.etTitleText.text.toString().trim()
        binding.tvLiveTitle.text = if (title.isEmpty()) "TITLE CARD PREVIEW" else title

        // Font
        val fontPos = binding.spinnerTitleFont.selectedItemPosition
        binding.tvLiveTitle.typeface = when (fontPos) {
            1 -> android.graphics.Typeface.SERIF
            2 -> android.graphics.Typeface.SANS_SERIF
            3 -> android.graphics.Typeface.MONOSPACE
            else -> android.graphics.Typeface.DEFAULT_BOLD
        }

        // Style
        when (binding.spinnerTitleStyle.selectedItemPosition) {
            1 -> { // Neon
                binding.tvLiveTitle.setTextColor(android.graphics.Color.parseColor("#FFFFFF"))
                binding.tvLiveTitle.setShadowLayer(8f, 0f, 0f, android.graphics.Color.parseColor("#00F0FF"))
            }
            2 -> { // 3D Retro
                binding.tvLiveTitle.setTextColor(android.graphics.Color.parseColor("#FFE14D"))
                binding.tvLiveTitle.setShadowLayer(6f, 4f, 4f, android.graphics.Color.parseColor("#FF4D8D"))
            }
            3 -> { // Cinematic
                binding.tvLiveTitle.setTextColor(android.graphics.Color.parseColor("#F8F9FA"))
                binding.tvLiveTitle.letterSpacing = 0.15f
                binding.tvLiveTitle.setShadowLayer(4f, 2f, 2f, android.graphics.Color.parseColor("#000000"))
            }
            4 -> { // Badge
                binding.tvLiveTitle.setTextColor(android.graphics.Color.parseColor("#1A1A1A"))
                binding.tvLiveTitle.setBackgroundColor(android.graphics.Color.parseColor("#FFE14D"))
                binding.tvLiveTitle.setShadowLayer(0f, 0f, 0f, 0)
            }
            else -> { // Classic
                binding.tvLiveTitle.setTextColor(android.graphics.Color.parseColor("#FFE14D"))
                binding.tvLiveTitle.setBackgroundColor(android.graphics.Color.TRANSPARENT)
                binding.tvLiveTitle.letterSpacing = 0.05f
                binding.tvLiveTitle.setShadowLayer(4f, 2f, 2f, android.graphics.Color.parseColor("#000000"))
            }
        }

        // Background
        when (binding.rgTitleBg.checkedRadioButtonId) {
            R.id.rbBgBlack -> binding.cardTitlePreview.setBackgroundColor(android.graphics.Color.parseColor("#000000"))
            R.id.rbBgVideo -> binding.cardTitlePreview.setBackgroundColor(android.graphics.Color.parseColor("#222233"))
            R.id.rbBgColor -> {
                val hex = binding.etTitleBgColor.text.toString().trim()
                try {
                    if (hex.startsWith("#") && (hex.length == 7 || hex.length == 9)) {
                        binding.cardTitlePreview.setBackgroundColor(android.graphics.Color.parseColor(hex))
                    }
                } catch (_: Exception) {}
            }
        }
    }

    private fun formatTime(seconds: Int): String {
        val m = seconds / 60
        val s = seconds % 60
        return "$m:${s.toString().padStart(2, '0')}"
    }

    /**
     * Called ONCE in onCreate. Creates the adapter and attaches a single ItemTouchHelper.
     * When photos change, call refreshPhotoOrder() instead of re-creating everything.
     */
    private fun setupPhotoOrderRecyclerView() {
        photoOrderAdapter = PhotoOrderAdapter(selectedPhotos)
        binding.rvPhotoOrder.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        binding.rvPhotoOrder.adapter = photoOrderAdapter

        binding.rvPhotoOrder.setOnTouchListener { v, event ->
            v.parent?.requestDisallowInterceptTouchEvent(true)
            false
        }

        val callback = object : ItemTouchHelper.SimpleCallback(ItemTouchHelper.LEFT or ItemTouchHelper.RIGHT, 0) {
            override fun onMove(rv: RecyclerView, source: RecyclerView.ViewHolder, target: RecyclerView.ViewHolder): Boolean {
                val from = source.adapterPosition
                val to = target.adapterPosition
                if (from == RecyclerView.NO_POSITION || to == RecyclerView.NO_POSITION) return false
                photoOrderAdapter.moveItem(from, to)
                return true
            }
            override fun onSwiped(vh: RecyclerView.ViewHolder, dir: Int) {}
            override fun isLongPressDragEnabled() = true

            override fun onSelectedChanged(vh: RecyclerView.ViewHolder?, actionState: Int) {
                super.onSelectedChanged(vh, actionState)
                if (actionState == ItemTouchHelper.ACTION_STATE_DRAG) {
                    vh?.itemView?.animate()?.scaleX(1.05f)?.scaleY(1.05f)?.translationZ(8f)?.setDuration(150)?.start()
                }
            }
            override fun clearView(rv: RecyclerView, vh: RecyclerView.ViewHolder) {
                super.clearView(rv, vh)
                vh.itemView.animate().scaleX(1f).scaleY(1f).translationZ(0f).setDuration(150).start()
                // Refresh badges after drop
                photoOrderAdapter.notifyDataSetChanged()
            }
        }
        itemTouchHelper = ItemTouchHelper(callback)
        itemTouchHelper!!.attachToRecyclerView(binding.rvPhotoOrder)
    }

    /** Notify the existing adapter that the photo list changed — no re-creation needed. */
    private fun refreshPhotoOrder() {
        photoOrderAdapter.notifyDataSetChanged()
        binding.rvPhotoOrder.visibility = View.VISIBLE
    }

    private fun loadSampleMusicTrack() {
        try {
            val sampleFile = File(cacheDir, "sample_funk_smooth_party.mp3")
            if (!sampleFile.exists() || sampleFile.length() == 0L) {
                resources.openRawResource(R.raw.funk_smooth_party).use { input ->
                    FileOutputStream(sampleFile).use { output ->
                        input.copyTo(output)
                    }
                }
            }
            val uri = Uri.fromFile(sampleFile)
            selectedMusicUri = uri
            binding.tvMusicStatus.text = "🎵 Sample: Funk Smooth Party (Pixabay)"

            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(sampleFile.absolutePath)
            val durationMs = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
            retriever.release()
            audioDurationSeconds = (durationMs / 1000).toInt()
            audioStartSeconds = 0
            audioEndSeconds = audioDurationSeconds
            isFullTrack = true

            if (audioDurationSeconds > 3) {
                binding.audioTrimContainer.visibility = View.VISIBLE
                binding.rbAudioFull.isChecked = true
                binding.layoutTrimSliders.visibility = View.GONE

                binding.seekAudioStart.max = audioDurationSeconds
                binding.seekAudioStart.progress = 0

                binding.seekAudioEnd.max = audioDurationSeconds
                binding.seekAudioEnd.progress = audioDurationSeconds

                updateAudioTrimLabels()
            }
            Toast.makeText(this, "Loaded Funk Smooth Party sample track! 🎶", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(this, "Could not load sample track: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun getFileFromUri(uri: Uri, prefix: String): File? {
        return try {
            if (uri.scheme == "file" && uri.path != null) {
                val f = File(uri.path!!)
                if (f.exists() && f.length() > 0) return f
            }
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val ext = if (prefix.startsWith("music")) ".mp3" else ".jpg"
            val file = File(cacheDir, "${prefix}_${System.currentTimeMillis()}${ext}")
            // Fix: use .use{} to guarantee streams close even on exception
            inputStream.use { input ->
                FileOutputStream(file).use { output ->
                    input.copyTo(output)
                }
            }
            file
        } catch (e: Exception) {
            null
        }
    }

    private fun clearCache() {
        cacheDir.listFiles()?.forEach { file ->
            if ((file.name.startsWith("music_") || file.name.startsWith("photo_")) && !file.name.startsWith("sample_")) {
                file.delete()
            }
        }
    }

    private fun uploadAndRender() {
        binding.btnRetry.visibility = View.GONE
        binding.progressBar.visibility = View.VISIBLE
        binding.progressBar.isIndeterminate = true
        binding.tvStatus.text = "Uploading to SnapBeat Lab..."
        binding.btnUnifiedRender.isEnabled = false

        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val requiredCredits = getRequiredCredits()
                creditManager.deductCredits(requiredCredits)
                withContext(Dispatchers.Main) {
                    updateCreditBalanceUI()
                }

                val builder = MultipartBody.Builder().setType(MultipartBody.FORM)
                builder.addFormDataPart("device_id", creditManager.getDeviceId())
                builder.addFormDataPart("credits_used", requiredCredits.toString())
                builder.addFormDataPart("watermark", "false")
                builder.addFormDataPart("render_type", "instant")

                val musicUri = selectedMusicUri
                    ?: throw IOException("No music selected")
                val musicFile = getFileFromUri(musicUri, "music") 
                    ?: throw IOException("Could not read music file")
                builder.addFormDataPart("audio", musicFile.name, musicFile.asRequestBody("audio/*".toMediaTypeOrNull()))

                val photosToUpload = if (::photoOrderAdapter.isInitialized) {
                    photoOrderAdapter.getOrderedPhotos()
                } else {
                    selectedPhotos
                }

                photosToUpload.forEachIndexed { index, uri ->
                    val photoFile = getFileFromUri(uri, "photo_$index") 
                        ?: throw IOException("Could not read photo $index")
                    builder.addFormDataPart("photos", photoFile.name, photoFile.asRequestBody("image/*".toMediaTypeOrNull()))
                }

                val isPro = (currentNavPage == NavPage.PRO)
                if (isPro) {
                    val selection = binding.spinnerTemplate.selectedItem?.toString() ?: "Beat Cut"
                    val templateName = when(selection) {
                        "Beat Cut" -> "beat-cut"
                        "Bounce" -> "beat-bounce"
                        "Cine Zoom" -> "cinematic-zoom"
                        "Fade" -> "beat-fade"
                        "Glide" -> "glide-pan"
                        "Pendulum" -> "pendulum"
                        "Pulse" -> "beat-pulse"
                        "Punch" -> "punch-cut"
                        "Reveal Boxes" -> "reveal-tiles"
                        "Slide" -> "beat-slide"
                        "Slow Drift" -> "slow-drift"
                        "Sway" -> "sway-ballad"
                        "Whip" -> "beat-whip"
                        "Zoom Out" -> "zoom-out-reveal"
                        else -> "beat-cut"
                    }
                    builder.addFormDataPart("template", templateName)

                    // Send drop_it flag if enabled
                    if (binding.switchDropIt.isChecked) {
                        builder.addFormDataPart("drop_it", "true")
                    }

                    // Send aspect ratio if custom toggle is enabled
                    val frameValue = if (binding.switchCustomAspectRatio.isChecked) {
                        when(binding.spinnerAspectRatio.selectedItemPosition) {
                            0 -> "portrait"
                            1 -> "landscape"
                            2 -> "square"
                            else -> "portrait"
                        }
                    } else {
                        "portrait"
                    }
                    builder.addFormDataPart("frame", frameValue)

                    // Send title only if switch is enabled and text is provided
                    val titleText = binding.etTitleText.text.toString().trim()
                    if (binding.switchEnableTitleCard.isChecked && titleText.isNotEmpty()) {
                        builder.addFormDataPart("title_text", titleText)
                        // Background mode
                        val titleBg = when (binding.rgTitleBg.checkedRadioButtonId) {
                            R.id.rbBgBlack -> "black"
                            R.id.rbBgColor -> binding.etTitleBgColor.text.toString().trim().ifEmpty { "#000000" }
                            R.id.rbBgVideo -> "video"
                            else -> "black"
                        }
                        builder.addFormDataPart("title_bg", titleBg)
                        // Duration
                        val titleDuration = binding.seekTitleDuration.progress.coerceIn(1, 5)
                        builder.addFormDataPart("title_duration", titleDuration.toString())

                        // Title font
                        val fontVal = when (binding.spinnerTitleFont.selectedItemPosition) {
                            0 -> "impact"
                            1 -> "serif"
                            2 -> "clean"
                            3 -> "typewriter"
                            4 -> "playful"
                            else -> "impact"
                        }
                        builder.addFormDataPart("title_font", fontVal)

                        // Title style
                        val styleVal = when (binding.spinnerTitleStyle.selectedItemPosition) {
                            0 -> "classic"
                            1 -> "neon"
                            2 -> "3d_retro"
                            3 -> "cinematic"
                            4 -> "badge"
                            else -> "classic"
                        }
                        builder.addFormDataPart("title_style", styleVal)

                        // Title frame
                        val frameVal = when (binding.spinnerTitleFrame.selectedItemPosition) {
                            0 -> "none"
                            1 -> "box"
                            2 -> "viewfinder"
                            3 -> "double_line"
                            4 -> "film_bars"
                            else -> "none"
                        }
                        builder.addFormDataPart("title_frame", frameVal)
                    }

                    // Video quality selection in Pro mode
                    val qualityVal = if (binding.switchCustomQuality.isChecked && binding.rbQualityMaster.isChecked) "master" else "fast"
                    builder.addFormDataPart("quality", qualityVal)
                } else {
                    builder.addFormDataPart("quality", "fast")
                }

                // Photo arrangement: auto (Gemini / smart) vs manual
                val autoArrange = if (binding.rbArrangeAuto.isChecked) "auto" else "manual"
                builder.addFormDataPart("auto_arrange", autoArrange)

                // Send audio duration and trimming (works in both basic and pro modes)
                if (isFullTrack) {
                    builder.addFormDataPart("full_track", "true")
                    builder.addFormDataPart("audio_start", "0")
                    builder.addFormDataPart("audio_end", "0")
                } else {
                    builder.addFormDataPart("full_track", "false")
                    builder.addFormDataPart("audio_start", audioStartSeconds.toString())
                    builder.addFormDataPart("audio_end", audioEndSeconds.toString())
                }

                val serverlessUrl = getServerlessUrl()
                val requestBody = builder.build()
                val request = Request.Builder()
                    .url("$serverlessUrl/api/render/mobile") 
                    .post(requestBody)
                    .build()

                withContext(Dispatchers.Main) { 
                    binding.tvStatus.text = "Uploading..." 
                }

                var jobId: String = ""
                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) throw IOException("Upload failed: ${response.code}")
                    val bodyString = response.body?.string() ?: "{}"
                    val json = JSONObject(bodyString)
                    if (!json.has("job_id")) throw IOException("Server error: $bodyString")
                    jobId = json.get("job_id").toString()
                }
                
                clearCache()
                pollStatusAndDownload(jobId, serverlessUrl)

            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    binding.progressBar.visibility = View.GONE
                    binding.tvStatus.text = "Error: ${e.message}"
                    binding.btnUnifiedRender.isEnabled = true
                    binding.btnRetry.visibility = View.VISIBLE
                }
                clearCache()
            }
        }
    }

    private suspend fun pollStatusAndDownload(jobId: String, serverUrl: String = getServerlessUrl()) {
        withContext(Dispatchers.Main) {
            binding.progressBar.isIndeterminate = false
            binding.progressBar.progress = 0
        }

        var isDone = false
        var pollCount = 0
        val maxPolls = 600

        while (!isDone && pollCount < maxPolls) {
            kotlinx.coroutines.delay(1500)
            pollCount++

            try {
                val statusRequest = Request.Builder()
                    .url("$serverUrl/api/render/status/$jobId")
                    .get()
                    .build()

                client.newCall(statusRequest).execute().use { response ->
                    if (!response.isSuccessful) return@use
                    val bodyString = response.body?.string() ?: "{}"
                    val json = JSONObject(bodyString)
                    val status = json.optString("status", "")
                    val stage = json.optString("stage", "processing")
                    val progress = json.optInt("progress", 0)

                    withContext(Dispatchers.Main) {
                        binding.tvStatus.text = "${stage.uppercase()} - $progress%"
                        binding.progressBar.progress = progress
                    }

                    if (status == "done") {
                        isDone = true
                    } else if (status == "failed" || status == "cancelled") {
                        val errorMsg = json.optString("error", "Unknown error")
                        throw RuntimeException("Render failed: $errorMsg")
                    }
                }
            } catch (e: RuntimeException) {
                throw e
            } catch (e: IOException) {
                if (pollCount % 3 != 0) continue else throw e
            }
        }

        if (pollCount >= maxPolls) throw IOException("Render timed out")

        withContext(Dispatchers.Main) {
            binding.progressBar.isIndeterminate = false
            binding.progressBar.progress = 0
            binding.tvStatus.text = "DOWNLOADING: 0%..."
        }

        val downloadRequest = Request.Builder()
            .url("$serverUrl/api/render/download/$jobId?delete_after=true")
            .get()
            .build()

        client.newCall(downloadRequest).execute().use { response ->
            if (!response.isSuccessful) throw IOException("Download failed")
            val body = response.body ?: throw IOException("Empty response")
            val totalBytes = body.contentLength()
            val inputStream = body.byteStream()
            
            val values = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, "SnapBeat_${jobId}.mp4")
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/SnapBeat")
                    put(MediaStore.Video.Media.IS_PENDING, 1)
                }
            }
            
            val uri = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Failed to create MediaStore entry")

            var downloadSuccess = false
            try {
                contentResolver.openOutputStream(uri)?.use { out ->
                    val buffer = ByteArray(8192)
                    var bytesRead: Int
                    var downloadedBytes = 0L
                    var lastReportedPct = -1
                    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                        out.write(buffer, 0, bytesRead)
                        downloadedBytes += bytesRead
                        if (totalBytes > 0) {
                            val pct = ((downloadedBytes * 100) / totalBytes).toInt().coerceIn(0, 100)
                            if (pct != lastReportedPct) {
                                lastReportedPct = pct
                                val currentMB = downloadedBytes / (1024.0 * 1024.0)
                                val totalMB = totalBytes / (1024.0 * 1024.0)
                                withContext(Dispatchers.Main) {
                                    binding.progressBar.isIndeterminate = false
                                    binding.progressBar.progress = pct
                                    binding.tvStatus.text = String.format("DOWNLOADING: %d%% (%.1f MB / %.1f MB)", pct, currentMB, totalMB)
                                }
                            }
                        }
                    }
                }
                downloadSuccess = true
            } finally {
                if (!downloadSuccess) {
                    contentResolver.delete(uri, null, null)
                }
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                values.clear()
                values.put(MediaStore.Video.Media.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
            }
            
            withContext(Dispatchers.Main) {
                binding.progressBar.visibility = View.GONE
                binding.tvStatus.text = "Done! Video saved \uD83C\uDFAC"
                binding.btnUnifiedRender.isEnabled = true
                lastVideoUri = uri

                // Record instant render job in Queue history ledger
                val title = if (currentNavPage == NavPage.PRO && binding.switchEnableTitleCard.isChecked) {
                    binding.etTitleText.text.toString().trim().ifEmpty { "Instant Render" }
                } else "Instant Render"
                val template = if (currentNavPage == NavPage.PRO) {
                    binding.spinnerTemplate.selectedItem?.toString() ?: "Beat Cut"
                } else "Beat Cut"
                val aspect = if (currentNavPage == NavPage.PRO && binding.switchCustomAspectRatio.isChecked) {
                    when (binding.spinnerAspectRatio.selectedItemPosition) {
                        0 -> "9:16"
                        1 -> "16:9"
                        2 -> "1:1"
                        else -> "9:16"
                    }
                } else "9:16"
                val quality = if (currentNavPage == NavPage.PRO && binding.switchCustomQuality.isChecked && binding.rbQualityMaster.isChecked) "master" else "fast"

                val instantJob = QueueJob(
                    id = "instant_$jobId",
                    title = title,
                    videoUri = uri.toString(),
                    timestamp = System.currentTimeMillis(),
                    templateName = template,
                    quality = quality,
                    aspectRatio = aspect,
                    status = "COMPLETED",
                    isFavourite = false,
                    isInstant = true
                )
                queueJobManager.addOrUpdateJob(instantJob)
                refreshQueueLedgerUI()

                // Launch dedicated Preview screen
                val intent = Intent(this@MainActivity, PreviewActivity::class.java).apply {
                    putExtra(PreviewActivity.EXTRA_VIDEO_URI, uri.toString())
                }
                startActivity(intent)
            }
        }
    }

    private fun queueBackgroundRender() {
        if (selectedMusicUri == null || selectedPhotos.isEmpty()) {
            Toast.makeText(this, "Please pick actual music and photos first!", Toast.LENGTH_LONG).show()
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                notificationPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                return
            }
        }

        startBackgroundRenderQueue()
    }

    private fun startBackgroundRenderQueue() {
        binding.cardQueueTray.visibility = View.VISIBLE
        binding.queueProgressBar.visibility = View.VISIBLE
        binding.queueProgressBar.isIndeterminate = true
        binding.tvQueueBadge.text = "QUEUED"
        binding.tvQueueBadge.setTextColor(Color.parseColor("#FFE14D"))
        binding.tvQueueStatus.text = "Preparing bundle for background worker..."
        binding.btnViewQueueVideo.visibility = View.GONE

        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val timestamp = System.currentTimeMillis()
                val jobDir = File(cacheDir, "queue_jobs/job_$timestamp")
                jobDir.mkdirs()

                // Copy music
                val musicUri = selectedMusicUri ?: throw IOException("No music selected")
                val musicDst = File(jobDir, "music_${timestamp}.mp3")
                contentResolver.openInputStream(musicUri)?.use { input ->
                    FileOutputStream(musicDst).use { output ->
                        input.copyTo(output)
                    }
                } ?: throw IOException("Failed to copy music to queue bundle")

                // Copy photos in current order
                val photosToQueue = if (::photoOrderAdapter.isInitialized) {
                    photoOrderAdapter.getOrderedPhotos()
                } else {
                    selectedPhotos
                }

                photosToQueue.forEachIndexed { index, uri ->
                    val photoDst = File(jobDir, "photo_${index}.jpg")
                    contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(photoDst).use { output ->
                            input.copyTo(output)
                        }
                    } ?: throw IOException("Failed to copy photo $index to queue bundle")
                }

                // Determine options
                val isPro = (currentNavPage == NavPage.PRO)
                val quality = if (isPro && binding.switchCustomQuality.isChecked && binding.rbQualityMaster.isChecked) "master" else "fast"

                val templateName = if (isPro) {
                    val selection = binding.spinnerTemplate.selectedItem?.toString() ?: "Beat Cut"
                    when (selection) {
                        "Beat Cut" -> "beat-cut"
                        "Bounce" -> "beat-bounce"
                        "Cine Zoom" -> "cinematic-zoom"
                        "Fade" -> "beat-fade"
                        "Glide" -> "glide-pan"
                        "Pendulum" -> "pendulum"
                        "Pulse" -> "beat-pulse"
                        "Punch" -> "punch-cut"
                        "Reveal Boxes" -> "reveal-tiles"
                        "Slide" -> "beat-slide"
                        "Slow Drift" -> "slow-drift"
                        "Sway" -> "sway-ballad"
                        "Whip" -> "beat-whip"
                        "Zoom Out" -> "zoom-out-reveal"
                        else -> "beat-cut"
                    }
                } else {
                    "beat-cut"
                }

                val frameValue = if (isPro && binding.switchCustomAspectRatio.isChecked) {
                    when (binding.spinnerAspectRatio.selectedItemPosition) {
                        0 -> "portrait"
                        1 -> "landscape"
                        2 -> "square"
                        else -> "portrait"
                    }
                } else {
                    "portrait"
                }

                val titleText = if (isPro && binding.switchEnableTitleCard.isChecked) binding.etTitleText.text.toString().trim() else ""
                val titleBg = if (isPro) {
                    when (binding.rgTitleBg.checkedRadioButtonId) {
                        R.id.rbBgBlack -> "black"
                        R.id.rbBgColor -> binding.etTitleBgColor.text.toString().trim().ifEmpty { "#000000" }
                        R.id.rbBgVideo -> "video"
                        else -> "black"
                    }
                } else "black"

                val titleDuration = if (isPro) binding.seekTitleDuration.progress.coerceIn(1, 5).toString() else "2"
                val titleFont = if (isPro) {
                    when (binding.spinnerTitleFont.selectedItemPosition) {
                        0 -> "impact"
                        1 -> "serif"
                        2 -> "clean"
                        3 -> "typewriter"
                        4 -> "playful"
                        else -> "impact"
                    }
                } else "impact"

                val titleStyle = if (isPro) {
                    when (binding.spinnerTitleStyle.selectedItemPosition) {
                        0 -> "classic"
                        1 -> "neon"
                        2 -> "3d_retro"
                        3 -> "cinematic"
                        4 -> "badge"
                        else -> "classic"
                    }
                } else "classic"

                val titleFrame = if (isPro) {
                    when (binding.spinnerTitleFrame.selectedItemPosition) {
                        0 -> "none"
                        1 -> "box"
                        2 -> "viewfinder"
                        3 -> "double_line"
                        4 -> "film_bars"
                        else -> "none"
                    }
                } else "none"

                val autoArrange = if (binding.rbArrangeAuto.isChecked) "auto" else "manual"

                val isWatermark = creditManager.shouldWatermark(isInstant = false)

                val data = Data.Builder()
                    .putString(RenderQueueWorker.KEY_DEVICE_ID, creditManager.getDeviceId())
                    .putInt(RenderQueueWorker.KEY_CREDITS_USED, 0)
                    .putBoolean(RenderQueueWorker.KEY_WATERMARK, isWatermark)
                    .putString(RenderQueueWorker.KEY_RENDER_TYPE, "free_queue")
                    .putString(RenderQueueWorker.KEY_JOB_DIR, jobDir.absolutePath)
                    .putString(RenderQueueWorker.KEY_AUTO_ARRANGE, autoArrange)
                    .putString(RenderQueueWorker.KEY_SERVER_URL, getVpsUrl())
                    .putString(RenderQueueWorker.KEY_QUALITY, quality)
                    .putString(RenderQueueWorker.KEY_TEMPLATE, templateName)
                    .putBoolean(RenderQueueWorker.KEY_DROP_IT, isPro && binding.switchDropIt.isChecked)
                    .putString(RenderQueueWorker.KEY_FRAME, frameValue)
                    .putString(RenderQueueWorker.KEY_TITLE_TEXT, titleText)
                    .putString(RenderQueueWorker.KEY_TITLE_BG, titleBg)
                    .putString(RenderQueueWorker.KEY_TITLE_DURATION, titleDuration)
                    .putString(RenderQueueWorker.KEY_TITLE_FONT, titleFont)
                    .putString(RenderQueueWorker.KEY_TITLE_STYLE, titleStyle)
                    .putString(RenderQueueWorker.KEY_TITLE_FRAME, titleFrame)
                    .putBoolean(RenderQueueWorker.KEY_FULL_TRACK, isFullTrack)
                    .putInt(RenderQueueWorker.KEY_AUDIO_START, audioStartSeconds)
                    .putInt(RenderQueueWorker.KEY_AUDIO_END, audioEndSeconds)
                    .build()

                val workRequest = OneTimeWorkRequestBuilder<RenderQueueWorker>()
                    .addTag(RenderQueueWorker.TAG)
                    .setInputData(data)
                    .build()

                WorkManager.getInstance(applicationContext).enqueueUniqueWork(
                    "snapbeat_active_render",
                    ExistingWorkPolicy.REPLACE,
                    workRequest
                )

                // Record initial queued job in history ledger
                val queuedJob = QueueJob(
                    id = "queue_$timestamp",
                    title = if (titleText.isNotEmpty()) titleText else "Queue Render",
                    videoUri = null,
                    timestamp = timestamp,
                    templateName = templateName,
                    quality = quality,
                    aspectRatio = frameValue,
                    status = "PROCESSING",
                    isFavourite = false,
                    isInstant = false
                )
                queueJobManager.addOrUpdateJob(queuedJob)

                withContext(Dispatchers.Main) {
                    refreshQueueLedgerUI()
                    Toast.makeText(
                        this@MainActivity,
                        "🎬 Added to render queue! You can safely close or minimize the app.",
                        Toast.LENGTH_LONG
                    ).show()
                }

            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    binding.tvQueueBadge.text = "ERROR"
                    binding.tvQueueBadge.setTextColor(Color.parseColor("#FF4D8D"))
                    binding.tvQueueStatus.text = "Failed to queue job: ${e.message}"
                }
            }
        }
    }

    private fun setupQueueObserver() {
        WorkManager.getInstance(applicationContext)
            .getWorkInfosByTagLiveData(RenderQueueWorker.TAG)
            .observe(this) { workInfoList ->
                if (workInfoList.isNullOrEmpty()) return@observe
                val info = workInfoList.maxByOrNull { it.generation } ?: workInfoList.last()
                when (info.state) {
                    WorkInfo.State.ENQUEUED -> {
                        binding.cardQueueTray.visibility = View.VISIBLE
                        binding.queueProgressBar.visibility = View.VISIBLE
                        binding.queueProgressBar.isIndeterminate = true
                        binding.tvQueueBadge.text = "QUEUED"
                        binding.tvQueueBadge.setTextColor(Color.parseColor("#FFE14D"))
                        binding.tvQueueStatus.text = "Waiting to run in background • Safe to close app"
                        binding.layoutQueueResultCard.visibility = View.GONE
                        binding.btnViewQueueVideo.visibility = View.GONE
                    }
                    WorkInfo.State.RUNNING -> {
                        binding.cardQueueTray.visibility = View.VISIBLE
                        binding.queueProgressBar.visibility = View.VISIBLE
                        binding.tvQueueBadge.text = "RUNNING"
                        binding.tvQueueBadge.setTextColor(Color.parseColor("#FFE14D"))
                        val stage = info.progress.getString("stage") ?: "Processing in background..."
                        val progress = info.progress.getInt("progress", 0)
                        binding.queueProgressBar.isIndeterminate = (progress <= 0)
                        binding.queueProgressBar.progress = progress
                        binding.tvQueueStatus.text = "$stage • Safe to close app"
                        binding.layoutQueueResultCard.visibility = View.GONE
                        binding.btnViewQueueVideo.visibility = View.GONE
                    }
                    WorkInfo.State.SUCCEEDED -> {
                        binding.cardQueueTray.visibility = View.VISIBLE
                        binding.queueProgressBar.visibility = View.GONE
                        binding.tvQueueBadge.text = "COMPLETE ✓"
                        binding.tvQueueBadge.setTextColor(Color.parseColor("#3DD4FF"))
                        binding.tvQueueStatus.text = "Video rendered & ready! 🎬"
                        val videoUriStr = info.outputData.getString(RenderQueueWorker.OUTPUT_VIDEO_URI)
                        if (!videoUriStr.isNullOrEmpty()) {
                            // Update Queue Ledger with completed job
                            val jobs = queueJobManager.getJobs()
                            val activeJob = jobs.find { it.status == "PROCESSING" && !it.isInstant }
                            if (activeJob != null) {
                                activeJob.status = "COMPLETED"
                                activeJob.videoUri = videoUriStr
                                queueJobManager.addOrUpdateJob(activeJob)
                            } else {
                                val newJob = QueueJob(
                                    id = "queue_${System.currentTimeMillis()}",
                                    title = "Queue Render",
                                    videoUri = videoUriStr,
                                    timestamp = System.currentTimeMillis(),
                                    status = "COMPLETED",
                                    isInstant = false
                                )
                                queueJobManager.addOrUpdateJob(newJob)
                            }
                            refreshQueueLedgerUI()

                            binding.layoutQueueResultCard.visibility = View.VISIBLE
                            binding.btnViewQueueVideo.visibility = View.VISIBLE
                            binding.btnViewQueueVideo.setOnClickListener {
                                if (unlockedVideoUris.contains(videoUriStr) || creditManager.isProSubscriber()) {
                                    val intent = Intent(this@MainActivity, PreviewActivity::class.java).apply {
                                        putExtra(PreviewActivity.EXTRA_VIDEO_URI, videoUriStr)
                                    }
                                    startActivity(intent)
                                } else {
                                    binding.btnViewQueueVideo.isEnabled = false
                                    Toast.makeText(this@MainActivity, "Loading sponsor message to unlock video...", Toast.LENGTH_SHORT).show()
                                    rewardedAdManager.showRewardedAd(
                                        activity = this@MainActivity,
                                        onUnlocked = {
                                            binding.btnViewQueueVideo.isEnabled = true
                                            unlockedVideoUris.add(videoUriStr)
                                            val intent = Intent(this@MainActivity, PreviewActivity::class.java).apply {
                                                putExtra(PreviewActivity.EXTRA_VIDEO_URI, videoUriStr)
                                            }
                                            startActivity(intent)
                                        },
                                        onIncompleteOrFailed = { reason ->
                                            binding.btnViewQueueVideo.isEnabled = true
                                            Toast.makeText(this@MainActivity, reason, Toast.LENGTH_LONG).show()
                                        }
                                    )
                                }
                            }
                        }
                    }
                    WorkInfo.State.FAILED -> {
                        binding.cardQueueTray.visibility = View.VISIBLE
                        binding.queueProgressBar.visibility = View.GONE
                        binding.tvQueueBadge.text = "FAILED ⚠️"
                        binding.tvQueueBadge.setTextColor(Color.parseColor("#FF4D8D"))
                        val error = info.outputData.getString("error") ?: "Background render failed"
                        binding.tvQueueStatus.text = error
                        binding.layoutQueueResultCard.visibility = View.GONE
                        binding.btnViewQueueVideo.visibility = View.GONE

                        val jobs = queueJobManager.getJobs()
                        val activeJob = jobs.find { it.status == "PROCESSING" && !it.isInstant }
                        if (activeJob != null) {
                            activeJob.status = "FAILED"
                            queueJobManager.addOrUpdateJob(activeJob)
                            refreshQueueLedgerUI()
                        }
                    }
                    WorkInfo.State.CANCELLED -> {
                        binding.cardQueueTray.visibility = View.GONE
                        binding.layoutQueueResultCard.visibility = View.GONE
                    }
                    else -> {}
                }
            }
    }

    private fun updatePhotoArrangementVisibility() {
        if (binding.rbArrangeManual.isChecked) {
            binding.rvPhotoOrder.visibility = if (selectedPhotos.isNotEmpty()) View.VISIBLE else View.GONE
        } else {
            binding.rvPhotoOrder.visibility = View.GONE
        }
    }

    private fun showProminentPrivacyDisclosureDialog() {
        val builder = androidx.appcompat.app.AlertDialog.Builder(this)
        builder.setTitle("🔒 Privacy & Media Processing Notice")
        builder.setMessage(
            "Welcome to SnapBeat!\n\n" +
            "To generate beat-synced music videos, SnapBeat processes only the specific photos and audio track that you select.\n\n" +
            "• Secure Processing: Your selected files are uploaded securely to our rendering engine solely for video creation and beat synchronization.\n\n" +
            "• Zero Permanent Storage: Uploaded files are processed ephemerally and automatically deleted immediately after your video is downloaded to your device.\n\n" +
            "• No Data Sharing: We never sell, store, or share your personal media with third parties or advertisers.\n\n" +
            "By continuing, you agree to our data handling practices."
        )
        builder.setCancelable(false)
        builder.setPositiveButton("Agree & Continue") { dialog, _ ->
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_PRIVACY_ACCEPTED, true)
                .apply()
            dialog.dismiss()
        }
        builder.setNeutralButton("View Full Policy") { _, _ ->
            showFullPrivacyPolicyDialog()
        }
        builder.show()
    }

    private fun showFullPrivacyPolicyDialog() {
        val policyText =
            "SNAPBEAT PRIVACY POLICY\n" +
            "Effective Date: September 8, 2026\n\n" +
            "1. MEDIA DATA PROCESSING\n" +
            "SnapBeat processes only the photos and audio file you choose to include in your video. The app does not access your private photo library or files not explicitly selected.\n\n" +
            "2. EPHEMERAL PROCESSING & AUTOMATIC DELETION\n" +
            "Selected media is securely transmitted to our rendering backend via TLS/HTTPS encryption. Upon completion and download of your video to your device gallery, all uploaded source files and temporary rendering assets are immediately and permanently deleted.\n\n" +
            "3. AI SMART ARRANGEMENT\n" +
            "When using AI Smart Arrangement, visual attributes (such as color vibrance, edge sharpness, and tempo alignment) are analyzed strictly to order photos for the video climax. Your photos are never used to train public AI models.\n\n" +
            "4. MINIMAL PERMISSIONS\n" +
            "• Internet: To communicate with the rendering server.\n" +
            "• Notifications: To alert you when your background render is finished.\n" +
            "• Foreground Service: To ensure background rendering is not killed by the OS.\n\n" +
            "5. NO DATA SELLING OR TRACKING\n" +
            "We do not sell, monetize, or share your data with third parties.\n\n" +
            "Contact Developer: snapbeat.app@gmail.com"

        val builder = androidx.appcompat.app.AlertDialog.Builder(this)
        builder.setTitle("SnapBeat Privacy Policy")
        builder.setMessage(policyText)
        builder.setPositiveButton("Close", null)
        builder.setNeutralButton("Open in Browser") { _, _ ->
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_POLICY_URL))
                startActivity(intent)
            } catch (_: Exception) {
                Toast.makeText(this, "Could not open browser", Toast.LENGTH_SHORT).show()
            }
        }
        builder.show()
    }

    private fun showRenderChoiceDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_render_choice, null)
        val dialog = androidx.appcompat.app.AlertDialog.Builder(this)
            .setView(dialogView)
            .create()

        val btnInstant = dialogView.findViewById<android.widget.Button>(R.id.btnChooseInstant)
        val btnQueue = dialogView.findViewById<android.widget.Button>(R.id.btnChooseQueue)
        val btnRemoveWatermark = dialogView.findViewById<android.widget.Button>(R.id.btnRemoveWatermark)
        val btnCancel = dialogView.findViewById<android.widget.Button>(R.id.btnCancelChoice)

        val required = getRequiredCredits()
        val creditText = if (required == 1) "1 CREDIT" else "$required CREDITS"
        btnInstant.text = "⚡ RENDER INSTANT ($creditText)"

        btnInstant.setOnClickListener {
            dialog.dismiss()
            if (creditManager.getCredits() < required) {
                showCreditStoreDialog(required)
            } else {
                uploadAndRender()
            }
        }

        btnQueue.setOnClickListener {
            dialog.dismiss()
            queueBackgroundRender()
            switchNavPage(NavPage.QUEUE)
        }

        btnRemoveWatermark?.setOnClickListener {
            dialog.dismiss()
            showCreditStoreDialog(required)
        }

        btnCancel.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun applyTheme(darkMode: Boolean) {
        if (darkMode) {
            binding.tvThemeIcon.text = "🌙"
            binding.tvThemeLabel.text = "DARK"
            binding.tvThemeLabel.setTextColor(Color.parseColor("#FFFCF5"))
            binding.rootScrollView.setBackgroundColor(Color.parseColor("#1A1A1A"))
            window.statusBarColor = Color.parseColor("#1A1A1A")
            window.navigationBarColor = Color.parseColor("#1A1A1A")
            WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = false

            binding.cardMusic.setBackgroundResource(R.drawable.card_dark)
            binding.cardPhotos.setBackgroundResource(R.drawable.card_dark)
            binding.proModeContainer.setBackgroundResource(R.drawable.card_dark)
            binding.cardQueueTray.setBackgroundResource(R.drawable.card_dark)

            binding.layoutNavToggle.setBackgroundResource(R.drawable.bg_credit_meter)
            binding.layoutThemeToggle.setBackgroundResource(R.drawable.bg_credit_meter)
            binding.layoutCreditMeter.setBackgroundResource(R.drawable.bg_credit_meter)

            binding.tvSubtitle.setTextColor(Color.parseColor("#FFFCF5"))
            binding.tvStatus.setTextColor(Color.parseColor("#FFFCF5"))
            binding.tvPrivacyPolicyLink.setTextColor(Color.parseColor("#888888"))
            binding.tvAppVersion.setTextColor(Color.parseColor("#555555"))

            setupSpinners(isDark = true)
        } else {
            binding.tvThemeIcon.text = "☀️"
            binding.tvThemeLabel.text = "LIGHT"
            binding.tvThemeLabel.setTextColor(Color.parseColor("#1A1A1A"))
            binding.rootScrollView.setBackgroundColor(Color.parseColor("#F4F4F6"))
            window.statusBarColor = Color.parseColor("#F4F4F6")
            window.navigationBarColor = Color.parseColor("#F4F4F6")
            WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true

            binding.cardMusic.setBackgroundResource(R.drawable.card_light)
            binding.cardPhotos.setBackgroundResource(R.drawable.card_light)
            binding.proModeContainer.setBackgroundResource(R.drawable.card_light)
            binding.cardQueueTray.setBackgroundResource(R.drawable.card_light)

            binding.layoutNavToggle.setBackgroundResource(R.drawable.bg_credit_meter_light)
            binding.layoutThemeToggle.setBackgroundResource(R.drawable.bg_credit_meter_light)
            binding.layoutCreditMeter.setBackgroundResource(R.drawable.bg_credit_meter_light)

            binding.tvSubtitle.setTextColor(Color.parseColor("#222222"))
            binding.tvStatus.setTextColor(Color.parseColor("#1A1A1A"))
            binding.tvPrivacyPolicyLink.setTextColor(Color.parseColor("#555555"))
            binding.tvAppVersion.setTextColor(Color.parseColor("#777777"))

            setupSpinners(isDark = false)
        }
        switchNavPage(currentNavPage)
    }

    private fun setupSpinners(isDark: Boolean = true) {
        val templatePos = binding.spinnerTemplate.selectedItemPosition.coerceAtLeast(0)
        val aspectPos = binding.spinnerAspectRatio.selectedItemPosition.coerceAtLeast(0)
        val fontPos = binding.spinnerTitleFont.selectedItemPosition.coerceAtLeast(0)
        val stylePos = binding.spinnerTitleStyle.selectedItemPosition.coerceAtLeast(0)
        val framePos = binding.spinnerTitleFrame.selectedItemPosition.coerceAtLeast(0)

        val itemRes = if (isDark) R.layout.spinner_item else R.layout.spinner_item_light
        val dropRes = if (isDark) R.layout.spinner_dropdown_item else R.layout.spinner_dropdown_item_light
        val popupBg = android.graphics.drawable.ColorDrawable(Color.parseColor(if (isDark) "#2A2A2A" else "#FFFFFF"))

        binding.spinnerTemplate.adapter = android.widget.ArrayAdapter(this, itemRes, templates).apply {
            setDropDownViewResource(dropRes)
        }
        binding.spinnerTemplate.setSelection(templatePos)

        binding.spinnerAspectRatio.adapter = android.widget.ArrayAdapter(this, itemRes, aspectRatios).apply {
            setDropDownViewResource(dropRes)
        }
        binding.spinnerAspectRatio.setSelection(aspectPos)

        binding.spinnerTitleFont.adapter = android.widget.ArrayAdapter(this, itemRes, titleFonts).apply {
            setDropDownViewResource(dropRes)
        }
        binding.spinnerTitleFont.setSelection(fontPos)

        binding.spinnerTitleStyle.adapter = android.widget.ArrayAdapter(this, itemRes, titleStyles).apply {
            setDropDownViewResource(dropRes)
        }
        binding.spinnerTitleStyle.setSelection(stylePos)

        binding.spinnerTitleFrame.adapter = android.widget.ArrayAdapter(this, itemRes, titleFrames).apply {
            setDropDownViewResource(dropRes)
        }
        binding.spinnerTitleFrame.setSelection(framePos)

        binding.spinnerTemplate.setPopupBackgroundDrawable(popupBg)
        binding.spinnerAspectRatio.setPopupBackgroundDrawable(popupBg)
        binding.spinnerTitleFont.setPopupBackgroundDrawable(popupBg)
        binding.spinnerTitleStyle.setPopupBackgroundDrawable(popupBg)
        binding.spinnerTitleFrame.setPopupBackgroundDrawable(popupBg)

        val spinnerBgRes = if (isDark) R.drawable.spinner_retro else R.drawable.spinner_retro_light
        binding.spinnerTemplate.setBackgroundResource(spinnerBgRes)
        binding.spinnerAspectRatio.setBackgroundResource(spinnerBgRes)
        binding.spinnerTitleFont.setBackgroundResource(spinnerBgRes)
        binding.spinnerTitleStyle.setBackgroundResource(spinnerBgRes)
        binding.spinnerTitleFrame.setBackgroundResource(spinnerBgRes)

        val editBgRes = if (isDark) R.drawable.edit_retro else R.drawable.edit_retro_light
        binding.etTitleText.setBackgroundResource(editBgRes)
        binding.etTitleBgColor.setBackgroundResource(editBgRes)
    }

    private fun switchNavPage(page: NavPage) {
        currentNavPage = page
        when (page) {
            NavPage.AUTO -> {
                binding.containerCreation.visibility = View.VISIBLE
                binding.proModeContainer.visibility = View.GONE
                binding.containerQueuePage.visibility = View.GONE

                binding.tabNavAuto.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.tabNavAuto.setTextColor(Color.parseColor("#000000"))
                binding.tabNavPro.setBackgroundColor(Color.TRANSPARENT)
                binding.tabNavPro.setTextColor(Color.parseColor("#888888"))
                binding.tabNavQueue.setBackgroundColor(Color.TRANSPARENT)
                binding.tabNavQueue.setTextColor(Color.parseColor("#888888"))
            }
            NavPage.PRO -> {
                binding.containerCreation.visibility = View.VISIBLE
                binding.proModeContainer.visibility = View.VISIBLE
                binding.containerQueuePage.visibility = View.GONE

                binding.tabNavAuto.setBackgroundColor(Color.TRANSPARENT)
                binding.tabNavAuto.setTextColor(Color.parseColor("#888888"))
                binding.tabNavPro.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.tabNavPro.setTextColor(Color.parseColor("#000000"))
                binding.tabNavQueue.setBackgroundColor(Color.TRANSPARENT)
                binding.tabNavQueue.setTextColor(Color.parseColor("#888888"))
            }
            NavPage.QUEUE -> {
                binding.containerCreation.visibility = View.GONE
                binding.containerQueuePage.visibility = View.VISIBLE

                binding.tabNavAuto.setBackgroundColor(Color.TRANSPARENT)
                binding.tabNavAuto.setTextColor(Color.parseColor("#888888"))
                binding.tabNavPro.setBackgroundColor(Color.TRANSPARENT)
                binding.tabNavPro.setTextColor(Color.parseColor("#888888"))
                binding.tabNavQueue.setBackgroundResource(R.drawable.btn_retro_blue)
                binding.tabNavQueue.setTextColor(Color.parseColor("#000000"))
            }
        }
        updatePhotoArrangementVisibility()
        if (page == NavPage.QUEUE) {
            refreshQueueLedgerUI()
        }
    }

    private fun setupQueueRecyclerView() {
        val jobs = queueJobManager.getJobs()
        queueJobAdapter = QueueJobAdapter(
            context = this,
            jobs = jobs,
            onPlayClick = { job -> handleQueuePlay(job) },
            onDownloadClick = { job -> handleQueueDownload(job) },
            onFavouriteClick = { job ->
                val newFav = queueJobManager.toggleFavourite(job.id)
                job.isFavourite = newFav
                refreshQueueLedgerUI()
            },
            onDeleteClick = { job ->
                queueJobManager.deleteJob(job.id)
                refreshQueueLedgerUI()
                Toast.makeText(this, "Removed from history", Toast.LENGTH_SHORT).show()
            }
        )
        binding.rvQueueJobs.layoutManager = LinearLayoutManager(this)
        binding.rvQueueJobs.adapter = queueJobAdapter
        refreshQueueLedgerUI()
    }

    private fun refreshQueueLedgerUI() {
        if (!::queueJobManager.isInitialized) return
        val jobs = queueJobManager.getJobs()
        if (jobs.isEmpty()) {
            binding.layoutQueueEmpty.visibility = View.VISIBLE
            binding.rvQueueJobs.visibility = View.GONE
            binding.btnClearQueue.visibility = View.GONE
        } else {
            binding.layoutQueueEmpty.visibility = View.GONE
            binding.rvQueueJobs.visibility = View.VISIBLE
            binding.btnClearQueue.visibility = View.VISIBLE
            if (::queueJobAdapter.isInitialized) {
                queueJobAdapter.updateData(jobs)
            }
        }
    }

    private fun handleQueuePlay(job: QueueJob) {
        val uriStr = job.videoUri ?: return
        if (unlockedVideoUris.contains(uriStr) || creditManager.isProSubscriber()) {
            val intent = Intent(this, PreviewActivity::class.java).apply {
                putExtra(PreviewActivity.EXTRA_VIDEO_URI, uriStr)
            }
            startActivity(intent)
        } else {
            Toast.makeText(this, "Loading sponsor message to play video...", Toast.LENGTH_SHORT).show()
            rewardedAdManager.showRewardedAd(
                activity = this,
                onUnlocked = {
                    unlockedVideoUris.add(uriStr)
                    val intent = Intent(this, PreviewActivity::class.java).apply {
                        putExtra(PreviewActivity.EXTRA_VIDEO_URI, uriStr)
                    }
                    startActivity(intent)
                },
                onIncompleteOrFailed = { reason ->
                    Toast.makeText(this, reason, Toast.LENGTH_LONG).show()
                }
            )
        }
    }

    private fun handleQueueDownload(job: QueueJob) {
        val uriStr = job.videoUri ?: return
        if (unlockedVideoUris.contains(uriStr) || creditManager.isProSubscriber()) {
            Toast.makeText(this, "Video is already saved in your Movies/SnapBeat gallery! 🎬", Toast.LENGTH_LONG).show()
        } else {
            Toast.makeText(this, "Loading sponsor message to download video...", Toast.LENGTH_SHORT).show()
            rewardedAdManager.showRewardedAd(
                activity = this,
                onUnlocked = {
                    unlockedVideoUris.add(uriStr)
                    Toast.makeText(this, "Video is ready and saved in your Movies/SnapBeat gallery! 🎬", Toast.LENGTH_LONG).show()
                },
                onIncompleteOrFailed = { reason ->
                    Toast.makeText(this, reason, Toast.LENGTH_LONG).show()
                }
            )
        }
    }

    private fun showClearQueueConfirmationDialog() {
        androidx.appcompat.app.AlertDialog.Builder(this)
            .setTitle("Clear Render History")
            .setMessage("Are you sure you want to clear all renders from this list? (Downloaded videos in your gallery will not be deleted).")
            .setPositiveButton("Clear All") { d, _ ->
                d.dismiss()
                queueJobManager.clearAll()
                refreshQueueLedgerUI()
                Toast.makeText(this, "Queue history cleared", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
