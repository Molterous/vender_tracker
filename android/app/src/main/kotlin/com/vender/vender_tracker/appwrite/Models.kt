package com.vender.vender_tracker.appwrite


data class UserEntity (
    val userId: String,
    val role: Int,
    val name: String,
    val email: String,
    val password: String,
    val designation: String,
    val fcm: String? = "",
    val creatorId: String
)

data class TaskEntity (
    val taskId: String,
    val status: Int,
    val title: String,
    val desc: String,
    val due: String,
    val updates: String,
    val workerId: String,
    val creatorId: String
)

data class LocationEntity (
    val locationId: String,
    val userName: String,
    val workerId: String,
    val latitude: String,
    val longitude: String,
    val timeStamp: String,
    val taskId: String,
    val batteryLevel: String,
    val event: String
)

data class AttendanceEntity (
    val attendanceId: String,
    val workerId: String,
    val loggedTime: String,
    val loggedDate: String,
    val loginTime: String,
    val isActive: String
)

data class QuotationEntity(
    val name: String,
    val info: String,
    val note: String,
    val worker: String,
    val taskId: String,
    val modifiedDate: String,
    val quotationId: String,
    val serviceName: String,
    val serviceType: String,
    val serviceCharges: String,
    val serviceUnit: String,
    val serviceRemark: String,
    val docketCharges: String,
    val hamaliCharges: String,
    val doorDelivery: String,
    val pfCharges: String,
    val greenTaxCharge: String,
    val fovCharges: String,
    val gstCharges: String,
    val otherCharges: String,
    val totalCharges: String,
)