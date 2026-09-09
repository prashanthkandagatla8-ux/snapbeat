package com.kiro.snapbeat

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

class QueueJobManager(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("snapbeat_queue_ledger", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_JOBS = "saved_render_jobs"
    }

    @Synchronized
    fun getJobs(): MutableList<QueueJob> {
        val jsonStr = prefs.getString(KEY_JOBS, null) ?: return mutableListOf()
        val list = mutableListOf<QueueJob>()
        try {
            val arr = JSONArray(jsonStr)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                list.add(QueueJob.fromJson(obj))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return list
    }

    @Synchronized
    fun saveJobs(jobs: List<QueueJob>) {
        val arr = JSONArray()
        jobs.forEach { arr.put(it.toJson()) }
        prefs.edit().putString(KEY_JOBS, arr.toString()).apply()
    }

    @Synchronized
    fun addOrUpdateJob(job: QueueJob) {
        val jobs = getJobs()
        val existingIndex = jobs.indexOfFirst { it.id == job.id }
        if (existingIndex >= 0) {
            jobs[existingIndex] = job
        } else {
            jobs.add(0, job) // newest first
        }
        saveJobs(jobs)
    }

    @Synchronized
    fun updateJobStatus(id: String, status: String, videoUri: String? = null) {
        val jobs = getJobs()
        val existing = jobs.find { it.id == id }
        if (existing != null) {
            existing.status = status
            if (videoUri != null) {
                existing.videoUri = videoUri
            }
            saveJobs(jobs)
        }
    }

    @Synchronized
    fun toggleFavourite(id: String): Boolean {
        val jobs = getJobs()
        val existing = jobs.find { it.id == id } ?: return false
        existing.isFavourite = !existing.isFavourite
        saveJobs(jobs)
        return existing.isFavourite
    }

    @Synchronized
    fun deleteJob(id: String) {
        val jobs = getJobs()
        jobs.removeAll { it.id == id }
        saveJobs(jobs)
    }

    @Synchronized
    fun clearAll() {
        // Clear all non-favourite or clear all entirely
        prefs.edit().remove(KEY_JOBS).apply()
    }
}
