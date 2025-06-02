package com.vender.vender_tracker.database.tasks
//
//import androidx.room.*
//
//@Dao
//interface TaskDao {
//    @Query("SELECT * FROM tasks")
//    suspend fun getAllTasks(): List<TasksEntity>
//
//    @Query("SELECT * FROM tasks WHERE worker = :userId")
//    suspend fun getTasksByUserId(userId: Int): List<TasksEntity>
//
//    @Query("SELECT * FROM tasks WHERE id = :taskId")
//    suspend fun getTasksById(taskId: Int): TasksEntity?
//
//    @Insert(onConflict = OnConflictStrategy.REPLACE)
//    suspend fun insertTask(task: TasksEntity): Long
//
//    @Update
//    suspend fun updateTask(task: TasksEntity)
//
//    @Query("DELETE FROM tasks WHERE id = :taskId")
//    suspend fun deleteTaskById(taskId: Int)
//}