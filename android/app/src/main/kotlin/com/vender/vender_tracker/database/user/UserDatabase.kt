package com.vender.vender_tracker.database.user
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
//@Database(entities = [UserEntity::class], version = 1)
//abstract class UserDatabase : RoomDatabase() {
//    abstract fun userDao(): UserDao
//
//    companion object {
//        @Volatile private var INSTANCE: UserDatabase? = null
//
//        fun getInstance(context: Context): UserDatabase {
//            return INSTANCE ?: synchronized(this) {
//                Room.databaseBuilder(
//                    context.applicationContext,
//                    UserDatabase::class.java,
//                    "user_db"
//                )
//                .addCallback(object : RoomDatabase.Callback() {
//                    override fun onCreate(db: SupportSQLiteDatabase) {
//                        super.onCreate(db)
//                        // Insert default super admin user
//                        CoroutineScope(Dispatchers.IO).launch {
//                            getInstance(context).userDao().insertUser(
//                                UserEntity(
//                                    id = 1000,
//                                    role = 0,
//                                    name = "super admin",
//                                    email = "admin@job.com",
//                                    password = "admin@job.com",
//                                    designation = "Super Admin",
//                                    creator = 1000
//                                )
//                            )
//                        }
//                    }
//                })
//                .build().also { INSTANCE = it }
//            }
//        }
//    }
//}