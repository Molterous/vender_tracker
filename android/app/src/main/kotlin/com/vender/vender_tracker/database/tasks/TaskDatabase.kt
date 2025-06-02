package com.vender.vender_tracker.database.tasks
//
//import android.content.Context
//import androidx.room.Database
//import androidx.room.Room
//import androidx.room.RoomDatabase
//import androidx.sqlite.db.SupportSQLiteDatabase
//import kotlinx.coroutines.CoroutineScope
//import kotlinx.coroutines.Dispatchers
//import kotlinx.coroutines.launch
//
//@Database(entities = [TasksEntity::class], version = 1)
//abstract class TaskDatabase : RoomDatabase() {
//    abstract fun taskDao(): TaskDao
//
//    companion object {
//        @Volatile private var INSTANCE: TaskDatabase? = null
//
//        fun getInstance(context: Context): TaskDatabase {
//            return INSTANCE ?: synchronized(this) {
//                Room.databaseBuilder(
//                    context.applicationContext,
//                    TaskDatabase::class.java,
//                    "task_db"
//                )
//                .build().also { INSTANCE = it }
//            }
//        }
//    }
//}