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
    private var selectedMusicUri: Uri? = null
    private var selectedPhotos = mutableListOf<Uri>()
    private lateinit var photoOrderAdapter: PhotoOrderAdapter
    private var lastVideoUri: android.net.Uri? = null
    private var audioDurationSeconds: Int = 0
    private var audioStartSeconds: Int = 0
    private var audioEndSeconds: Int = 0
    private var isFullTrack: Boolean = true
    private var isDarkMode: Boolean = true
    private val PREFS_NAME = "snapbeat_prefs"
    private val KEY_DARK_MODE = "is_dark_mode"
    enum class AppTheme(val id: String, val displayName: String) {
        RETRO_DARK("dark", "🌙 Retro Dark"),
        RETRO_LIGHT("light", "☀️ Retro Light"),
        VINTAGE_Y2K("vintage_y2k", "📼 Vintage Y2K Boombox")
    }

    private var currentTheme: AppTheme = AppTheme.RETRO_DARK
    private val KEY_CURRENT_THEME = "current_theme_v2"
    private val KEY_PRIVACY_ACCEPTED = "privacy_policy_accepted_v1"
    private val PRIVACY_POLICY_URL = "https://github.com/prashanthkandagatla8-ux/snapbeat/blob/android/PRIVACY_POLICY.md"

    private val KEY_CACHED_SERVER_URL = "cached_server_url"
    private val REMOTE_CONFIG_URL = "https://raw.githubusercontent.com/prashanthkandagatla8-ux/snapbeat/main/config.json"

    private fun getServerUrl(): String {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val cached = prefs.getString(KEY_CACHED_SERVER_URL, null)
        return if (!cached.isNullOrBlank()) cached else BuildConfig.SERVER_URL
    }

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
                        val remoteUrl = json.optString("server_url", "").trim().trimEnd('/')
                        if (remoteUrl.isNotEmpty()) {
                            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                                .edit()
                                .putString(KEY_CACHED_SERVER_URL, remoteUrl)
                                .apply()
                        }
                    }
                }
            } catch (e: Exception) {
                // Graceful fallback to cached or BuildConfig.SERVER_URL
            }
        }
    }

    private val templates = arrayOf("Beat Cut", "Bounce", "Cine Zoom", "Fade", "Glide", "Mosaic Flow", "Mosaic Pulse", "Pendulum", "Pendulum OG", "Pulse", "Punch", "Reveal Bounce", "Reveal Boxes", "Reveal Circles", "Reveal Grid", "Reveal Spiral", "Slide", "Slow Drift", "Spin", "Sway", "Whip", "Zoom Out")
    private val aspectRatios = arrayOf("Portrait (9:16)", "Landscape (16:9)", "Square (1:1)")
    private val titleFonts = arrayOf("Bold Blockbuster (Impact)", "Elegant Serif (Georgia)", "Modern Minimal (Clean)", "Vintage Typewriter", "Casual Retro (Playful)")
    private val titleStyles = arrayOf("Classic Yellow Drop-Shadow", "Neon Glow (Electric Cyan)", "3D Retro Arcade Extrusion", "Cinematic All-Caps", "Badge Tag Container")
    private val titleFrames = arrayOf("None (Borderless)", "Cinematic Box Border", "Viewfinder Camera Corners", "Retro Double Border", "Film Letterbox Bars")

    // Single ItemTouchHelper instance — attached once, never duplicated
    private var itemTouchHelper: ItemTouchHelper? = null
    
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
            binding.tvPhotosStatus.text = if (currentTheme == AppTheme.VINTAGE_Y2K) {
                "$count polaroids in stack (Max 60)"
            } else {
                "$count photos loaded (Max 60)"
            }
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
        isDarkMode = prefs.getBoolean(KEY_DARK_MODE, true)

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

        // Initial theme setup & listener
        val savedThemeStr = prefs.getString(KEY_CURRENT_THEME, null)
        currentTheme = if (savedThemeStr != null) {
            AppTheme.values().find { it.id == savedThemeStr } ?: AppTheme.RETRO_DARK
        } else {
            if (prefs.getBoolean(KEY_DARK_MODE, true)) AppTheme.RETRO_DARK else AppTheme.RETRO_LIGHT
        }
        isDarkMode = (currentTheme == AppTheme.RETRO_DARK)
        applyTheme(currentTheme)

        binding.btnThemeSelect.setOnClickListener {
            showThemeSelectionDialog()
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

        binding.switchMode.setOnCheckedChangeListener { _, isChecked ->
            updateModeSwitchLabels()
            if (isChecked) {
                binding.proModeContainer.visibility = View.VISIBLE
            } else {
                binding.proModeContainer.visibility = View.GONE
            }
            updatePhotoArrangementVisibility()
        }

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

        binding.btnRender.setOnClickListener {
            if (selectedMusicUri == null || selectedPhotos.isEmpty()) {
                Toast.makeText(this, "Please pick actual music and photos first!", Toast.LENGTH_LONG).show()
                return@setOnClickListener
            }
            uploadAndRender()
        }

        binding.btnQueue.setOnClickListener {
            queueBackgroundRender()
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

    private fun updateAudioTrimLabels() {
        binding.tvAudioStart.text = "Start Time: ${formatTime(audioStartSeconds)}"
        binding.tvAudioEnd.text = "End Time: ${formatTime(audioEndSeconds)}"
        val duration = maxOf(0, audioEndSeconds - audioStartSeconds)
        binding.tvAudioRange.text = "Start: ${formatTime(audioStartSeconds)}  |  End: ${formatTime(audioEndSeconds)}  (Duration: ${formatTime(duration)})"
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
        binding.btnRender.isEnabled = false

        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val builder = MultipartBody.Builder().setType(MultipartBody.FORM)

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

                if (binding.switchMode.isChecked) {
                    val selection = binding.spinnerTemplate.selectedItem?.toString() ?: "simple"
                    val templateName = when(selection) {
                        "Beat Cut" -> "beat-cut"
                        "Bounce" -> "beat-bounce"
                        "Cine Zoom" -> "cinematic-zoom"
                        "Fade" -> "beat-fade"
                        "Glide" -> "glide-pan"
                        "Mosaic Flow" -> "mosaic-flow"
                        "Mosaic Pulse" -> "aesthetic-beat-mosaic"
                        "Pendulum" -> "pendulum"
                        "Pendulum OG" -> "beat-pendulum"
                        "Pulse" -> "beat-pulse"
                        "Punch" -> "punch-cut"
                        "Reveal Bounce" -> "reveal-tiles-bounce"
                        "Reveal Boxes" -> "reveal-tiles"
                        "Reveal Circles" -> "reveal-circles"
                        "Reveal Grid" -> "reveal-tiles-fine"
                        "Reveal Spiral" -> "reveal-spiral"
                        "Slide" -> "beat-slide"
                        "Slow Drift" -> "slow-drift"
                        "Spin" -> "beat-spin"
                        "Sway" -> "sway-ballad"
                        "Whip" -> "beat-whip"
                        "Zoom Out" -> "zoom-out-reveal"
                        else -> "simple"
                    }
                    builder.addFormDataPart("template", templateName)

                    // Send drop_it flag if enabled
                    if (binding.switchDropIt.isChecked) {
                        builder.addFormDataPart("drop_it", "true")
                    }

                    // Send aspect ratio
                    val frameValue = when(binding.spinnerAspectRatio.selectedItemPosition) {
                        0 -> "portrait"
                        1 -> "landscape"
                        2 -> "square"
                        else -> "portrait"
                    }
                    builder.addFormDataPart("frame", frameValue)

                    // Send title if provided
                    val titleText = binding.etTitleText.text.toString().trim()
                    if (titleText.isNotEmpty()) {
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
                    val qualityVal = if (binding.rbQualityMaster.isChecked) "master" else "fast"
                    builder.addFormDataPart("quality", qualityVal)
                } else {
                    builder.addFormDataPart("quality", "fast")
                }

                // Photo arrangement: auto (Gemini / smart) vs manual
                val isPro = binding.switchMode.isChecked
                val autoArrange = if (!isPro || binding.rbArrangeAuto.isChecked) "auto" else "manual"
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

                val requestBody = builder.build()
                val request = Request.Builder()
                    .url(getServerUrl() + "/api/render/mobile") 
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
                pollStatusAndDownload(jobId)

            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    binding.progressBar.visibility = View.GONE
                    binding.tvStatus.text = "Error: ${e.message}"
                    binding.btnRender.isEnabled = true
                    binding.btnRetry.visibility = View.VISIBLE
                }
                clearCache()
            }
        }
    }

    private suspend fun pollStatusAndDownload(jobId: String) {
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
                    .url(getServerUrl() + "/api/render/status/$jobId")
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
            .url(getServerUrl() + "/api/render/download/$jobId?delete_after=true")
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
                binding.btnRender.isEnabled = true
                lastVideoUri = uri

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
                val isPro = binding.switchMode.isChecked
                val quality = if (isPro && binding.rbQualityMaster.isChecked) "master" else "fast"

                val templateName = if (isPro) {
                    val selection = binding.spinnerTemplate.selectedItem?.toString() ?: "simple"
                    when (selection) {
                        "Beat Cut" -> "beat-cut"
                        "Bounce" -> "beat-bounce"
                        "Cine Zoom" -> "cinematic-zoom"
                        "Fade" -> "beat-fade"
                        "Glide" -> "glide-pan"
                        "Mosaic Flow" -> "mosaic-flow"
                        "Mosaic Pulse" -> "aesthetic-beat-mosaic"
                        "Pendulum" -> "pendulum"
                        "Pendulum OG" -> "beat-pendulum"
                        "Pulse" -> "beat-pulse"
                        "Punch" -> "punch-cut"
                        "Reveal Bounce" -> "reveal-tiles-bounce"
                        "Reveal Boxes" -> "reveal-tiles"
                        "Reveal Circles" -> "reveal-circles"
                        "Reveal Grid" -> "reveal-tiles-fine"
                        "Reveal Spiral" -> "reveal-spiral"
                        "Slide" -> "beat-slide"
                        "Slow Drift" -> "slow-drift"
                        "Spin" -> "beat-spin"
                        "Sway" -> "sway-ballad"
                        "Whip" -> "beat-whip"
                        "Zoom Out" -> "zoom-out-reveal"
                        else -> "simple"
                    }
                } else {
                    "simple"
                }

                val frameValue = if (isPro) {
                    when (binding.spinnerAspectRatio.selectedItemPosition) {
                        0 -> "portrait"
                        1 -> "landscape"
                        2 -> "square"
                        else -> "portrait"
                    }
                } else {
                    "portrait"
                }

                val titleText = if (isPro) binding.etTitleText.text.toString().trim() else ""
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

                val autoArrange = if (!isPro || binding.rbArrangeAuto.isChecked) "auto" else "manual"

                val data = Data.Builder()
                    .putString(RenderQueueWorker.KEY_JOB_DIR, jobDir.absolutePath)
                    .putString(RenderQueueWorker.KEY_AUTO_ARRANGE, autoArrange)
                    .putString(RenderQueueWorker.KEY_SERVER_URL, getServerUrl())
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

                withContext(Dispatchers.Main) {
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
                        binding.btnViewQueueVideo.visibility = View.GONE
                    }
                    WorkInfo.State.SUCCEEDED -> {
                        binding.cardQueueTray.visibility = View.VISIBLE
                        binding.queueProgressBar.visibility = View.GONE
                        binding.tvQueueBadge.text = "COMPLETE ✓"
                        binding.tvQueueBadge.setTextColor(Color.parseColor("#3DD4FF"))
                        binding.tvQueueStatus.text = "Video rendered & saved to your Gallery! 🎬"
                        val videoUriStr = info.outputData.getString(RenderQueueWorker.OUTPUT_VIDEO_URI)
                        if (!videoUriStr.isNullOrEmpty()) {
                            binding.btnViewQueueVideo.visibility = View.VISIBLE
                            binding.btnViewQueueVideo.setOnClickListener {
                                val intent = Intent(this@MainActivity, PreviewActivity::class.java).apply {
                                    putExtra(PreviewActivity.EXTRA_VIDEO_URI, videoUriStr)
                                }
                                startActivity(intent)
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
                        binding.btnViewQueueVideo.visibility = View.GONE
                    }
                    WorkInfo.State.CANCELLED -> {
                        binding.cardQueueTray.visibility = View.GONE
                    }
                    else -> {}
                }
            }
    }

    private fun updatePhotoArrangementVisibility() {
        val isPro = binding.switchMode.isChecked
        if (!isPro) {
            binding.rvPhotoOrder.visibility = View.GONE
            binding.layoutAutoArrangeBadge.visibility = View.VISIBLE
            binding.tvAutoArrangeBadge.text = "AI SMART ARRANGE (GEMINI BEAT-SYNC)"
        } else {
            if (binding.rbArrangeManual.isChecked) {
                binding.layoutAutoArrangeBadge.visibility = View.GONE
                binding.rvPhotoOrder.visibility = if (selectedPhotos.isNotEmpty()) View.VISIBLE else View.GONE
            } else {
                binding.rvPhotoOrder.visibility = View.GONE
                binding.layoutAutoArrangeBadge.visibility = View.VISIBLE
                binding.tvAutoArrangeBadge.text = "AI SMART ARRANGE (GEMINI BEAT-SYNC)"
            }
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
    private fun showThemeSelectionDialog() {
        val themes = AppTheme.values()
        val names = themes.map { it.displayName }.toTypedArray()
        val currentIdx = themes.indexOf(currentTheme)

        androidx.appcompat.app.AlertDialog.Builder(this)
            .setTitle("Select App Theme")
            .setSingleChoiceItems(names, currentIdx) { dialog, which ->
                currentTheme = themes[which]
                isDarkMode = (currentTheme == AppTheme.RETRO_DARK)
                getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putString(KEY_CURRENT_THEME, currentTheme.id)
                    .putBoolean(KEY_DARK_MODE, isDarkMode)
                    .apply()
                applyTheme(currentTheme)
                dialog.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun setupSpinners(theme: AppTheme) {
        val templatePos = binding.spinnerTemplate.selectedItemPosition.coerceAtLeast(0)
        val aspectPos = binding.spinnerAspectRatio.selectedItemPosition.coerceAtLeast(0)
        val fontPos = binding.spinnerTitleFont.selectedItemPosition.coerceAtLeast(0)
        val stylePos = binding.spinnerTitleStyle.selectedItemPosition.coerceAtLeast(0)
        val framePos = binding.spinnerTitleFrame.selectedItemPosition.coerceAtLeast(0)

        val (itemRes, dropRes, popupBgColor) = when (theme) {
            AppTheme.RETRO_DARK -> Triple(R.layout.spinner_item, R.layout.spinner_dropdown_item, "#2A2A2A")
            AppTheme.RETRO_LIGHT -> Triple(R.layout.spinner_item_light, R.layout.spinner_dropdown_item_light, "#FFFFFF")
            AppTheme.VINTAGE_Y2K -> Triple(R.layout.spinner_item_y2k, R.layout.spinner_dropdown_item_y2k, "#FFFDF9")
        }

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

        val popupBg = android.graphics.drawable.ColorDrawable(Color.parseColor(popupBgColor))
        binding.spinnerTemplate.setPopupBackgroundDrawable(popupBg)
        binding.spinnerAspectRatio.setPopupBackgroundDrawable(popupBg)
        binding.spinnerTitleFont.setPopupBackgroundDrawable(popupBg)
        binding.spinnerTitleStyle.setPopupBackgroundDrawable(popupBg)
        binding.spinnerTitleFrame.setPopupBackgroundDrawable(popupBg)
    }

    private fun applyTheme(theme: AppTheme) {
        // 1. Theme indicator button text
        binding.btnThemeSelect.text = when (theme) {
            AppTheme.RETRO_DARK -> "🎨 THEME: DARK ▾"
            AppTheme.RETRO_LIGHT -> "🎨 THEME: LIGHT ▾"
            AppTheme.VINTAGE_Y2K -> "🎨 THEME: Y2K ▾"
        }

        // 2. Mode switch indicators (AUTO / PRO)
        updateModeSwitchLabels()

        when (theme) {
            AppTheme.RETRO_DARK -> {
                // Root Background & Bars
                val rootBg = Color.parseColor("#1A1A1A")
                binding.rootScrollView.setBackgroundColor(rootBg)
                window.statusBarColor = rootBg
                window.navigationBarColor = rootBg
                WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = false

                // Header
                binding.tvTitle.text = "SNAPBEAT"
                binding.tvTitle.setTextColor(Color.parseColor("#FFE14D"))
                binding.tvTitle.setShadowLayer(0f, 3f, 3f, Color.parseColor("#000000"))
                binding.tvSubtitle.text = "let the music decide your edit."
                binding.tvSubtitle.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvSubtitle.alpha = 0.7f

                // Cards
                binding.proModeContainer.setBackgroundResource(R.drawable.card_dark)
                binding.cardMusic.setBackgroundResource(R.drawable.card_dark)
                binding.cardPhotos.setBackgroundResource(R.drawable.card_dark)
                binding.cardQueueTray.setBackgroundResource(R.drawable.card_dark)

                // Buttons
                binding.btnSelectMusic.setBackgroundResource(R.drawable.btn_retro_pink)
                binding.btnSelectMusic.text = "PICK A TAPE"
                binding.btnSampleMusic.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.btnSampleMusic.text = "✨ USE SAMPLE TAPE (Funk Party)"
                binding.btnSelectPhotos.setBackgroundResource(R.drawable.btn_retro_blue)
                binding.btnSelectPhotos.text = "POLAROID STACK"
                binding.btnRender.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.btnRender.text = "RENDER VIDEO"
                binding.btnQueue.setBackgroundResource(R.drawable.btn_retro_pink)
                binding.btnRetry.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.btnThemeSelect.setTextColor(Color.parseColor("#FFE14D"))

                // Headers & Labels
                binding.tvMusicHeader.text = "🎵 MUSIC"
                binding.tvMusicHeader.setTextColor(Color.parseColor("#FF4D8D"))
                binding.tvMusicStatus.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvMusicStatus.alpha = 0.7f
                binding.rbAudioFull.setTextColor(Color.parseColor("#FFFCF5"))
                binding.rbAudioTrim.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvAudioStart.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvAudioEnd.setTextColor(Color.parseColor("#FFFCF5"))
                binding.divTrim1.setBackgroundColor(Color.parseColor("#2E2E2E"))

                binding.tvPhotosHeader.text = "📸 PHOTOS"
                binding.tvPhotosHeader.setTextColor(Color.parseColor("#3DD4FF"))
                binding.tvPhotosStatus.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvPhotosStatus.alpha = 0.6f

                // Auto arrange badge
                binding.layoutAutoArrangeBadge.setBackgroundResource(R.drawable.badge_circle)
                binding.tvAutoArrangeIcon.text = "✨"
                binding.tvAutoArrangeBadge.setTextColor(Color.parseColor("#FFE14D"))

                binding.tvStatus.setTextColor(Color.parseColor("#FFFCF5"))

                // Pro container
                binding.tvProTemplateHeader.text = "⚡ PRO TEMPLATE"
                binding.tvProTemplateHeader.setTextColor(Color.parseColor("#FFE14D"))
                binding.divPro1.setBackgroundColor(Color.parseColor("#333333"))
                binding.tvDropItDesc.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvDropItDesc.alpha = 0.5f
                binding.divPro2.setBackgroundColor(Color.parseColor("#333333"))
                binding.tvAspectRatioHeader.setTextColor(Color.parseColor("#3DD4FF"))
                binding.divProQuality.setBackgroundColor(Color.parseColor("#333333"))
                binding.tvQualityHeader.setTextColor(Color.parseColor("#3DD4FF"))
                binding.rbQualityFast.setTextColor(Color.parseColor("#FFFCF5"))
                binding.rbQualityMaster.setTextColor(Color.parseColor("#FFFCF5"))

                // Arrangement in Pro
                binding.divProArrangement.setBackgroundColor(Color.parseColor("#333333"))
                binding.tvArrangementHeader.setTextColor(Color.parseColor("#FFE14D"))
                binding.rbArrangeAuto.setTextColor(Color.parseColor("#FFFCF5"))
                binding.rbArrangeManual.setTextColor(Color.parseColor("#FFFCF5"))
                binding.rbArrangeAuto.buttonTintList = ColorStateList.valueOf(Color.parseColor("#FFE14D"))
                binding.rbArrangeManual.buttonTintList = ColorStateList.valueOf(Color.parseColor("#FFE14D"))

                binding.divPro3.setBackgroundColor(Color.parseColor("#333333"))
                binding.tvTitleCardHeader.setTextColor(Color.parseColor("#FFE14D"))
                binding.tvTitleFontLabel.setTextColor(Color.parseColor("#999999"))
                binding.tvTitleStyleLabel.setTextColor(Color.parseColor("#999999"))
                binding.tvTitleFrameLabel.setTextColor(Color.parseColor("#999999"))
                binding.tvTitleBgLabel.setTextColor(Color.parseColor("#999999"))
                binding.rbBgBlack.setTextColor(Color.parseColor("#FFFCF5"))
                binding.rbBgColor.setTextColor(Color.parseColor("#FFFCF5"))
                binding.rbBgVideo.setTextColor(Color.parseColor("#FFFCF5"))
                binding.tvTitleDurationLabel.setTextColor(Color.parseColor("#999999"))
                binding.tvTitleDuration.setTextColor(Color.parseColor("#FFE14D"))

                binding.tvQueueTitle.setTextColor(Color.parseColor("#3DD4FF"))
                binding.tvQueueStatus.setTextColor(Color.parseColor("#FFFCF5"))

                // Spinners & Inputs
                binding.etTitleText.setBackgroundResource(R.drawable.spinner_retro)
                binding.etTitleText.setTextColor(Color.parseColor("#FFFCF5"))
                binding.etTitleText.setHintTextColor(Color.parseColor("#666666"))
                binding.etTitleBgColor.setBackgroundResource(R.drawable.spinner_retro)
                binding.etTitleBgColor.setTextColor(Color.parseColor("#FFFCF5"))
                binding.etTitleBgColor.setHintTextColor(Color.parseColor("#666666"))

                binding.spinnerTemplate.setBackgroundResource(R.drawable.spinner_retro)
                binding.spinnerAspectRatio.setBackgroundResource(R.drawable.spinner_retro)
                binding.spinnerTitleFont.setBackgroundResource(R.drawable.spinner_retro)
                binding.spinnerTitleStyle.setBackgroundResource(R.drawable.spinner_retro)
                binding.spinnerTitleFrame.setBackgroundResource(R.drawable.spinner_retro)

                binding.tvPrivacyPolicyLink.setTextColor(Color.parseColor("#888888"))
                binding.tvAppVersion.setTextColor(Color.parseColor("#555555"))
            }

            AppTheme.RETRO_LIGHT -> {
                // Root Background & Bars
                val rootBg = Color.parseColor("#F4F4F6")
                binding.rootScrollView.setBackgroundColor(rootBg)
                window.statusBarColor = rootBg
                window.navigationBarColor = rootBg
                WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true

                // Header
                binding.tvTitle.text = "SNAPBEAT"
                binding.tvTitle.setTextColor(Color.parseColor("#1A1A1A"))
                binding.tvTitle.setShadowLayer(0f, 3f, 3f, Color.parseColor("#FFE14D"))
                binding.tvSubtitle.text = "let the music decide your edit."
                binding.tvSubtitle.setTextColor(Color.parseColor("#666666"))
                binding.tvSubtitle.alpha = 0.9f

                // Cards
                binding.proModeContainer.setBackgroundResource(R.drawable.card_light)
                binding.cardMusic.setBackgroundResource(R.drawable.card_light)
                binding.cardPhotos.setBackgroundResource(R.drawable.card_light)
                binding.cardQueueTray.setBackgroundResource(R.drawable.card_light)

                // Buttons
                binding.btnSelectMusic.setBackgroundResource(R.drawable.btn_retro_pink)
                binding.btnSelectMusic.text = "PICK A TAPE"
                binding.btnSampleMusic.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.btnSampleMusic.text = "✨ USE SAMPLE TAPE (Funk Party)"
                binding.btnSelectPhotos.setBackgroundResource(R.drawable.btn_retro_blue)
                binding.btnSelectPhotos.text = "POLAROID STACK"
                binding.btnRender.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.btnRender.text = "RENDER VIDEO"
                binding.btnQueue.setBackgroundResource(R.drawable.btn_retro_pink)
                binding.btnRetry.setBackgroundResource(R.drawable.btn_retro_yellow)
                binding.btnThemeSelect.setTextColor(Color.parseColor("#1A1A1A"))

                // Headers & Labels
                binding.tvMusicHeader.text = "🎵 MUSIC"
                binding.tvMusicHeader.setTextColor(Color.parseColor("#D81B60"))
                binding.tvMusicStatus.setTextColor(Color.parseColor("#333333"))
                binding.tvMusicStatus.alpha = 0.9f
                binding.rbAudioFull.setTextColor(Color.parseColor("#222222"))
                binding.rbAudioTrim.setTextColor(Color.parseColor("#222222"))
                binding.tvAudioStart.setTextColor(Color.parseColor("#333333"))
                binding.tvAudioEnd.setTextColor(Color.parseColor("#333333"))
                binding.divTrim1.setBackgroundColor(Color.parseColor("#E5E5E5"))

                binding.tvPhotosHeader.text = "📸 PHOTOS"
                binding.tvPhotosHeader.setTextColor(Color.parseColor("#0288D1"))
                binding.tvPhotosStatus.setTextColor(Color.parseColor("#444444"))
                binding.tvPhotosStatus.alpha = 0.9f

                // Auto arrange badge
                binding.layoutAutoArrangeBadge.setBackgroundResource(R.drawable.badge_circle)
                binding.tvAutoArrangeIcon.text = "✨"
                binding.tvAutoArrangeBadge.setTextColor(Color.parseColor("#0288D1"))

                binding.tvStatus.setTextColor(Color.parseColor("#1A1A1A"))

                // Pro container
                binding.tvProTemplateHeader.text = "⚡ PRO TEMPLATE"
                binding.tvProTemplateHeader.setTextColor(Color.parseColor("#1A1A1A"))
                binding.divPro1.setBackgroundColor(Color.parseColor("#E0E0E0"))
                binding.tvDropItDesc.setTextColor(Color.parseColor("#555555"))
                binding.tvDropItDesc.alpha = 0.8f
                binding.divPro2.setBackgroundColor(Color.parseColor("#E0E0E0"))
                binding.tvAspectRatioHeader.setTextColor(Color.parseColor("#0288D1"))
                binding.divProQuality.setBackgroundColor(Color.parseColor("#E0E0E0"))
                binding.tvQualityHeader.setTextColor(Color.parseColor("#0288D1"))
                binding.rbQualityFast.setTextColor(Color.parseColor("#222222"))
                binding.rbQualityMaster.setTextColor(Color.parseColor("#222222"))

                // Arrangement in Pro
                binding.divProArrangement.setBackgroundColor(Color.parseColor("#E0E0E0"))
                binding.tvArrangementHeader.setTextColor(Color.parseColor("#0288D1"))
                binding.rbArrangeAuto.setTextColor(Color.parseColor("#222222"))
                binding.rbArrangeManual.setTextColor(Color.parseColor("#222222"))
                binding.rbArrangeAuto.buttonTintList = ColorStateList.valueOf(Color.parseColor("#0288D1"))
                binding.rbArrangeManual.buttonTintList = ColorStateList.valueOf(Color.parseColor("#0288D1"))

                binding.divPro3.setBackgroundColor(Color.parseColor("#E0E0E0"))
                binding.tvTitleCardHeader.setTextColor(Color.parseColor("#1A1A1A"))
                binding.tvTitleFontLabel.setTextColor(Color.parseColor("#555555"))
                binding.tvTitleStyleLabel.setTextColor(Color.parseColor("#555555"))
                binding.tvTitleFrameLabel.setTextColor(Color.parseColor("#555555"))
                binding.tvTitleBgLabel.setTextColor(Color.parseColor("#555555"))
                binding.rbBgBlack.setTextColor(Color.parseColor("#222222"))
                binding.rbBgColor.setTextColor(Color.parseColor("#222222"))
                binding.rbBgVideo.setTextColor(Color.parseColor("#222222"))
                binding.tvTitleDurationLabel.setTextColor(Color.parseColor("#555555"))
                binding.tvTitleDuration.setTextColor(Color.parseColor("#1A1A1A"))

                binding.tvQueueTitle.setTextColor(Color.parseColor("#0288D1"))
                binding.tvQueueStatus.setTextColor(Color.parseColor("#333333"))

                // Spinners & Inputs
                binding.etTitleText.setBackgroundResource(R.drawable.spinner_retro_light)
                binding.etTitleText.setTextColor(Color.parseColor("#1A1A1A"))
                binding.etTitleText.setHintTextColor(Color.parseColor("#999999"))
                binding.etTitleBgColor.setBackgroundResource(R.drawable.spinner_retro_light)
                binding.etTitleBgColor.setTextColor(Color.parseColor("#1A1A1A"))
                binding.etTitleBgColor.setHintTextColor(Color.parseColor("#999999"))

                binding.spinnerTemplate.setBackgroundResource(R.drawable.spinner_retro_light)
                binding.spinnerAspectRatio.setBackgroundResource(R.drawable.spinner_retro_light)
                binding.spinnerTitleFont.setBackgroundResource(R.drawable.spinner_retro_light)
                binding.spinnerTitleStyle.setBackgroundResource(R.drawable.spinner_retro_light)
                binding.spinnerTitleFrame.setBackgroundResource(R.drawable.spinner_retro_light)

                binding.tvPrivacyPolicyLink.setTextColor(Color.parseColor("#555555"))
                binding.tvAppVersion.setTextColor(Color.parseColor("#777777"))
            }

            AppTheme.VINTAGE_Y2K -> {
                // Root Background & Bars (Warm paper cream)
                val rootBg = Color.parseColor("#F6F3EC")
                binding.rootScrollView.setBackgroundColor(rootBg)
                window.statusBarColor = rootBg
                window.navigationBarColor = rootBg
                WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true

                // Header
                binding.tvTitle.text = "SNAPBEAT 📼"
                binding.tvTitle.setTextColor(Color.parseColor("#2B2A27"))
                binding.tvTitle.setShadowLayer(0f, 3f, 3f, Color.parseColor("#FF9F1C"))
                binding.tvSubtitle.text = "let the tape roll & the music decide your edit."
                binding.tvSubtitle.setTextColor(Color.parseColor("#7A756C"))
                binding.tvSubtitle.alpha = 0.95f

                // Cards (Warm Polaroid Cream with 3D Charcoal borders)
                binding.proModeContainer.setBackgroundResource(R.drawable.card_y2k)
                binding.cardMusic.setBackgroundResource(R.drawable.card_y2k)
                binding.cardPhotos.setBackgroundResource(R.drawable.card_y2k)
                binding.cardQueueTray.setBackgroundResource(R.drawable.card_y2k)

                // Buttons (Cassette deck styling)
                binding.btnSelectMusic.setBackgroundResource(R.drawable.btn_y2k_pink)
                binding.btnSelectMusic.text = "📼 LOAD CASSETTE TAPE"
                binding.btnSampleMusic.setBackgroundResource(R.drawable.btn_y2k_amber)
                binding.btnSampleMusic.text = "✨ DEMO TAPE (Funk Party)"
                binding.btnSelectPhotos.setBackgroundResource(R.drawable.btn_y2k_amber)
                binding.btnSelectPhotos.text = "📸 SHUFFLE POLAROIDS"
                binding.btnRender.setBackgroundResource(R.drawable.btn_y2k_black)
                binding.btnRender.text = "● REC / RENDER VIDEO"
                binding.btnQueue.setBackgroundResource(R.drawable.btn_y2k_pink)
                binding.btnRetry.setBackgroundResource(R.drawable.btn_y2k_amber)
                binding.btnThemeSelect.setTextColor(Color.parseColor("#FF9F1C"))

                // Headers & Labels
                binding.tvMusicHeader.text = "📼 CASSETTE DECK / TAPE"
                binding.tvMusicHeader.setTextColor(Color.parseColor("#FF4D8D"))
                binding.tvMusicStatus.setTextColor(Color.parseColor("#4A463F"))
                binding.tvMusicStatus.alpha = 0.9f
                binding.rbAudioFull.setTextColor(Color.parseColor("#2B2A27"))
                binding.rbAudioTrim.setTextColor(Color.parseColor("#2B2A27"))
                binding.tvAudioStart.setTextColor(Color.parseColor("#4A463F"))
                binding.tvAudioEnd.setTextColor(Color.parseColor("#4A463F"))
                binding.divTrim1.setBackgroundColor(Color.parseColor("#DED9CE"))

                binding.tvPhotosHeader.text = "📸 POLAROID PHOTO ROLL"
                binding.tvPhotosHeader.setTextColor(Color.parseColor("#FF9F1C"))
                binding.tvPhotosStatus.setTextColor(Color.parseColor("#4A463F"))
                binding.tvPhotosStatus.alpha = 0.9f

                // Auto arrange badge
                binding.layoutAutoArrangeBadge.setBackgroundResource(R.drawable.badge_y2k)
                binding.tvAutoArrangeIcon.text = "📼"
                binding.tvAutoArrangeBadge.setTextColor(Color.parseColor("#FF9F1C"))

                binding.tvStatus.setTextColor(Color.parseColor("#2B2A27"))

                // Pro container
                binding.tvProTemplateHeader.text = "⚡ BOOMBOX TEMPLATE"
                binding.tvProTemplateHeader.setTextColor(Color.parseColor("#2B2A27"))
                binding.divPro1.setBackgroundColor(Color.parseColor("#DED9CE"))
                binding.tvDropItDesc.setTextColor(Color.parseColor("#7A756C"))
                binding.tvDropItDesc.alpha = 0.9f
                binding.divPro2.setBackgroundColor(Color.parseColor("#DED9CE"))
                binding.tvAspectRatioHeader.setTextColor(Color.parseColor("#FF9F1C"))
                binding.divProQuality.setBackgroundColor(Color.parseColor("#DED9CE"))
                binding.tvQualityHeader.setTextColor(Color.parseColor("#FF9F1C"))
                binding.rbQualityFast.setTextColor(Color.parseColor("#2B2A27"))
                binding.rbQualityMaster.setTextColor(Color.parseColor("#2B2A27"))

                // Arrangement in Pro
                binding.divProArrangement.setBackgroundColor(Color.parseColor("#DED9CE"))
                binding.tvArrangementHeader.setTextColor(Color.parseColor("#FF9F1C"))
                binding.rbArrangeAuto.setTextColor(Color.parseColor("#2B2A27"))
                binding.rbArrangeManual.setTextColor(Color.parseColor("#2B2A27"))
                binding.rbArrangeAuto.buttonTintList = ColorStateList.valueOf(Color.parseColor("#FF9F1C"))
                binding.rbArrangeManual.buttonTintList = ColorStateList.valueOf(Color.parseColor("#FF9F1C"))

                binding.divPro3.setBackgroundColor(Color.parseColor("#DED9CE"))
                binding.tvTitleCardHeader.setTextColor(Color.parseColor("#2B2A27"))
                binding.tvTitleFontLabel.setTextColor(Color.parseColor("#7A756C"))
                binding.tvTitleStyleLabel.setTextColor(Color.parseColor("#7A756C"))
                binding.tvTitleFrameLabel.setTextColor(Color.parseColor("#7A756C"))
                binding.tvTitleBgLabel.setTextColor(Color.parseColor("#7A756C"))
                binding.rbBgBlack.setTextColor(Color.parseColor("#2B2A27"))
                binding.rbBgColor.setTextColor(Color.parseColor("#2B2A27"))
                binding.rbBgVideo.setTextColor(Color.parseColor("#2B2A27"))
                binding.tvTitleDurationLabel.setTextColor(Color.parseColor("#7A756C"))
                binding.tvTitleDuration.setTextColor(Color.parseColor("#FF9F1C"))

                binding.tvQueueTitle.setTextColor(Color.parseColor("#FF9F1C"))
                binding.tvQueueStatus.setTextColor(Color.parseColor("#4A463F"))

                // Spinners & Inputs
                binding.etTitleText.setBackgroundResource(R.drawable.spinner_retro_y2k)
                binding.etTitleText.setTextColor(Color.parseColor("#2B2A27"))
                binding.etTitleText.setHintTextColor(Color.parseColor("#8A857C"))
                binding.etTitleBgColor.setBackgroundResource(R.drawable.spinner_retro_y2k)
                binding.etTitleBgColor.setTextColor(Color.parseColor("#2B2A27"))
                binding.etTitleBgColor.setHintTextColor(Color.parseColor("#8A857C"))

                binding.spinnerTemplate.setBackgroundResource(R.drawable.spinner_retro_y2k)
                binding.spinnerAspectRatio.setBackgroundResource(R.drawable.spinner_retro_y2k)
                binding.spinnerTitleFont.setBackgroundResource(R.drawable.spinner_retro_y2k)
                binding.spinnerTitleStyle.setBackgroundResource(R.drawable.spinner_retro_y2k)
                binding.spinnerTitleFrame.setBackgroundResource(R.drawable.spinner_retro_y2k)

                binding.tvPrivacyPolicyLink.setTextColor(Color.parseColor("#7A756C"))
                binding.tvAppVersion.setTextColor(Color.parseColor("#9E9A90"))
            }
        }

        // Rebind spinners with current theme layout resources
        setupSpinners(theme)
    }

    private fun updateModeSwitchLabels() {
        val isPro = binding.switchMode.isChecked
        when (currentTheme) {
            AppTheme.RETRO_DARK -> {
                if (isPro) {
                    binding.tvModeAuto.setTextColor(Color.parseColor("#666666"))
                    binding.tvModePro.setTextColor(Color.parseColor("#FFE14D"))
                } else {
                    binding.tvModeAuto.setTextColor(Color.parseColor("#FFE14D"))
                    binding.tvModePro.setTextColor(Color.parseColor("#666666"))
                }
                binding.switchMode.thumbTintList = ColorStateList.valueOf(Color.parseColor("#FFE14D"))
                binding.switchMode.trackTintList = ColorStateList.valueOf(Color.parseColor("#333333"))
            }
            AppTheme.RETRO_LIGHT -> {
                if (isPro) {
                    binding.tvModeAuto.setTextColor(Color.parseColor("#999999"))
                    binding.tvModePro.setTextColor(Color.parseColor("#1A1A1A"))
                } else {
                    binding.tvModeAuto.setTextColor(Color.parseColor("#1A1A1A"))
                    binding.tvModePro.setTextColor(Color.parseColor("#999999"))
                }
                binding.switchMode.thumbTintList = ColorStateList.valueOf(Color.parseColor("#1A1A1A"))
                binding.switchMode.trackTintList = ColorStateList.valueOf(Color.parseColor("#CCCCCC"))
            }
            AppTheme.VINTAGE_Y2K -> {
                if (isPro) {
                    binding.tvModeAuto.setTextColor(Color.parseColor("#8A857C"))
                    binding.tvModePro.setTextColor(Color.parseColor("#FF9F1C"))
                } else {
                    binding.tvModeAuto.setTextColor(Color.parseColor("#FF9F1C"))
                    binding.tvModePro.setTextColor(Color.parseColor("#8A857C"))
                }
                binding.switchMode.thumbTintList = ColorStateList.valueOf(Color.parseColor("#FF9F1C"))
                binding.switchMode.trackTintList = ColorStateList.valueOf(Color.parseColor("#DED9CE"))
            }
        }
    }
}
