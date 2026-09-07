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
            binding.tvPhotosStatus.text = "${selectedPhotos.size} photos loaded (Max 60)"
            refreshPhotoOrder()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val templates = arrayOf("Beat Cut", "Bounce", "Cine Zoom", "Fade", "Glide", "Mosaic Flow", "Mosaic Pulse", "Pendulum", "Pendulum OG", "Pulse", "Punch", "Reveal Bounce", "Reveal Boxes", "Reveal Circles", "Reveal Grid", "Reveal Spiral", "Slide", "Slow Drift", "Spin", "Sway", "Whip", "Zoom Out")
        val adapter = android.widget.ArrayAdapter(this, R.layout.spinner_item, templates)
        adapter.setDropDownViewResource(R.layout.spinner_dropdown_item)
        binding.spinnerTemplate.adapter = adapter

        // Aspect ratio spinner setup
        val aspectRatios = arrayOf("Portrait (9:16)", "Landscape (16:9)", "Square (1:1)")
        binding.spinnerAspectRatio.adapter = android.widget.ArrayAdapter(
            this, R.layout.spinner_item, aspectRatios
        ).apply { setDropDownViewResource(R.layout.spinner_dropdown_item) }

        // Title Card Designer Spinners
        val titleFonts = arrayOf("Bold Blockbuster (Impact)", "Elegant Serif (Georgia)", "Modern Minimal (Clean)", "Vintage Typewriter", "Casual Retro (Playful)")
        binding.spinnerTitleFont.adapter = android.widget.ArrayAdapter(
            this, R.layout.spinner_item, titleFonts
        ).apply { setDropDownViewResource(R.layout.spinner_dropdown_item) }

        val titleStyles = arrayOf("Classic Yellow Drop-Shadow", "Neon Glow (Electric Cyan)", "3D Retro Arcade Extrusion", "Cinematic All-Caps", "Badge Tag Container")
        binding.spinnerTitleStyle.adapter = android.widget.ArrayAdapter(
            this, R.layout.spinner_item, titleStyles
        ).apply { setDropDownViewResource(R.layout.spinner_dropdown_item) }

        val titleFrames = arrayOf("None (Borderless)", "Cinematic Box Border", "Viewfinder Camera Corners", "Retro Double Border", "Film Letterbox Bars")
        binding.spinnerTitleFrame.adapter = android.widget.ArrayAdapter(
            this, R.layout.spinner_item, titleFrames
        ).apply { setDropDownViewResource(R.layout.spinner_dropdown_item) }

        // Live preview listeners
        val previewWatcher = object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                updateLiveTitlePreview()
            }
            override fun afterTextChanged(s: Editable?) {}
        }
        binding.etTitleText.addTextChangedListener(previewWatcher)
        binding.etTitleBgColor.addTextChangedListener(previewWatcher)

        val spinnerListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                updateLiveTitlePreview()
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
        binding.spinnerTitleFont.onItemSelectedListener = spinnerListener
        binding.spinnerTitleStyle.onItemSelectedListener = spinnerListener
        binding.spinnerTitleFrame.onItemSelectedListener = spinnerListener

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
            if (isChecked) {
                // Right position = PRO
                binding.tvModeBasic.setTextColor(android.graphics.Color.parseColor("#666666"))
                binding.tvModePro.setTextColor(android.graphics.Color.parseColor("#FFE14D"))
                binding.proModeContainer.visibility = View.VISIBLE
            } else {
                // Left position = BASIC
                binding.tvModeBasic.setTextColor(android.graphics.Color.parseColor("#FFE14D"))
                binding.tvModePro.setTextColor(android.graphics.Color.parseColor("#666666"))
                binding.proModeContainer.visibility = View.GONE
            }
            if (selectedPhotos.isNotEmpty()) {
                binding.rvPhotoOrder.visibility = View.VISIBLE
            }
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
                }

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
                    .url(BuildConfig.SERVER_URL + "/api/render/mobile") 
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
                    .url(BuildConfig.SERVER_URL + "/api/render/status/$jobId")
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
                        // Fix: Use a custom exception so the catch block below
                        // does NOT swallow explicit server failures
                        throw RuntimeException("Render failed: $errorMsg")
                    }
                }
            } catch (e: RuntimeException) {
                // Server explicitly said "failed" — surface immediately, don't retry
                throw e
            } catch (e: IOException) {
                // Transient network error — retry up to 3 in a row before giving up
                if (pollCount % 3 != 0) continue else throw e
            }
        }

        if (pollCount >= maxPolls) throw IOException("Render timed out")

        withContext(Dispatchers.Main) {
            binding.progressBar.isIndeterminate = true
            binding.tvStatus.text = "DOWNLOADING VIDEO..."
        }

        val downloadRequest = Request.Builder()
            .url(BuildConfig.SERVER_URL + "/api/render/download/$jobId")
            .get()
            .build()

        client.newCall(downloadRequest).execute().use { response ->
            if (!response.isSuccessful) throw IOException("Download failed")
            val inputStream = response.body?.byteStream() ?: throw IOException("Empty response")
            
            val values = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, "SnapBeat_${jobId}.mp4")
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                // Fix: RELATIVE_PATH only exists on API 29+
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
                    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                        out.write(buffer, 0, bytesRead)
                    }
                }
                downloadSuccess = true
            } finally {
                if (!downloadSuccess) {
                    // Clean up partial MediaStore entry on failure
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
}
