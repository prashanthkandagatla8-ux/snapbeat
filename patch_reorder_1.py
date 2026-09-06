import os
from pathlib import Path
import re

app_dir = Path(r"C:\MyProjects\SnapBeat\app")
src_main = app_dir / "src" / "main"
res_layout = src_main / "res" / "layout"
res_drawable = src_main / "res" / "drawable"
kt_package = src_main / "java" / "com" / "kiro" / "snapbeat"

# 1. build.gradle
build_gradle = app_dir / "build.gradle"
bg_content = build_gradle.read_text(encoding="utf-8")
if "bumptech.glide" not in bg_content:
    bg_content = bg_content.replace("implementation 'com.squareup.okhttp3:okhttp:4.12.0'", 
        "implementation 'com.squareup.okhttp3:okhttp:4.12.0'\n    implementation 'com.github.bumptech.glide:glide:4.16.0'")
    build_gradle.write_text(bg_content, encoding="utf-8")
    print("Patched build.gradle")

# 2. activity_main.xml
activity_main = res_layout / "activity_main.xml"
am_content = activity_main.read_text(encoding="utf-8")
rv_xml = """
        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvPhotoOrder"
            android:layout_width="0dp"
            android:layout_height="100dp"
            android:layout_marginTop="12dp"
            android:clipToPadding="false"
            android:paddingStart="4dp"
            android:paddingEnd="4dp"
            android:visibility="gone"
            android:overScrollMode="never"
            app:layout_constraintTop_toBottomOf="@+id/tvPhotosStatus"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent" />
"""
if "rvPhotoOrder" not in am_content:
    target = 'app:layout_constraintStart_toStartOf="parent" />'
    parts = am_content.split('id="@+id/tvPhotosStatus"')
    if len(parts) == 2:
        part2 = parts[1]
        insert_idx = part2.find(target) + len(target)
        new_am = parts[0] + 'id="@+id/tvPhotosStatus"' + part2[:insert_idx] + rv_xml + part2[insert_idx:]
        activity_main.write_text(new_am, encoding="utf-8")
        print("Patched activity_main.xml")

# 3. item_photo_thumb.xml
(res_layout / "item_photo_thumb.xml").write_text("""<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="88dp"
    android:layout_height="88dp"
    android:padding="4dp">

    <ImageView
        android:id="@+id/ivThumb"
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:scaleType="centerCrop"
        android:background="@drawable/thumb_border" />

    <TextView
        android:id="@+id/tvIndex"
        android:layout_width="20dp"
        android:layout_height="20dp"
        android:layout_gravity="start|top"
        android:gravity="center"
        android:background="@drawable/badge_circle"
        android:textColor="#FFFFFF"
        android:textSize="11sp"
        android:textStyle="bold" />
</FrameLayout>""", encoding="utf-8")

# 4. thumb_border.xml
res_drawable.mkdir(exist_ok=True, parents=True)
(res_drawable / "thumb_border.xml").write_text("""<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#EEEEEE" />
    <stroke android:width="2dp" android:color="#000000" />
    <corners android:radius="8dp" />
</shape>""", encoding="utf-8")

# 5. badge_circle.xml
(res_drawable / "badge_circle.xml").write_text("""<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#FF69B4" />
</shape>""", encoding="utf-8")

# 6. PhotoOrderAdapter.kt
(kt_package / "PhotoOrderAdapter.kt").write_text("""package com.kiro.snapbeat

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
}""", encoding="utf-8")

print("Created XML files and PhotoOrderAdapter.kt")

