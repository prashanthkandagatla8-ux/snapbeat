package com.kiro.snapbeat

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
    private var photos: MutableList<Uri>
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
        // Fix: Use holder.itemView.context instead of storing Activity reference
        Glide.with(holder.itemView.context)
            .load(uri)
            .override(160, 160)
            .centerCrop()
            .error(android.R.drawable.ic_menu_gallery)
            .into(holder.ivThumb)
            
        holder.tvIndex.text = (position + 1).toString()
    }

    override fun getItemCount() = photos.size

    fun moveItem(from: Int, to: Int) {
        // Fix: Bounds check to prevent IndexOutOfBoundsException
        if (from < 0 || to < 0 || from >= photos.size || to >= photos.size) return
        if (from == to) return

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