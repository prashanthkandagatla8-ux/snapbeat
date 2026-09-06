import os
import re
from pathlib import Path

kt_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\java\com\kiro\snapbeat\MainActivity.kt")
content = kt_path.read_text(encoding="utf-8")

# 1. Add imports for RecyclerView & TouchHelper
if "import androidx.recyclerview.widget.LinearLayoutManager" not in content:
    imports = """import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.ItemTouchHelper"""
    content = content.replace("import java.util.concurrent.TimeUnit", "import java.util.concurrent.TimeUnit\n" + imports)

# 2. Add photoOrderAdapter field
if "private lateinit var photoOrderAdapter: PhotoOrderAdapter" not in content:
    content = content.replace("private var selectedPhotos = mutableListOf<Uri>()", 
        "private var selectedPhotos = mutableListOf<Uri>()\n    private lateinit var photoOrderAdapter: PhotoOrderAdapter")

# 3. Add setupPhotoOrderRecyclerView function
setup_fn = """
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
"""
if "fun setupPhotoOrderRecyclerView" not in content:
    content = content.replace("private fun getFileFromUri", setup_fn.strip() + "\n\n    private fun getFileFromUri")

# 4. Trigger setup in photosPicker
old_picker = """        if (uris.isNotEmpty()) {
            selectedPhotos.clear()
            selectedPhotos.addAll(uris.take(60))
            binding.tvPhotosStatus.text = "${selectedPhotos.size} photos loaded (Max 60)"
        }"""
new_picker = """        if (uris.isNotEmpty()) {
            selectedPhotos.clear()
            selectedPhotos.addAll(uris.take(60))
            binding.tvPhotosStatus.text = "${selectedPhotos.size} photos loaded (Max 60)"
            if (!binding.switchMode.isChecked) {
                setupPhotoOrderRecyclerView()
            }
        }"""
if old_picker in content:
    content = content.replace(old_picker, new_picker)

# 5. Handle UI visibility in switchMode
old_switch = """        binding.switchMode.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                binding.switchMode.text = "BASIC"
                binding.proModeContainer.visibility = android.view.View.GONE
            } else {
                binding.switchMode.text = "PRO"
                binding.proModeContainer.visibility = android.view.View.VISIBLE
            }
        }"""
new_switch = """        binding.switchMode.setOnCheckedChangeListener { _, isChecked ->
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
        }"""
if old_switch in content:
    content = content.replace(old_switch, new_switch)

# 6. Apply ordering in uploadAndRender
old_upload = """                selectedPhotos.forEachIndexed { index, uri ->
                    val photoFile = getFileFromUri(uri, "photo_$index") 
                        ?: throw IOException("Could not read photo $index")
                    builder.addFormDataPart("photos", photoFile.name, photoFile.asRequestBody("image/*".toMediaTypeOrNull()))
                }"""
new_upload = """                val photosToUpload = if (!binding.switchMode.isChecked && ::photoOrderAdapter.isInitialized) {
                    photoOrderAdapter.getOrderedPhotos()
                } else {
                    selectedPhotos
                }

                photosToUpload.forEachIndexed { index, uri ->
                    val photoFile = getFileFromUri(uri, "photo_$index") 
                        ?: throw IOException("Could not read photo $index")
                    builder.addFormDataPart("photos", photoFile.name, photoFile.asRequestBody("image/*".toMediaTypeOrNull()))
                }"""
if old_upload in content:
    content = content.replace(old_upload, new_upload)

kt_path.write_text(content, encoding="utf-8")
print("Patched MainActivity.kt (Step 2)")

