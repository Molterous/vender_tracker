package com.vender.vender_tracker.database.attendance
//
//import androidx.room.*
//import kotlinx.coroutines.flow.Flow
//
//@Dao
//interface AttendanceDao {
//
//    @Insert(onConflict = OnConflictStrategy.REPLACE)
//    suspend fun insertAttendance(attendance: AttendanceEntity): Long
//
//    // Get all attendance for a user in a specific month
//    @Query("SELECT * FROM attendance WHERE worker = :userId AND date LIKE :month || '%' ORDER BY date ASC")
//    suspend fun getUserAttendanceForMonth(userId: Int, month: String): List<AttendanceEntity>
//
//    // Get all attendance of all users for a particular date
//    @Query("SELECT * FROM attendance WHERE date = :targetDate ORDER BY loginTime ASC")
//    suspend fun getAllAttendanceForDay(targetDate: String): List<AttendanceEntity>
//
//    // ✅ Update logged time for a user on a specific date
//    @Query("UPDATE attendance SET logged = :loggedTime WHERE worker = :userId AND date = :targetDate")
//    suspend fun updateLoggedTime(userId: Int, targetDate: String, loggedTime: String): Int
//
//    @Query("SELECT logged FROM attendance WHERE worker = :userId AND date = :date LIMIT 1")
//    suspend fun getLoggedTimeForUserOnDate(userId: Int, date: String): String?
//}
//
//
//// val userId = 4
//// val date = "2025-05-17"
//// val durationInMinutes = "120"
//
//// val rowsUpdated = attendanceDao.updateLoggedTime(userId, date, durationInMinutes)
//// val attendanceMay = dao.getUserAttendanceForMonth(userId = 4, month = "2025-05")
//// val attendanceToday = dao.getAllAttendanceForDay("2025-05-17")