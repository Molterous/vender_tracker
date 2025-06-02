package com.vender.vender_tracker.database.location

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "locations")
data class LocationEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,

    val userName: String,
    val workerId: String,
    val latitude: String,
    val longitude: String,
    val timeStamp: String,
    val taskId: String,
    val batteryLevel: String,
    val event: String
)