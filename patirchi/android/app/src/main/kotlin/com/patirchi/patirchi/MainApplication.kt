package com.patirchi.patirchi

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("a803c74e-8c7a-4842-a9c6-3a2118055e3c")
    }
}