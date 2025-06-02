package com.vender.vender_tracker.location

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.util.Log
import androidx.core.content.ContextCompat
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

suspend fun getLastKnownLocation(context: Context): Location? = suspendCancellableCoroutine { cont ->
    if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
        != PackageManager.PERMISSION_GRANTED
    ) {
        Log.i("getLastKnownLocation", "suspendCancellableCoroutine")
        cont.resume(null)
        return@suspendCancellableCoroutine
    }

    val fusedClient = LocationServices.getFusedLocationProviderClient(context)
    fusedClient.lastLocation
        .addOnSuccessListener { location -> cont.resume(location) }
        .addOnFailureListener { cont.resume(null) }
}