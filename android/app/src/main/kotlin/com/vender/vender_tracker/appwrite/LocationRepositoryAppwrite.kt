package com.vender.vender_tracker.appwrite

import android.util.Log
import io.appwrite.Query
import io.appwrite.models.Document
import io.appwrite.services.Databases
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class LocationRepositoryAppwrite(
    private val databases: Databases,
    private val collectionId: String = "6829bd7c003292340088",
    private val dbId: String = "6829bd41001be6cf973b"
) {
    suspend fun insertLocation(location: LocationEntity): String? = withContext(Dispatchers.IO) {
        try {
            databases.createDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = "unique()",
                data = location.toMap()
            ).id
        } catch (e: Exception) {
            Log.e("Appwrite", "Error inserting location", e)
            null
        }
    }

    suspend fun getUserLocationsByDate(workerId: String, start: String, end: String): List<LocationEntity> =
        withContext(Dispatchers.IO) {
            try {
                databases.listDocuments(
                    databaseId = dbId,
                    collectionId = collectionId,
                    queries = listOf(
                        Query.equal("worker", workerId),
                        Query.greaterThanEqual("timestamp", start),
                        Query.lessThanEqual("timestamp", end),
                        Query.orderAsc("timestamp")
                    )
                ).documents.map { it.toLocation() }
            } catch (e: Exception) {
                Log.e("Appwrite", "Error fetching user locations by date", e)
                emptyList()
            }
        }

    private fun Document<Map<String, Any>>.toLocation() = LocationEntity(
        locationId = this.id,
        userName = data["name"] as String,
        workerId = data["worker"] as String,
        latitude = data["latitude"] as String,
        longitude = data["longitude"] as String,
        timeStamp = data["timestamp"] as String,
        taskId = data["task"] as String,
        batteryLevel = data["battery"] as String,
        event = data["event"] as String
    )

    private fun LocationEntity.toMap(): Map<String, Any> = mapOf(
        "name" to userName,
        "worker" to workerId,
        "latitude" to latitude,
        "longitude" to longitude,
        "timestamp" to timeStamp,
        "task" to taskId,
        "battery" to batteryLevel,
        "event" to event
    )
}
