package com.kiro.snapbeat

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.widget.AppCompatButton
import androidx.recyclerview.widget.RecyclerView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class QueueJobAdapter(
    private val context: Context,
    private var jobs: MutableList<QueueJob>,
    private val onPlayClick: (QueueJob) -> Unit,
    private val onDownloadClick: (QueueJob) -> Unit,
    private val onFavouriteClick: (QueueJob) -> Unit,
    private val onDeleteClick: (QueueJob) -> Unit
) : RecyclerView.Adapter<QueueJobAdapter.JobViewHolder>() {

    class JobViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvFavStar: TextView = view.findViewById(R.id.tvJobFavStar)
        val tvTitle: TextView = view.findViewById(R.id.tvJobTitle)
        val tvStatusBadge: TextView = view.findViewById(R.id.tvJobStatusBadge)
        val tvDetails: TextView = view.findViewById(R.id.tvJobDetails)
        val tvDate: TextView = view.findViewById(R.id.tvJobDate)
        val btnPlay: AppCompatButton = view.findViewById(R.id.btnJobPlay)
        val btnDownload: AppCompatButton = view.findViewById(R.id.btnJobDownload)
        val btnDelete: AppCompatButton = view.findViewById(R.id.btnJobDelete)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): JobViewHolder {
        val view = LayoutInflater.from(context).inflate(R.layout.item_queue_job, parent, false)
        return JobViewHolder(view)
    }

    override fun onBindViewHolder(holder: JobViewHolder, position: Int) {
        val job = jobs[position]

        holder.tvTitle.text = job.title
        holder.tvFavStar.text = if (job.isFavourite) "★" else "☆"
        holder.tvFavStar.setTextColor(if (job.isFavourite) Color.parseColor("#FFE14D") else Color.parseColor("#777777"))

        val sdf = SimpleDateFormat("MMM dd HH:mm", Locale.getDefault())
        holder.tvDate.text = sdf.format(Date(job.timestamp))

        val typeLabel = if (job.isInstant) "Instant" else "Queue"
        val qualityLabel = if (job.quality == "master") "Master" else "Fast"
        holder.tvDetails.text = "${job.templateName} • ${job.aspectRatio} • $qualityLabel • $typeLabel"

        when (job.status) {
            "COMPLETED" -> {
                holder.tvStatusBadge.text = "READY ✓"
                holder.tvStatusBadge.setBackgroundResource(R.drawable.badge_pill_cyan)
                holder.tvStatusBadge.setTextColor(Color.BLACK)
                holder.btnPlay.visibility = View.VISIBLE
                holder.btnDownload.visibility = View.VISIBLE
            }
            "RENDERING", "QUEUED" -> {
                holder.tvStatusBadge.text = "PROCESSING ⏳"
                holder.tvStatusBadge.setBackgroundResource(R.drawable.badge_pill_yellow)
                holder.tvStatusBadge.setTextColor(Color.BLACK)
                holder.btnPlay.visibility = View.GONE
                holder.btnDownload.visibility = View.GONE
            }
            "FAILED" -> {
                holder.tvStatusBadge.text = "FAILED ⚠️"
                holder.tvStatusBadge.setBackgroundResource(R.drawable.badge_pill_dark)
                holder.tvStatusBadge.setTextColor(Color.parseColor("#FF4D8D"))
                holder.btnPlay.visibility = View.GONE
                holder.btnDownload.visibility = View.GONE
            }
            else -> {
                holder.tvStatusBadge.text = job.status
                holder.tvStatusBadge.setBackgroundResource(R.drawable.badge_pill_cyan)
                holder.tvStatusBadge.setTextColor(Color.BLACK)
            }
        }

        holder.tvFavStar.setOnClickListener {
            onFavouriteClick(job)
        }

        holder.btnPlay.setOnClickListener {
            onPlayClick(job)
        }

        holder.btnDownload.setOnClickListener {
            onDownloadClick(job)
        }

        holder.btnDelete.setOnClickListener {
            onDeleteClick(job)
        }
    }

    override fun getItemCount(): Int = jobs.size

    fun updateData(newJobs: List<QueueJob>) {
        jobs.clear()
        jobs.addAll(newJobs)
        notifyDataSetChanged()
    }
}
