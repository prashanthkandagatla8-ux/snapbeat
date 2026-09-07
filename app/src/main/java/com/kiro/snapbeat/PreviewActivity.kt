package com.kiro.snapbeat

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.MediaController
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.kiro.snapbeat.databinding.ActivityPreviewBinding

class PreviewActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPreviewBinding
    private var videoUri: Uri? = null

    companion object {
        const val EXTRA_VIDEO_URI = "extra_video_uri"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPreviewBinding.inflate(layoutInflater)
        setContentView(binding.root)

        window.statusBarColor = android.graphics.Color.parseColor("#1A1A1A")
        window.navigationBarColor = android.graphics.Color.parseColor("#1A1A1A")

        val uriString = intent.getStringExtra(EXTRA_VIDEO_URI)
        if (uriString.isNullOrEmpty()) {
            Toast.makeText(this, "No video to preview", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        videoUri = Uri.parse(uriString)

        setupPlayer()
        setupActions()
    }

    private fun setupPlayer() {
        val uri = videoUri ?: return

        binding.previewVideoView.setVideoURI(uri)
        val mediaController = MediaController(this)
        mediaController.setAnchorView(binding.previewVideoView)
        binding.previewVideoView.setMediaController(mediaController)

        binding.previewVideoView.setOnPreparedListener { mediaPlayer ->
            mediaPlayer.isLooping = true
            binding.previewVideoView.start()
        }

        binding.previewVideoView.setOnErrorListener { _, _, _ ->
            Toast.makeText(this, "Playback error", Toast.LENGTH_SHORT).show()
            true
        }
    }

    private fun setupActions() {
        binding.btnBack.setOnClickListener {
            finish()
        }

        binding.btnNewVideo.setOnClickListener {
            finish()
        }

        binding.btnShareVideo.setOnClickListener {
            val uri = videoUri ?: return@setOnClickListener
            try {
                val shareIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "video/mp4"
                    putExtra(Intent.EXTRA_STREAM, uri)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                startActivity(Intent.createChooser(shareIntent, "Share your SnapBeat"))
            } catch (e: Exception) {
                Toast.makeText(this, "Could not share video: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onPause() {
        super.onPause()
        if (binding.previewVideoView.isPlaying) {
            binding.previewVideoView.pause()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        binding.previewVideoView.stopPlayback()
    }
}
