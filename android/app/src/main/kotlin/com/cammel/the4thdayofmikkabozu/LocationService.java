package com.cammel.the4thdayofmikkabozu;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

public class LocationService extends Service {

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("debug", "called TestServiceJ.onCreate()");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("debug", "called onStartCommand()");
        String channelId = "service";
        String title = "TestServiceJ";
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationManager notificationManager =
                    (NotificationManager)getApplication().getSystemService(Context.NOTIFICATION_SERVICE);
            NotificationChannel channel = new NotificationChannel(channelId, title, NotificationManager.IMPORTANCE_DEFAULT);

            if(notificationManager != null){
                notificationManager.createNotificationChannel(channel);
                Notification notification = new Notification.Builder(getApplicationContext(), channelId)
                        .setContentTitle(title)
                        .setContentText("service start")
                        .build();

                Log.d("debug", "before call startForeground()");
                startForeground(1,notification);
                Log.d("debug", "after call startForeground()");
            }
        }

        return START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("debug", "called onDestroy()");
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
