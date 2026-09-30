package com.sara.bellapp

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.ServiceCompat

class RingForegroundService : Service() {
    private var player: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private val stopRunnable = Runnable { stopSelf() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        RingNotification.ensureChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = RingNotification.build(this, "La otra campana está sonando")
        try {
            if (Build.VERSION.SDK_INT >= 34) {
                ServiceCompat.startForeground(
                    this,
                    RingNotification.ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
                )
            } else {
                startForeground(RingNotification.ID, notification)
            }
        } catch (_: Exception) {
            RingNotification.notifyFallback(this)
            stopSelf()
            return START_NOT_STICKY
        }

        try {
            playBell()
        } catch (_: Exception) {
            RingNotification.notifyFallback(this)
            stopSelf()
            return START_NOT_STICKY
        }

        handler.removeCallbacks(stopRunnable)
        handler.postDelayed(stopRunnable, 8_000)
        return START_NOT_STICKY
    }

    private fun playBell() {
        player?.release()
        player = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            val afd = resources.openRawResourceFd(R.raw.bell)
            setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            setOnCompletionListener {
                it.release()
                player = null
                stopSelf()
            }
            prepare()
            start()
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(stopRunnable)
        player?.release()
        player = null
        super.onDestroy()
    }
}
