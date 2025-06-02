package com.vender.vender_tracker.database.attendance

//import android.content.Context
//
//class AttendanceRepository(context: Context) {
//
//    private val attendanceDao = AttendanceDatabase.getInstance(context).attendanceDao()
//
//    // Insert or replace attendance record
//    suspend fun logAttendance(userId: Int, date: String, loginTime: String, logged: String = "1"): Long {
//        val attendance = AttendanceEntity(
//            worker = userId,
//            date = date,
//            loginTime = loginTime,
//            logged = logged
//        )
//        return attendanceDao.insertAttendance(attendance)
//    }
//
//    // Update logged time when user logs out
//    suspend fun updateLoggedTime(userId: Int, date: String, loggedTime: String): Int {
//        return attendanceDao.updateLoggedTime(userId, date, loggedTime)
//    }
//
//    // Get attendance for a user for a specific month (format "YYYY-MM")
//    suspend fun getUserAttendanceForMonth(userId: Int, month: String): List<AttendanceEntity> {
//        return attendanceDao.getUserAttendanceForMonth(userId, month)
//    }
//
//    // Get all users' attendance for a specific day (format "YYYY-MM-DD")
//    suspend fun getAllAttendanceForDay(date: String): List<AttendanceEntity> {
//        return attendanceDao.getAllAttendanceForDay(date)
//    }
//
//    suspend fun getLoggedTimeOrZero(userId: Int, date: String): String {
//        return attendanceDao.getLoggedTimeForUserOnDate(userId, date) ?: "0"
//    }
//}