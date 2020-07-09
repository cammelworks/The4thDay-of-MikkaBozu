package com.cammel.the4thdayofmikkabozu

import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import java.util.*;

class TestService : Service(){
    val handler = Handler()
    private val timer = Timer()
    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        val timerTask = object : TimerTask() {
            override fun run() {
                handler.post (Runnable {
                    Log.d("debug", "background")
                })
            }
        }
        timer.schedule(timerTask, 0, 1000)
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
    }
}