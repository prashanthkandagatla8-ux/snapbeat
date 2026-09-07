package com.kiro.snapbeat

import android.content.Intent
import android.os.Bundle
import android.view.animation.AlphaAnimation
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import android.os.Handler
import android.os.Looper

class SplashActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        window.statusBarColor = android.graphics.Color.parseColor("#1A1A1A")
        window.navigationBarColor = android.graphics.Color.parseColor("#1A1A1A")

        val icon = findViewById<ImageView>(R.id.ivSplashIcon)
        val title = findViewById<TextView>(R.id.tvSplashTitle)
        val tagline = findViewById<TextView>(R.id.tvSplashTagline)

        val fadeIn = AlphaAnimation(0f, 1f).apply {
            duration = 800
            fillAfter = true
        }

        icon.startAnimation(fadeIn)

        Handler(Looper.getMainLooper()).postDelayed({
            title.startAnimation(AlphaAnimation(0f, 1f).apply {
                duration = 600
                fillAfter = true
            })
        }, 300)

        Handler(Looper.getMainLooper()).postDelayed({
            tagline.startAnimation(AlphaAnimation(0f, 1f).apply {
                duration = 600
                fillAfter = true
            })
        }, 600)

        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, 1800)
    }
}
