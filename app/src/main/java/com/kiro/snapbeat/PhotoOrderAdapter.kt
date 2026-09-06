package com.kiro.snapbeat

import android.content.Context
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import java.util.Collections

class PhotoOrderAdapter(
    private var photos: MutableList<Uri>,
    private val context: Context
) : RecyclerView.Adapter<PhotoOrderAdapter.ViewHolder>() {

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val ivThumb: ImageView = view.findViewById(R.id.ivThumb)
        val tvIndex: TextView = view.findViewById(R.id.tvIndex)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_photo_thumb, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val uri = photos[position]
        Glide.with(context)
            .load(uri)
            .override(160, 160)
            .centerCrop()
            .into(holder.ivThumb)
            
        holder.tvIndex.text = (position + 1).toString()
    }

    override fun getItemCount() = photos.size

    fun moveItem(from: Int, to: Int) {
        if (from < to) {
            for (i in from until to) {
                Collections.swap(photos, i, i + 1)
            }
        } else {
            for (i in from downTo to + 1) {
                Collections.swap(photos, i, i - 1)
            }
        }
        notifyItemMoved(from, to)
    }

    fun getOrderedPhotos(): List<Uri> {
        return photos.toList()
    }
}