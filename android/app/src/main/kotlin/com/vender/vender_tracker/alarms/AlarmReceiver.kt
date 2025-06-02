package com.vender.vender_tracker.alarms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat
import com.vender.vender_tracker.location.LocationWorkerService

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        ContextCompat.startForegroundService(
            context,
            Intent(context, LocationWorkerService::class.java)
        )
    }
}
