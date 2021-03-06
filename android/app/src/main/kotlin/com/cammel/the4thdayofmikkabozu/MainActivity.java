package com.cammel.the4thdayofmikkabozu;

import android.content.Intent;
import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "Java.Foreground";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("ON")){
                                Intent serviceIntent = new Intent(getApplication(), LocationService.class);
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    startForegroundService(serviceIntent);
                                }
                            } else if(call.method.equals("OFF")){
                                Intent intent = new Intent(getApplication(), LocationService.class);
                                stopService(intent);
                            }
                        }
                );
    }
}