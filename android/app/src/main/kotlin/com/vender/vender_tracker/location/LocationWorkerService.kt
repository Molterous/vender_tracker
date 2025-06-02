package com.vender.vender_tracker.location

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Context.BATTERY_SERVICE
import android.os.BatteryManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.vender.vender_tracker.alarms.AlarmManagerHelper
import com.vender.vender_tracker.appwrite.LocationEntity
import com.vender.vender_tracker.appwrite.LocationRepositoryAppwrite
import com.vender.vender_tracker.pref.UserPreferences
import io.appwrite.Client
import io.appwrite.services.Databases
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch


class LocationWorkerService : LifecycleService() {

    override fun onCreate() {
        super.onCreate()
        startForeground(1, createNotification())
        fetchAndStoreLocation()
    }

    private fun createNotification(): Notification {

        val channelId = "location_channel"
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(channelId, "Location Logging", NotificationManager.IMPORTANCE_LOW)
        )
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Location Logging Active")
            .setContentText("Logging location every 30 minutes")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .build()
    }

    private fun fetchAndStoreLocation() {
        lifecycleScope.launch {
            fetchAndStoreLoc(applicationContext)
            AlarmManagerHelper.scheduleNext(applicationContext)
            stopSelf()
        }
    }
}

suspend fun fetchAndStoreLoc(applicationContext: Context, taskId: String = "", event: String = "") {

    val location    = getLastKnownLocation(applicationContext)
    val prefs       = UserPreferences(applicationContext)

    // user info
    val info        = prefs.getUser()
    val username    = info.firstOrNull()?.first
    val empId       = info.firstOrNull()?.second

    val manager = applicationContext.getSystemService(BATTERY_SERVICE) as BatteryManager
    val batteryLevel = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)

    Log.w("LocationWorkerService", "Logging loc with ${location?.latitude} |" +
            " ${location?.longitude} | $batteryLevel | $taskId | $event")

    if (location != null && !username.isNullOrBlank() && !empId.isNullOrBlank()) {

        val client = Client(applicationContext)
            .setEndpoint("https://fra.cloud.appwrite.io/v1")
            .setProject("6829baed00384fcf5a57")
//            .setSelfSigned(status = true)

        LocationRepositoryAppwrite(Databases(client)).insertLocation(
            location = LocationEntity(
                locationId = "",
                userName = username,
                workerId   =  empId,
                latitude = location.latitude.toString(),
                longitude = location.longitude.toString(),
                timeStamp = System.currentTimeMillis().toString(),
                taskId = taskId,
                batteryLevel = batteryLevel.toString(),
                event = event
            )
        )
        Log.w("LocationWorkerService", "Logged loc to server")
    } else {
        Log.w("LocationWorkerService", "Skipping save — missing location or username")
    }
}