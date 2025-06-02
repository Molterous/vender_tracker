package com.vender.vender_tracker.alarms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.vender.vender_tracker.location.fetchAndStoreLoc
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class BootShutdownReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pendingResult = goAsync()

        CoroutineScope(Dispatchers.IO).launch {
            when (intent.action) {
                Intent.ACTION_SHUTDOWN -> {
                    Log.d("BootShutdownReceiver", "Device is shutting down")
                    AlarmManagerHelper.cancel(context)
                    fetchAndStoreLoc(context, event = "SHUT-DOWN")
                }

                Intent.ACTION_BOOT_COMPLETED -> {
                    Log.d("BootShutdownReceiver", "Device boot completed")
                    fetchAndStoreLoc(context, event = "BOOT-ON")
                }
            }
            pendingResult.finish()  // Important: let system know you're done
        }
    }

}