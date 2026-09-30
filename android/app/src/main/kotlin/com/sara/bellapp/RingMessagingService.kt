package com.sara.bellapp

import android.content.Intent
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class RingMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        if (message.data["type"] != "ring") return
        if (AppForeground.isForeground) return
        if (!RingNotification.claim(message.data["ringId"])) return

        val highPriority =
            message.priority == RemoteMessage.PRIORITY_HIGH ||
                message.originalPriority == RemoteMessage.PRIORITY_HIGH

        if (highPriority) {
            val intent = Intent(this, RingForegroundService::class.java).apply {
                putExtra("ringId", message.data["ringId"])
                putExtra("roomId", message.data["roomId"])
            }
            try {
                ContextCompat.startForegroundService(this, intent)
            } catch (_: Exception) {
                RingNotification.notifyFallback(this)
            }
        } else {
            RingNotification.notifyFallback(this)
        }
    }
}
