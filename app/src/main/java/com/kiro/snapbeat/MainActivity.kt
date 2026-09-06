package com.kiro.snapbeat

import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
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
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.ItemTouchHelper

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private var selectedMusicUri: Uri? = null
    private var selectedPhotos = mutableListOf<Uri>()
    private lateinit var photoOrderAdapter: PhotoOrderAdapter
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(5, TimeUnit.MINUTES)
        .writeTimeout(5, TimeUnit.MINUTES)
        .readTimeout(5, TimeUnit.MINUTES)
        .build()

    private val musicPicker = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        uri?.let {
            selectedMusicUri = it
            binding.tvMusicStatus.text = "1 tape selected"
        }
    }

    private val photosPicker = registerForActivityResult(ActivityResultContracts.GetMultipleContents()) { uris ->
        if (uris.isNotEmpty()) {
            selectedPhotos.clear()
            selectedPhotos.addAll(uris.take(60))
            binding.tvPhotosStatus.text = "${selectedPhotos.size} photos loaded (Max 60)"
            if (!binding.switchMode.isChecked) {
                setupPhotoOrderRecyclerView()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val templates = arrayOf("Pendulum", "Glide", "Sway", "Punch", "Mosaic Reveal", "Spin", "Pulse", "Whip", "Slow Drift", "Auto (Beat Cut)")
        val adapter = android.widget.ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, templates)
        binding.spinnerTemplate.adapter = adapter

        binding.switchMode.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                binding.switchMode.text = "BASIC"
                binding.proModeContainer.visibility = android.view.View.GONE
                binding.rvPhotoOrder.visibility = android.view.View.GONE
            } else {
                binding.switchMode.text = "PRO"
                binding.proModeContainer.visibility = android.view.View.VISIBLE
                if (selectedPhotos.isNotEmpty()) {
                    setupPhotoOrderRecyclerView()
                }
            }
        }

        binding.btnSelectMusic.setOnClickListener {
            musicPicker.launch("audio/*")
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
    }

    private fun setupPhotoOrderRecyclerView() {
        photoOrderAdapter = PhotoOrderAdapter(selectedPhotos, this)
        binding.rvPhotoOrder.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        binding.rvPhotoOrder.adapter = photoOrderAdapter
        binding.rvPhotoOrder.visibility = View.VISIBLE

        val callback = object : ItemTouchHelper.SimpleCallback(ItemTouchHelper.LEFT or ItemTouchHelper.RIGHT, 0) {
            override fun onMove(rv: RecyclerView, source: RecyclerView.ViewHolder, target: RecyclerView.ViewHolder): Boolean {
                photoOrderAdapter.moveItem(source.adapterPosition, target.adapterPosition)
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
        ItemTouchHelper(callback).attachToRecyclerView(binding.rvPhotoOrder)
    }

    private fun getFileFromUri(uri: Uri, prefix: String): File? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val ext = if (prefix.startsWith("music")) ".mp3" else ".jpg"
            val file = File(cacheDir, "${prefix}_${System.currentTimeMillis()}${ext}")
            val outputStream = FileOutputStream(file)
            inputStream.copyTo(outputStream)
            inputStream.close()
            outputStream.close()
            file
        } catch (e: Exception) {
            null
        }
    }

    private fun clearCache() {
        cacheDir.listFiles()?.forEach { file ->
            if (file.name.startsWith("music_") || file.name.startsWith("photo_")) {
                file.delete()
            }
        }
    }

    private fun uploadAndRender() {
        binding.progressBar.visibility = View.VISIBLE
        binding.progressBar.isIndeterminate = true
        binding.tvStatus.text = "Uploading to SnapBeat Lab..."
        binding.btnRender.isEnabled = false

        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val builder = MultipartBody.Builder().setType(MultipartBody.FORM)

                val musicFile = getFileFromUri(selectedMusicUri!!, "music") 
                    ?: throw IOException("Could not read music file")
                builder.addFormDataPart("audio", musicFile.name, musicFile.asRequestBody("audio/*".toMediaTypeOrNull()))

                val photosToUpload = if (!binding.switchMode.isChecked && ::photoOrderAdapter.isInitialized) {
                    photoOrderAdapter.getOrderedPhotos()
                } else {
                    selectedPhotos
                }

                photosToUpload.forEachIndexed { index, uri ->
                    val photoFile = getFileFromUri(uri, "photo_$index") 
                        ?: throw IOException("Could not read photo $index")
                    builder.addFormDataPart("photos", photoFile.name, photoFile.asRequestBody("image/*".toMediaTypeOrNull()))
                }

                if (!binding.switchMode.isChecked) {
                    val selection = binding.spinnerTemplate.selectedItem.toString()
                    val templateName = when(selection) {
                        "Pendulum" -> "pendulum"
                        "Glide" -> "glide-pan"
                        "Sway" -> "sway-ballad"
                        "Punch" -> "punch-cut"
                        "Mosaic Reveal" -> "reveal-tiles"
                        "Spin" -> "beat-spin"
                        "Pulse" -> "beat-pulse"
                        "Whip" -> "beat-whip"
                        "Slow Drift" -> "slow-drift"
                        "Auto (Beat Cut)" -> "beat-cut"
                        else -> "simple"
                    }
                    builder.addFormDataPart("template", templateName)
                }

                val requestBody = builder.build()
                val request = Request.Builder()
                    .url(BuildConfig.SERVER_URL + "/api/render/mobile") 
                    .post(requestBody)
                    .build()

                withContext(Dispatchers.Main) { 
                    binding.tvStatus.text = "Uploading..." 
                }

                var jobId: Int = -1
                client.newCall(request).execute().use { response ->
                    if (!response.isSuccessful) throw IOException("Upload failed: $response")
                    val bodyString = response.body?.string() ?: ""
                    val json = JSONObject(bodyString)
                    jobId = json.getInt("job_id")
                }
                
                clearCache()
                pollStatusAndDownload(jobId)

            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    binding.progressBar.visibility = View.GONE
                    binding.tvStatus.text = "Error: ${e.message}"
                    binding.btnRender.isEnabled = true
                }
                clearCache()
            }
        }
    }

    private suspend fun pollStatusAndDownload(jobId: Int) {
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
                    val bodyString = response.body?.string() ?: ""
                    val json = JSONObject(bodyString)
                    val status = json.getString("status")
                    val stage = json.getString("stage")
                    val progress = json.getInt("progress")

                    withContext(Dispatchers.Main) {
                        binding.tvStatus.text = "${stage.uppercase()} - $progress%"
                        binding.progressBar.progress = progress
                    }

                    if (status == "done") {
                        isDone = true
                    } else if (status == "failed" || status == "cancelled") {
                        val errorMsg = json.optString("error", "Unknown error")
                        throw IOException("Server Render Failed: $errorMsg")
                    }
                }
            } catch (e: IOException) {
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
                put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/SnapBeat")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Video.Media.IS_PENDING, 1)
                }
            }
            
            val uri = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Failed to create MediaStore entry")
                
            contentResolver.openOutputStream(uri)?.use { out ->
                val buffer = ByteArray(8192)
                var bytesRead: Int
                while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                    out.write(buffer, 0, bytesRead)
                }
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                values.clear()
                values.put(MediaStore.Video.Media.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
            }
            
            withContext(Dispatchers.Main) {
                binding.progressBar.visibility = View.GONE
                binding.tvStatus.text = "VIDEO EXPORTED! Check your gallery."
                binding.btnRender.isEnabled = true
                
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "video/mp4")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                try { startActivity(intent) } catch (e: Exception) {}
            }
        }
    }
}
