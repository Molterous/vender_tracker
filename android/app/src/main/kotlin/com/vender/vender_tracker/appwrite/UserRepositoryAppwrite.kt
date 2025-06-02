package com.vender.vender_tracker.appwrite

import android.util.Log
import io.appwrite.Query
import io.appwrite.models.Document
import io.appwrite.services.Databases
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class UserRepositoryAppwrite(
    private val databases: Databases,
    private val collectionId: String = "6829bd5b0023262efee7",
    private val dbId: String = "6829bd41001be6cf973b"
) {

    suspend fun getAllUsers(): List<UserEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
            ).documents.map { it.toUser() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching all users", e)
            throw e
        }
    }

    suspend fun getUserById(userId: String): UserEntity? = withContext(Dispatchers.IO) {
        try {
            databases.getDocument(dbId, collectionId, userId).toUser()
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching user by ID", e)
            throw e
        }
    }

    suspend fun getUserByEmail(email: String): UserEntity? = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(Query.equal("email", email), Query.limit(1))
            ).documents.firstOrNull()?.toUser()
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching user by email", e)
            throw e
        }
    }

    suspend fun insertUser(user: UserEntity): String? = withContext(Dispatchers.IO) {
        try {
            databases.createDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = "unique()",
                data = user.toMap()
            ).id
        } catch (e: Exception) {
            Log.e("Appwrite", "Error inserting user", e)
            throw e
        }
    }

    suspend fun updateUser(user: UserEntity): Boolean = withContext(Dispatchers.IO) {
        try {
            databases.updateDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = user.userId,
                data = user.toMap()
            )
            true
        } catch (e: Exception) {
            Log.e("Appwrite", "Error updating user", e)
            throw e
        }
    }

    suspend fun deleteUser(userId: String): Boolean = withContext(Dispatchers.IO) {
        try {
            databases.deleteDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = userId
            )
            true
        } catch (e: Exception) {
            Log.e("Appwrite", "Error deleting user", e)
            throw e
        }
    }

    private fun Document<Map<String, Any>>.toUser() = UserEntity(
        userId = this.id,
        role = (data["role"] as Number).toInt(),
        name = data["name"] as String,
        email = data["email"] as String,
        password = data["password"] as String,
        designation = data["designation"] as String,
        fcm = (data["fcm"] ?: "") as String,
        creatorId = data["creator"] as String
    )

    private fun UserEntity.toMap(): Map<String, Any> = mapOf(
        "role" to role,
        "name" to name,
        "email" to email,
        "password" to password,
        "designation" to designation,
        "fcm" to (fcm ?: ""),
        "creator" to creatorId
    )
}
