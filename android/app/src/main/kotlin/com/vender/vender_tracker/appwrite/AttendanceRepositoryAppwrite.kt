package com.vender.vender_tracker.appwrite

import android.util.Log
import io.appwrite.Query
import io.appwrite.models.Document
import io.appwrite.services.Databases
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AttendanceRepositoryAppwrite(
    private val databases: Databases,
    private val collectionId: String = "",
    private val dbId: String = ""
) {
    suspend fun insertAttendance(att: AttendanceEntity): String? = withContext(Dispatchers.IO) {
        try {
            val doc = databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(
                    Query.equal("worker", att.workerId),
                    Query.equal("date", att.loggedDate)
                )
            ).documents.firstOrNull()

            if (doc != null) {
                return@withContext doc.id;
            }

            databases.createDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = "unique()",
                data = att.toMap()
            ).id
        } catch (e: Exception) {
            Log.e("Appwrite", "Error inserting attendance", e)
            null
        }
    }

    suspend fun getUserAttendanceForMonth(workerId: String, month: String): List<AttendanceEntity> =
        withContext(Dispatchers.IO) {
            try {
                databases.listDocuments(
                    databaseId = dbId,
                    collectionId = collectionId,
                    queries = listOf(
                        Query.equal("worker", workerId),
                        Query.startsWith("date", month),
                        Query.orderAsc("date")
                    )
                ).documents.map { it.toAttendance() }
            } catch (e: Exception) {
                Log.e("Appwrite", "Error fetching attendance for month", e)
                emptyList()
            }
        }

    suspend fun getAllAttendanceForDay(date: String): List<AttendanceEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(
                    Query.equal("date", date),
                    Query.orderAsc("login")
                )
            ).documents.map { it.toAttendance() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching attendance for day", e)
            emptyList()
        }
    }

    suspend fun getAllActiveUser(date: String): List<AttendanceEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(
                    Query.equal("date", date),
                    Query.equal("isActive", "Yes"),
                    Query.orderAsc("login")
                )
            ).documents.map { it.toAttendance() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching get All Active User for day", e)
            emptyList()
        }
    }

    suspend fun updateLoggedTime(workerId: String, date: String, loggedTime: String): Boolean =
        withContext(Dispatchers.IO) {
            try {
                val doc = databases.listDocuments(
                    databaseId = dbId,
                    collectionId = collectionId,
                    queries = listOf(
                        Query.equal("worker", workerId),
                        Query.equal("date", date)
                    )
                ).documents.firstOrNull() ?: return@withContext false

                databases.updateDocument(
                    databaseId = dbId,
                    collectionId = collectionId,
                    documentId = doc.id,
                    data = mapOf("logged" to loggedTime)
                )
                true
            } catch (e: Exception) {
                Log.e("Appwrite", "Error updating logged time", e)
                false
            }
        }

    suspend fun updateLoggedType(workerId: String, date: String, isActive: Boolean): Boolean =
        withContext(Dispatchers.IO) {
            try {
                val doc = databases.listDocuments(
                    databaseId = dbId,
                    collectionId = collectionId,
                    queries = listOf(
                        Query.equal("worker", workerId),
                        Query.equal("date", date)
//                        Query.orderAsc("date")
                    )
                ).documents.firstOrNull() ?: return@withContext false

                val isActiveStr = if (isActive) { "Yes" } else { "No" }

                databases.updateDocument(
                    databaseId = dbId,
                    collectionId = collectionId,
                    documentId = doc.id,
                    data = mapOf("isActive" to isActiveStr)
                )
                true
            } catch (e: Exception) {
                Log.e("Appwrite", "Error updating logged time", e)
                false
            }
        }

    suspend fun getLoggedTimeForUserOnDate(workerId: String, date: String): String? =
        withContext(Dispatchers.IO) {
            try {
                databases.listDocuments(
                    databaseId = dbId,
                    collectionId = collectionId,
                    queries = listOf(
                        Query.equal("worker", workerId),
                        Query.equal("date", date)
                    )
                ).documents.firstOrNull()?.data?.get("logged") as? String
            } catch (e: Exception) {
                Log.e("Appwrite", "Error fetching logged time for user on date", e)
                null
            }
        }

    private fun Document<Map<String, Any>>.toAttendance() = AttendanceEntity(
        attendanceId = this.id,
        workerId = data["worker"] as String,
        loggedTime = data["logged"] as String,
        loggedDate = data["date"] as String,
        loginTime = data["login"] as String,
        isActive = data["isActive"] as String
    )

    private fun AttendanceEntity.toMap(): Map<String, Any> = mapOf(
        "worker" to workerId,
        "logged" to loggedTime,
        "date" to loggedDate,
        "login" to loginTime,
        "isActive" to isActive
    )
}
