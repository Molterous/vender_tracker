package com.vender.vender_tracker.appwrite

import android.util.Log
import io.appwrite.Query
import io.appwrite.models.Document
import io.appwrite.services.Databases
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class QuotationRepositoryAppwrite(
    private val databases: Databases,
    private val collectionId: String = "",
    private val dbId: String = ""
) {
    suspend fun addQuotation(q: QuotationEntity): String? = withContext(Dispatchers.IO) {
        try {
            databases.createDocument(
                databaseId = dbId,
                collectionId = collectionId,
                documentId = "unique()",
                data = q.toMap()
            ).id
        } catch (e: Exception) {
            Log.e("Appwrite", "Error adding quotation", e)
            null
        }
    }

    suspend fun getAllQuotations(): List<QuotationEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId
            ).documents.map { it.toQuotation() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching all quotations", e)
            emptyList()
        }
    }

    suspend fun getQuotationsByWorker(workerId: String): List<QuotationEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(Query.equal("worker", workerId))
            ).documents.map { it.toQuotation() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching quotations by worker", e)
            emptyList()
        }
    }

    suspend fun getQuotationsByTask(taskId: String): List<QuotationEntity> = withContext(Dispatchers.IO) {
        try {
            databases.listDocuments(
                databaseId = dbId,
                collectionId = collectionId,
                queries = listOf(Query.equal("taskId", taskId))
            ).documents.map { it.toQuotation() }
        } catch (e: Exception) {
            Log.e("Appwrite", "Error fetching quotations by task", e)
            emptyList()
        }
    }

    suspend fun updateQuotation(quotationId: String, updatedData: QuotationEntity): Boolean =
        withContext(Dispatchers.IO) {
            try {
                databases.updateDocument(
                    databaseId = dbId,
                    collectionId = collectionId,
                    documentId = quotationId,
                    data = updatedData.toMap()
                )
                true
            } catch (e: Exception) {
                Log.e("Appwrite", "Error updating quotation", e)
                false
            }
        }

    suspend fun deleteQuotation(quotationId: String): Boolean = withContext(Dispatchers.IO) {
        try {
            databases.deleteDocument(dbId, collectionId, quotationId)
            true
        } catch (e: Exception) {
            Log.e("Appwrite", "Error deleting quotation", e)
            false
        }
    }

    private fun Document<Map<String, Any>>.toQuotation() = QuotationEntity(
        name = data["name"] as String,
        info = data["info"] as String,
        note = data["note"] as String,
        worker = data["worker"] as String,
        taskId = data["taskId"] as String,
        modifiedDate = data["modifiedDate"] as String,
        quotationId = this.id,
        serviceName = data["serviceName"] as String,
        serviceType = data["serviceType"] as String,
        serviceCharges = data["serviceCharges"] as String,
        serviceUnit = data["serviceUnit"] as String,
        serviceRemark = data["serviceRemark"] as String,
        docketCharges = data["docketCharges"] as String,
        hamaliCharges = data["hamaliCharges"] as String,
        doorDelivery = data["doorDelivery"] as String,
        pfCharges = data["pfCharges"] as String,
        greenTaxCharge = data["greenTaxCharge"] as String,
        fovCharges = data["fovCharges"] as String,
        gstCharges = data["gstCharges"] as String,
        otherCharges = data["otherCharges"] as String,
        totalCharges = data["totalCharges"] as String,
    )

    private fun QuotationEntity.toMap(): Map<String, Any> = mapOf(
        "name" to name,
        "info" to info,
        "note" to note,
        "worker" to worker,
        "taskId" to taskId,
        "modifiedDate" to modifiedDate,
        "serviceName" to serviceName,
        "serviceType" to serviceType,
        "serviceCharges" to serviceCharges,
        "serviceUnit" to serviceUnit,
        "serviceRemark" to serviceRemark,
        "docketCharges" to docketCharges,
        "hamaliCharges" to hamaliCharges,
        "doorDelivery" to doorDelivery,
        "pfCharges" to pfCharges,
        "greenTaxCharge" to greenTaxCharge,
        "fovCharges" to fovCharges,
        "gstCharges" to gstCharges,
        "otherCharges" to otherCharges,
        "totalCharges" to totalCharges,
    )
}
