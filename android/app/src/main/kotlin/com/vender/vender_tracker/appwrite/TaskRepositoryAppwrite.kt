package com.vender.vender_tracker.appwrite

import android.util.Log
import io.appwrite.Query
import io.appwrite.models.Document
import io.appwrite.services.Databases
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class TaskRepositoryAppwrite(
    private val databases: Databases,
    private val collectionId: String = "",
    private val dbId: String = ""
) {

    suspend fun getAllTasks(): List<TaskEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
            ).documents.map { it.toTask() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching all tasks", e)
            throw e
        }
    }

    suspend fun getTasksByUserId(userId: String): List<TaskEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(Query.equal("worker", userId))
            ).documents.map { it.toTask() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching tasks by userId", e)
            throw e
        }
    }

    suspend fun getTaskById(taskId: String): TaskEntity? = withContext(Dispatchers.IO) {
        try {
            databases.getDocument(dbId, collectionId, taskId).toTask()
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching task by ID", e)
            throw e
        }
    }

    suspend fun insertTask(task: TaskEntity): String? = withContext(Dispatchers.IO) {
        try {
            databases.createDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = "unique()",
                data = task.toMap()
            ).id
        } catch (e: Exception) {
            Log.e("Appwrite", "Error inserting task", e)
            throw e
        }
    }

    suspend fun updateTask(task: TaskEntity): Boolean = withContext(Dispatchers.IO) {
        try {
            databases.updateDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = task.taskId,
                data = task.toMap()
            )
            true
        } catch (e: Exception) {
            Log.e("Appwrite", "Error updating task", e)
            throw e
        }
    }

    suspend fun deleteTaskById(taskId: String): Boolean = withContext(Dispatchers.IO) {
        try {
            databases.deleteDocument(dbId, collectionId, taskId)
            true
        } catch (e: Exception) {
            Log.e("Appwrite", "Error deleting task", e)
            throw e
        }
    }

    private fun Document<Map<String, Any>>.toTask() = TaskEntity(
        taskId = this.id,
        status = ((data["status"]).toString()).toInt(),
        title = data["title"] as String,
        desc = data["desc"] as String,
        due = data["due"] as String,
        updates = data["updates"] as String,
        workerId = data["worker"] as String,
        creatorId = data["creator"] as String
    )

    private fun TaskEntity.toMap(): Map<String, Any> = mapOf(
        "status" to status,
        "title" to title,
        "desc" to desc,
        "due" to due,
        "updates" to updates,
        "worker" to workerId,
        "creator" to creatorId
    )
}
