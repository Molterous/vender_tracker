package com.vender.vender_tracker.database.user
//
//import android.content.Context
//import kotlinx.coroutines.flow.Flow
//
//class UserRepository(context: Context) {
//    private val userDao = UserDatabase.getInstance(context).userDao()
//
//    fun init() { userDao }
//
//    suspend fun getAllUsers(): List<UserEntity> = userDao.getAllUsers()
//
//    suspend fun getUserById(userId: Int): UserEntity? = userDao.getUserById(userId)
//
//    suspend fun getUserByEmail(email: String): UserEntity? = userDao.getUserByEmail(email)
//
//    suspend fun createUser(
//        role: Int,
//        name: String,
//        email: String,
//        password: String,
//        designation: String,
//        creator: Int
//    ): Long {
//        val user = UserEntity(
//            role = role,
//            name = name,
//            email = email,
//            password = password,
//            designation = designation,
//            creator = creator
//        )
//        return userDao.insertUser(user)
//    }
//
//    suspend fun updateUser(
//        id: Int,
//        role: Int,
//        name: String,
//        email: String,
//        password: String,
//        designation: String,
//        creator: Int
//    ) {
//        val user = UserEntity(
//            id = id,
//            role = role,
//            name = name,
//            email = email,
//            password = password,
//            designation = designation,
//            creator = creator
//        )
//        userDao.updateUser(user)
//    }
//
//    suspend fun deleteUser(userId: Int) {
//        userDao.deleteUserById(userId)
//    }
//}