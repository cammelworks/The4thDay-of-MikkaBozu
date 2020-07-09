package com.cammel.the4thdayofmikkabozu

import androidx.annotation.NonNull;
import android.content.Intent;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private var forService: Intent? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        forService = Intent(this@MainActivity, TestService::class.java)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.tasogarei.test/web").setMethodCallHandler {
            call, result ->
            when(call.method) {
                "web" -> {
                    Log.d("debug", "forService")
                    startService()
                }
            }
        }
    }

    private fun startService() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService)
//        } else {
//            startService(forService)
//        }
    }
}
