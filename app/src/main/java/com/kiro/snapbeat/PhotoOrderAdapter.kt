package com.kiro.snapbeat

import android.net.Uri
import android.view.LayoutInflater
import android.view.MotionEvent
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
        val btnMoveLeft: TextView = view.findViewById(R.id.btnMoveLeft)
        val btnMoveRight: TextView = view.findViewById(R.id.btnMoveRight)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_photo_thumb, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val uri = photos[position]
        Glide.with(holder.itemView.context)
            .load(uri)
            .override(180, 180)
            .centerCrop()
            .error(android.R.drawable.ic_menu_gallery)
            .into(holder.ivThumb)

        holder.tvIndex.text = (position + 1).toString()

        // Disallow ScrollView touch interception when user touches an item
        holder.itemView.setOnTouchListener { v, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                v.parent?.requestDisallowInterceptTouchEvent(true)
            }
            false
        }

        // 1-Tap Reorder Buttons
        holder.btnMoveLeft.visibility = if (position > 0) View.VISIBLE else View.INVISIBLE
        holder.btnMoveRight.visibility = if (position < photos.size - 1) View.VISIBLE else View.INVISIBLE

        holder.btnMoveLeft.setOnClickListener {
            val currentPos = holder.adapterPosition
            if (currentPos != RecyclerView.NO_POSITION && currentPos > 0) {
                Collections.swap(photos, currentPos, currentPos - 1)
                notifyItemMoved(currentPos, currentPos - 1)
                notifyItemChanged(currentPos)
                notifyItemChanged(currentPos - 1)
            }
        }

        holder.btnMoveRight.setOnClickListener {
            val currentPos = holder.adapterPosition
            if (currentPos != RecyclerView.NO_POSITION && currentPos in 0 until photos.size - 1) {
                Collections.swap(photos, currentPos, currentPos + 1)
                notifyItemMoved(currentPos, currentPos + 1)
                notifyItemChanged(currentPos)
                notifyItemChanged(currentPos + 1)
            }
        }
    }

    override fun getItemCount() = photos.size

    fun moveItem(from: Int, to: Int) {
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