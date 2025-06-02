package com.vender.vender_tracker.database.tasks
//
//import android.content.Context
//
//class TaskRepository(context: Context) {
//
//    private val taskDao = TaskDatabase.getInstance(context).taskDao()
//
//    suspend fun getAllTasks(): List<TasksEntity> = taskDao.getAllTasks()
//
//    suspend fun getTasksByUserId(userId: Int): List<TasksEntity> = taskDao.getTasksByUserId(userId)
//
//    suspend fun getTasksById(taskId: Int): TasksEntity? = taskDao.getTasksById(taskId)
//
//    suspend fun createTask(
//        status: Int,
//        title: String,
//        desc: String,
//        dueDate: String,
//        updates: String,
//        worker: Int,
//        creator: Int
//    ): Long {
//        val task = TasksEntity(
//            status = status,
//            title = title,
//            desc = desc,
//            dueDate = dueDate,
//            updates = updates,
//            worker = worker,
//            creator = creator
//        )
//        return taskDao.insertTask(task)
//    }
//
//    suspend fun updateTask(
//        id: Int,
//        status: Int,
//        title: String,
//        desc: String,
//        dueDate: String,
//        updates: String,
//        worker: Int,
//        creator: Int
//    ) {
//        val task = TasksEntity(
//            id = id,
//            status = status,
//            title = title,
//            desc = desc,
//            dueDate = dueDate,
//            updates = updates,
//            worker = worker,
//            creator = creator
//        )
//        taskDao.updateTask(task)
//    }
//
//    suspend fun deleteTask(taskId: Int) {
//        taskDao.deleteTaskById(taskId)
//    }
//}