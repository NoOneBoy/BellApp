package com.sara.bellapp

import android.content.Intent
import android.os.Bundle
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        RingNotification.ensureChannel(this)
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()
        AppForeground.isForeground = true
    }

    override fun onPause() {
        AppForeground.isForeground = false
        super.onPause()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "playRemoteBell") {
                val intent = Intent(this, RingForegroundService::class.java)
                ContextCompat.startForegroundService(this, intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.sara.bellapp/ring"
    }
}
