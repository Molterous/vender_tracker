package com.vender.vender_tracker.database.attendance
//
//import android.content.Context
//import androidx.room.Database
//import androidx.room.Room
//import androidx.room.RoomDatabase
//
//@Database(entities = [AttendanceEntity::class], version = 1)
//abstract class AttendanceDatabase : RoomDatabase() {
//    abstract fun attendanceDao(): AttendanceDao
//
//    companion object {
//        @Volatile private var INSTANCE: AttendanceDatabase? = null
//
//        fun getInstance(context: Context): AttendanceDatabase {
//            return INSTANCE ?: synchronized(this) {
//                Room.databaseBuilder(
//                    context.applicationContext,
//                    AttendanceDatabase::class.java,
//                    "attendance_db"
//                )
//                .build().also { INSTANCE = it }
//            }
//        }
//    }
//}