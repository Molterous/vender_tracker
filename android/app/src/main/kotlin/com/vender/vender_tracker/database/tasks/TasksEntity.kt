package com.vender.vender_tracker.database.tasks
//
//import androidx.room.Entity
//import androidx.room.PrimaryKey
//
//@Entity(tableName = "tasks")
//data class TasksEntity(
//    @PrimaryKey(autoGenerate = true)
//    val id: Int? = null, // taskId
//
//    val status: Int, // 0 for idle, 1 for in progress, 2 for completed
//    val title: String,
//    val desc: String,
//    val dueDate: String, // dateTime in string format
//    val updates: String, // json encoded map, updates made to this task
//    val worker: Int, // user if
//    val creator: Int // admin id, who created this task
//    // time logged, calc at frontend
//)