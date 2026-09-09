package com.kiro.snapbeat

import org.json.JSONObject

data class QueueJob(
    val id: String,
    val title: String,
    var videoUri: String? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val templateName: String = "Beat Cut",
    val quality: String = "fast",
    val aspectRatio: String = "portrait",
    var status: String = "QUEUED", // QUEUED, RENDERING, COMPLETED, FAILED
    var isFavourite: Boolean = false,
    val isInstant: Boolean = false
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("id", id)
            put("title", title)
            put("videoUri", videoUri ?: "")
            put("timestamp", timestamp)
            put("templateName", templateName)
            put("quality", quality)
            put("aspectRatio", aspectRatio)
            put("status", status)
            put("isFavourite", isFavourite)
            put("isInstant", isInstant)
        }
    }

    companion object {
        fun fromJson(json: JSONObject): QueueJob {
            val uriStr = json.optString("videoUri", "")
            return QueueJob(
                id = json.optString("id", System.currentTimeMillis().toString()),
                title = json.optString("title", "SnapBeat Video"),
                videoUri = if (uriStr.isEmpty()) null else uriStr,
                timestamp = json.optLong("timestamp", System.currentTimeMillis()),
                templateName = json.optString("templateName", "Beat Cut"),
                quality = json.optString("quality", "fast"),
                aspectRatio = json.optString("aspectRatio", "portrait"),
                status = json.optString("status", "COMPLETED"),
                isFavourite = json.optBoolean("isFavourite", false),
                isInstant = json.optBoolean("isInstant", false)
            )
        }
    }
}
