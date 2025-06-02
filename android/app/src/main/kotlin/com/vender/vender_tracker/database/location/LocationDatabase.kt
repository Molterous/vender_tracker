package com.vender.vender_tracker.database.location

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [LocationEntity::class], version = 1)
abstract class LocationDatabase : RoomDatabase() {
    abstract fun locationDao(): LocationDao

    companion object {
        @Volatile private var INSTANCE: LocationDatabase? = null

        fun getInstance(context: Context): LocationDatabase {
            return INSTANCE ?: synchronized(this) {
                Room.databaseBuilder(
                    context.applicationContext,
                    LocationDatabase::class.java,
                    "location_db"
                ).build().also { INSTANCE = it }
            }
        }
    }
}