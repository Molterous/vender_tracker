package com.vender.vender_tracker.database.user
//
//import androidx.room.*
//import kotlinx.coroutines.flow.Flow
//
//@Dao
//interface UserDao {
//    @Query("SELECT * FROM users")
//    suspend fun getAllUsers(): List<UserEntity>
//
//    @Query("SELECT * FROM users WHERE id = :userId")
//    suspend fun getUserById(userId: Int): UserEntity?
//
//    @Query("SELECT * FROM users WHERE email = :email LIMIT 1")
//    suspend fun getUserByEmail(email: String): UserEntity?
//
//    @Insert(onConflict = OnConflictStrategy.REPLACE)
//    suspend fun insertUser(user: UserEntity): Long
//
//    @Update
//    suspend fun updateUser(user: UserEntity)
//
//    @Delete
//    suspend fun deleteUser(user: UserEntity)
//
//    @Query("DELETE FROM users WHERE id = :userId")
//    suspend fun deleteUserById(userId: Int)
//}