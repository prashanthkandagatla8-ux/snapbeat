package com.kiro.snapbeat

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import kotlinx.coroutines.delay
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.util.concurrent.TimeUnit

class RenderQueueWorker(
    private val appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    companion object {
        const val TAG = "snapbeat_render"
        const val CHANNEL_ID = "snapbeat_render_channel"
        const val NOTIFICATION_ID = 2026
        const val NOTIFICATION_COMPLETE_ID = 2027

        const val KEY_JOB_DIR = "job_dir"
        const val KEY_SERVER_URL = "server_url"
        const val KEY_QUALITY = "quality"
        const val KEY_TEMPLATE = "template"
        const val KEY_DROP_IT = "drop_it"
        const val KEY_FRAME = "frame"
        const val KEY_TITLE_TEXT = "title_text"
        const val KEY_TITLE_BG = "title_bg"
        const val KEY_TITLE_DURATION = "title_duration"
        const val KEY_TITLE_FONT = "title_font"
        const val KEY_TITLE_STYLE = "title_style"
        const val KEY_TITLE_FRAME = "title_frame"
        const val KEY_FULL_TRACK = "full_track"
        const val KEY_AUDIO_START = "audio_start"
        const val KEY_AUDIO_END = "audio_end"
        const val KEY_AUTO_ARRANGE = "auto_arrange"

        const val OUTPUT_VIDEO_URI = "output_video_uri"
        const val OUTPUT_JOB_ID = "output_job_id"
    }

    private val notificationManager =
        appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private val client = OkHttpClient.Builder()
        .connectTimeout(5, TimeUnit.MINUTES)
        .writeTimeout(5, TimeUnit.MINUTES)
        .readTimeout(5, TimeUnit.MINUTES)
        .build()

    override suspend fun getForegroundInfo(): ForegroundInfo {
        createNotificationChannel()
        val notification = buildProgressNotification("SnapBeat Background Render", "Queued...", 0, true)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ForegroundInfo(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            ForegroundInfo(NOTIFICATION_ID, notification)
        }
    }

    override suspend fun doWork(): Result {
        createNotificationChannel()
        setForeground(getForegroundInfo())

        val jobDirPath = inputData.getString(KEY_JOB_DIR)
            ?: return Result.failure(workDataOf("error" to "Missing job directory"))
        val jobDir = File(jobDirPath)
        if (!jobDir.exists() || !jobDir.isDirectory) {
            return Result.failure(workDataOf("error" to "Job directory not found"))
        }

        val serverUrl = inputData.getString(KEY_SERVER_URL) ?: BuildConfig.SERVER_URL
        var jobId: String? = null

        try {
            // 1. Prepare files for upload
            val musicFile = jobDir.listFiles { f -> f.name.startsWith("music") }?.firstOrNull()
                ?: throw IOException("Music file not found in job bundle")
            val photoFiles = jobDir.listFiles { f -> f.name.startsWith("photo_") }
                ?.sortedBy { f ->
                    val num = f.nameWithoutExtension.removePrefix("photo_").toIntOrNull() ?: 0
                    num
                } ?: emptyList()

            if (photoFiles.isEmpty()) throw IOException("No photos found in job bundle")

            updateNotification("Uploading ${photoFiles.size} photos and music...", 5, true)
            setProgress(workDataOf("stage" to "Uploading...", "progress" to 5))

            // 2. Build multipart body
            val builder = MultipartBody.Builder().setType(MultipartBody.FORM)
            builder.addFormDataPart(
                "audio",
                musicFile.name,
                musicFile.asRequestBody("audio/*".toMediaTypeOrNull())
            )

            photoFiles.forEach { photoFile ->
                builder.addFormDataPart(
                    "photos",
                    photoFile.name,
                    photoFile.asRequestBody("image/*".toMediaTypeOrNull())
                )
            }

            // Options
            val quality = inputData.getString(KEY_QUALITY) ?: "fast"
            builder.addFormDataPart("quality", quality)

            val autoArrange = inputData.getString(KEY_AUTO_ARRANGE) ?: "auto"
            builder.addFormDataPart("auto_arrange", autoArrange)

            val template = inputData.getString(KEY_TEMPLATE)
            if (!template.isNullOrEmpty()) {
                builder.addFormDataPart("template", template)
            }

            if (inputData.getBoolean(KEY_DROP_IT, false)) {
                builder.addFormDataPart("drop_it", "true")
            }

            val frame = inputData.getString(KEY_FRAME) ?: "portrait"
            builder.addFormDataPart("frame", frame)

            val titleText = inputData.getString(KEY_TITLE_TEXT) ?: ""
            if (titleText.isNotEmpty()) {
                builder.addFormDataPart("title_text", titleText)
                builder.addFormDataPart("title_bg", inputData.getString(KEY_TITLE_BG) ?: "black")
                builder.addFormDataPart("title_duration", inputData.getString(KEY_TITLE_DURATION) ?: "2")
                builder.addFormDataPart("title_font", inputData.getString(KEY_TITLE_FONT) ?: "impact")
                builder.addFormDataPart("title_style", inputData.getString(KEY_TITLE_STYLE) ?: "classic")
                builder.addFormDataPart("title_frame", inputData.getString(KEY_TITLE_FRAME) ?: "none")
            }

            val fullTrack = inputData.getBoolean(KEY_FULL_TRACK, true)
            if (fullTrack) {
                builder.addFormDataPart("full_track", "true")
                builder.addFormDataPart("audio_start", "0")
                builder.addFormDataPart("audio_end", "0")
            } else {
                builder.addFormDataPart("full_track", "false")
                builder.addFormDataPart("audio_start", inputData.getInt(KEY_AUDIO_START, 0).toString())
                builder.addFormDataPart("audio_end", inputData.getInt(KEY_AUDIO_END, 0).toString())
            }

            // 3. Post to server
            val renderRequest = Request.Builder()
                .url("$serverUrl/api/render/mobile")
                .post(builder.build())
                .build()

            client.newCall(renderRequest).execute().use { response ->
                if (!response.isSuccessful) throw IOException("Server upload failed: ${response.code}")
                val bodyStr = response.body?.string() ?: "{}"
                val json = JSONObject(bodyStr)
                if (!json.has("job_id")) throw IOException("Server returned no job_id: $bodyStr")
                jobId = json.getString("job_id")
            }

            val compositeId = jobId ?: throw IOException("Invalid job ID")

            // 4. Poll status until complete
            var isDone = false
            var pollCount = 0
            val maxPolls = 600

            while (!isDone && pollCount < maxPolls) {
                delay(1500)
                pollCount++

                val statusRequest = Request.Builder()
                    .url("$serverUrl/api/render/status/$compositeId")
                    .get()
                    .build()

                try {
                    client.newCall(statusRequest).execute().use { response ->
                        if (!response.isSuccessful) return@use
                        val bodyStr = response.body?.string() ?: "{}"
                        val json = JSONObject(bodyStr)
                        val status = json.optString("status", "")
                        val stage = json.optString("stage", "processing")
                        val progress = json.optInt("progress", 0)

                        updateNotification("${stage.uppercase()} - $progress%", progress, false)
                        setProgress(
                            workDataOf(
                                "status" to status,
                                "stage" to stage,
                                "progress" to progress,
                                "job_id" to compositeId
                            )
                        )

                        if (status == "done") {
                            isDone = true
                        } else if (status == "failed" || status == "cancelled") {
                            val errorMsg = json.optString("error", "Unknown render error")
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

            // 5. Download video with delete_after=true and byte-level progress
            updateNotification("Downloading video to Gallery...", 95, true)
            setProgress(workDataOf("stage" to "Downloading video...", "progress" to 95, "job_id" to compositeId))

            val downloadRequest = Request.Builder()
                .url("$serverUrl/api/render/download/$compositeId?delete_after=true")
                .get()
                .build()

            var savedUri: Uri? = null

            client.newCall(downloadRequest).execute().use { response ->
                if (!response.isSuccessful) throw IOException("Download failed with code: ${response.code}")
                val body = response.body ?: throw IOException("Empty response body")
                val totalBytes = body.contentLength()
                val inputStream = body.byteStream()

                val values = ContentValues().apply {
                    put(MediaStore.Video.Media.DISPLAY_NAME, "SnapBeat_${compositeId}.mp4")
                    put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/SnapBeat")
                        put(MediaStore.Video.Media.IS_PENDING, 1)
                    }
                }

                val uri = appContext.contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
                    ?: throw IOException("Failed to create MediaStore entry")

                var downloadSuccess = false
                try {
                    appContext.contentResolver.openOutputStream(uri)?.use { out ->
                        val buffer = ByteArray(8192)
                        var bytesRead: Int
                        var downloadedBytes = 0L
                        var lastReportedPct = -1

                        while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                            out.write(buffer, 0, bytesRead)
                            downloadedBytes += bytesRead
                            if (totalBytes > 0) {
                                val pct = ((downloadedBytes * 100) / totalBytes).toInt().coerceIn(0, 100)
                                if (pct != lastReportedPct && pct % 5 == 0) {
                                    lastReportedPct = pct
                                    val currentMB = downloadedBytes / (1024.0 * 1024.0)
                                    val totalMB = totalBytes / (1024.0 * 1024.0)
                                    updateNotification(
                                        String.format("Downloading: %d%% (%.1f MB / %.1f MB)", pct, currentMB, totalMB),
                                        pct,
                                        false
                                    )
                                    setProgress(workDataOf("stage" to "Downloading ($pct%)", "progress" to pct))
                                }
                            }
                        }
                    }
                    downloadSuccess = true
                    savedUri = uri
                } finally {
                    if (!downloadSuccess) {
                        appContext.contentResolver.delete(uri, null, null)
                    }
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    values.clear()
                    values.put(MediaStore.Video.Media.IS_PENDING, 0)
                    appContext.contentResolver.update(uri, values, null, null)
                }
            }

            // 6. Clean up temporary local files
            jobDir.deleteRecursively()

            // 7. Show completion notification with tap-to-view action
            savedUri?.let { uri ->
                showCompletionNotification(uri, compositeId)
            }

            return Result.success(
                workDataOf(
                    OUTPUT_VIDEO_URI to (savedUri?.toString() ?: ""),
                    OUTPUT_JOB_ID to compositeId
                )
            )

        } catch (e: Exception) {
            e.printStackTrace()
            // Clean up temporary local files
            jobDir.deleteRecursively()

            // Attempt server cleanup if we had a jobId
            jobId?.let { id ->
                try {
                    val cleanupReq = Request.Builder()
                        .url("$serverUrl/api/render/cleanup/$id")
                        .post(ByteArray(0).toRequestBody(null))
                        .build()
                    client.newCall(cleanupReq).execute().close()
                } catch (_: Exception) {}
            }

            showErrorNotification(e.message ?: "Render failed")
            return Result.failure(workDataOf("error" to (e.message ?: "Render failed")))
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "SnapBeat Background Renders",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows progress of background video rendering and downloading"
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun buildProgressNotification(
        title: String,
        content: String,
        progress: Int,
        indeterminate: Boolean
    ): Notification {
        val launchIntent = appContext.packageManager.getLaunchIntentForPackage(appContext.packageName)
        val pendingIntent = PendingIntent.getActivity(
            appContext,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        return NotificationCompat.Builder(appContext, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setProgress(100, progress, indeterminate)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun updateNotification(content: String, progress: Int, indeterminate: Boolean) {
        val notification = buildProgressNotification("SnapBeat: Background Render", content, progress, indeterminate)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun showCompletionNotification(videoUri: Uri, jobId: String) {
        notificationManager.cancel(NOTIFICATION_ID)

        val intent = Intent(appContext, PreviewActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(PreviewActivity.EXTRA_VIDEO_URI, videoUri.toString())
        }
        val pendingIntent = PendingIntent.getActivity(
            appContext,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(appContext, CHANNEL_ID)
            .setContentTitle("SnapBeat Video Ready! 🎬")
            .setContentText("Your video has been saved to your Gallery. Tap to watch!")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        notificationManager.notify(NOTIFICATION_COMPLETE_ID, notification)
    }

    private fun showErrorNotification(errorMsg: String) {
        notificationManager.cancel(NOTIFICATION_ID)
        val notification = NotificationCompat.Builder(appContext, CHANNEL_ID)
            .setContentTitle("SnapBeat: Render Failed ⚠️")
            .setContentText(errorMsg)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(NOTIFICATION_COMPLETE_ID, notification)
    }
}
