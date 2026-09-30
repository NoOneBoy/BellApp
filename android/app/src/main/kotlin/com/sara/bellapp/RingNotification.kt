package com.sara.bellapp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object RingNotification {
    const val CHANNEL_ID = "bell_ring"
    const val ID = 1001
    const val FALLBACK_ID = 1002

    private val playedIds = LinkedHashSet<String>()

    @Synchronized
    fun claim(ringId: String?): Boolean {
        if (ringId.isNullOrBlank()) return true
        if (!playedIds.add(ringId)) return false
        while (playedIds.size > 40) {
            val iterator = playedIds.iterator()
            iterator.next()
            iterator.remove()
        }
        return true
    }

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val sound = Uri.parse("android.resource://${context.packageName}/${R.raw.bell}")
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Campana remota",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Suena cuando la otra campana se toca o se agita"
            setSound(sound, attrs)
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 180, 80, 180)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        context.getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    fun build(context: Context, text: String): Notification {
        ensureChannel(context)
        val launch = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pending = PendingIntent.getActivity(
            context,
            0,
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_bell)
            .setContentTitle("BellApp")
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    fun notifyFallback(context: Context) {
        ensureChannel(context)
        try {
            NotificationManagerCompat.from(context).notify(
                FALLBACK_ID,
                build(context, "La otra campana está sonando"),
            )
        } catch (_: SecurityException) {
            // Sin POST_NOTIFICATIONS el sistema bloquea el aviso.
        }
    }
}
