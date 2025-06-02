package com.vender.vender_tracker

import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat
import com.vender.vender_tracker.alarms.AlarmManagerHelper
import com.vender.vender_tracker.appwrite.AttendanceEntity
import com.vender.vender_tracker.appwrite.AttendanceRepositoryAppwrite
import com.vender.vender_tracker.appwrite.LocationEntity
import com.vender.vender_tracker.appwrite.LocationRepositoryAppwrite
import com.vender.vender_tracker.appwrite.QuotationEntity
import com.vender.vender_tracker.appwrite.QuotationRepositoryAppwrite
import com.vender.vender_tracker.appwrite.TaskEntity
import com.vender.vender_tracker.appwrite.TaskRepositoryAppwrite
import com.vender.vender_tracker.appwrite.UserEntity
import com.vender.vender_tracker.appwrite.UserRepositoryAppwrite
import com.vender.vender_tracker.location.LocationWorkerService
import com.vender.vender_tracker.location.fetchAndStoreLoc
import com.vender.vender_tracker.pref.UserPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.ZoneId
import io.appwrite.Client
import io.appwrite.services.Databases

class MainActivity: FlutterActivity() {

    private lateinit var client: Client

    private lateinit var userRepo: UserRepositoryAppwrite
    private lateinit var taskRepo: TaskRepositoryAppwrite
    private lateinit var locRepo: LocationRepositoryAppwrite
    private lateinit var attendanceRepo: AttendanceRepositoryAppwrite
    private lateinit var quotationRepo: QuotationRepositoryAppwrite


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        client = Client(context)
            .setEndpoint("https://fra.cloud.appwrite.io/v1")
            .setProject("6829baed00384fcf5a57")
//            .setSelfSigned(status = true)

        val db = Databases(client)


        userRepo = UserRepositoryAppwrite(db)
        taskRepo = TaskRepositoryAppwrite(db)
        locRepo = LocationRepositoryAppwrite(db)
        attendanceRepo = AttendanceRepositoryAppwrite(db)
        quotationRepo = QuotationRepositoryAppwrite(db)


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                when(call.method) {

                    /// locations methods

                    startLoggingMethod -> {
                        try {
                            ContextCompat.startForegroundService(
                                context,
                                Intent(context, LocationWorkerService::class.java)
                            )
                            MainScope().launch {
                                fetchAndStoreLoc(applicationContext, event = "Punch-In")
                                attendanceRepo.updateLoggedType(
                                    workerId = call.argument(idKey) ?: "",
                                    date = call.argument("date") ?: "",
                                    isActive = true,
                                )
                            }

                            result.success(true)
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    stopLoggingMethod -> {
                        try {
                            AlarmManagerHelper.cancel(context)
                            MainScope().launch {
                                fetchAndStoreLoc(applicationContext, event = "Punch-Out")
                                attendanceRepo.updateLoggedType(
                                    workerId = call.argument(idKey) ?: "",
                                    date = call.argument("date") ?: "",
                                    isActive = false,
                                )
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }


                    getLocDataByUserId -> {
                        try {

                            MainScope().launch {
                                val (start, end) = getStartAndEndTimestamps(call.argument("date") ?: "")

                                val allLocations = locRepo.getUserLocationsByDate(
                                    workerId = call.argument(idKey) ?: "",
                                    start = start.toString(),
                                    end = end.toString()
                                )

                                val uniqueLocations = allLocations.deduplicated()
                                val mapped = mutableMapOf<String, Map<String, String>>()

                                for (it in uniqueLocations) {
                                    val tempLoc = mapOf(
                                        "latitude" to it.latitude,
                                        "longitude" to it.longitude,
                                        "timestamp" to it.timeStamp,
                                        "taskId" to it.taskId,
                                        "batteryLevel" to it.batteryLevel,
                                        "event" to it.event,
                                    )
                                    mapped[it.timeStamp] = tempLoc
                                }

                                result.success(mapped)
                            }

                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }


                    /// user management methods

                    saveUserData -> {
                        try {
                            val prefs = UserPreferences(application)
                            MainScope().launch {
                                prefs.saveUser(
                                    call.argument(nameKey) ?: "",
                                    call.argument(idKey) ?: "",
                                )
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getSavedUserData -> {
                        try {
                            val prefs = UserPreferences(application)
                            MainScope().launch {
                                val user = prefs.getUser().firstOrNull()
                                Log.d("test", "userId: ${user?.second}")
                                result.success(user?.second)
                            }

                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    createUserMethod -> {
                        try {
                            MainScope().launch {

                                val userId = userRepo.insertUser(
                                    user = UserEntity(
                                        userId = "",
                                        role = call.argument(roleKey) ?: 1,
                                        name = call.argument(nameKey) ?: "",
                                        email = call.argument(emailKey) ?: "",
                                        password = call.argument(passwordKey) ?: "",
                                        designation = call.argument(designationKey) ?: "",
                                        fcm = call.argument(fcmKey) ?: "",
                                        creatorId = call.argument(creatorKey) ?: ""
                                    )
                                )
                                result.success(userId)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    updateUserMethod -> {
                        try {
                            MainScope().launch {
                                userRepo.updateUser(
                                    user = UserEntity(
                                        userId = call.argument(idKey) ?: "",
                                        role = call.argument(roleKey) ?: 1,
                                        name = call.argument(nameKey) ?: "",
                                        email = call.argument(emailKey) ?: "",
                                        password = call.argument(passwordKey) ?: "",
                                        designation = call.argument(designationKey) ?: "",
                                        fcm = call.argument(fcmKey) ?: "",
                                        creatorId = call.argument(creatorKey) ?: ""
                                    )
                                )
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    deleteUserMethod -> {
                        try {
                            MainScope().launch {
                                userRepo.deleteUser(userId = call.argument(idKey) ?: "")
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getUserByIdMethod -> {
                        try {
                            MainScope().launch {
                                val user = userRepo.getUserById(
                                    userId = call.argument(idKey) ?: ""
                                )

                                if (user == null ) {
                                    result.error(otherErrorCode, otherErrorMsg, "user is null")
                                } else {
                                    val userMap = mapOf(
                                        "id" to user.userId,
                                        "role" to (user.role).toString(),
                                        "name" to user.name,
                                        "email" to user.email,
                                        "password" to user.password,
                                        "designation" to user.designation,
                                        "creator" to (user.creatorId).toString()
                                    )
                                    result.success(userMap)
                                }
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getUserByEmailMethod -> {
                        try {
                            MainScope().launch {
                                val user = userRepo.getUserByEmail(
                                    email = call.argument(emailKey) ?: ""
                                )

                                if (user == null ) {
                                    result.error(otherErrorCode, otherErrorMsg, "user is null")
                                } else {
                                    val userMap = mapOf(
                                        "id" to user.userId,
                                        "role" to (user.role).toString(),
                                        "name" to user.name,
                                        "email" to user.email,
                                        "password" to user.password,
                                        "designation" to user.designation,
                                        "creator" to user.creatorId
                                    )
                                    result.success(userMap)
                                }
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getUsersMethod -> {
                        try {
                            MainScope().launch {
                                val users = userRepo.getAllUsers()

                                // Use mutableMap for construction
                                val userMap = mutableMapOf<String, Map<String, String>>()

                                for (user in users) {
                                    val singleUserMap = mapOf(
                                        "id" to user.userId,
                                        "role" to user.role.toString(),
                                        "name" to user.name,
                                        "email" to user.email,
                                        "password" to user.password,
                                        "designation" to user.designation,
                                        "creator" to user.creatorId
                                    )

                                    userMap[user.userId] = singleUserMap
                                }

                                result.success(userMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }
                    
                    
                    /// task management methods
                    
                    createTaskMethod -> {
                        try {
                            MainScope().launch {
                                
                                val taskId = taskRepo.insertTask(
                                    task = TaskEntity(
                                        taskId =    "",
                                        status =    call.argument("status") ?: 0,
                                        title =     call.argument("title") ?: "",
                                        desc =      call.argument("desc") ?: "",
                                        due =       call.argument("dueDate") ?: "",
                                        updates =   call.argument("updates") ?: "{}",
                                        workerId =  call.argument("worker") ?: "",
                                        creatorId = call.argument("creator") ?: ""
                                    )
                                )
                                result.success(taskId.toString())
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    updateTaskMethod -> {
                        try {
                            MainScope().launch {
                                taskRepo.updateTask(
                                    task = TaskEntity(
                                        taskId =    call.argument("id") ?: "",
                                        status =    call.argument("status") ?: 0,
                                        title =     call.argument("title") ?: "",
                                        desc =      call.argument("desc") ?: "",
                                        due =       call.argument("dueDate") ?: "",
                                        updates =   call.argument("updates") ?: "{}",
                                        workerId =  call.argument("worker") ?: "",
                                        creatorId = call.argument("creator") ?: ""
                                    )
                                )
                                
                                val status = call.argument("status") ?: 1
                                val statusString = if (status == 1) "In-progress" else "completed"

                                fetchAndStoreLoc(
                                    applicationContext,
                                    taskId =  call.argument("id") ?: "",
                                    event = "task status: $statusString"
                                )

                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    deleteTaskMethod -> {
                        try {
                            MainScope().launch {
                                taskRepo.deleteTaskById(taskId = call.argument("id") ?: "")
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getAllTasksMethod -> {
                        try {
                            MainScope().launch {
                                val tasks = taskRepo.getAllTasks()
                                val taskMap = mutableMapOf<String, Map<String, String>>()

                                for (task in tasks) {
                                    val t = mapOf(
                                        "id" to task.taskId,
                                        "status" to task.status.toString(),
                                        "title" to task.title,
                                        "desc" to task.desc,
                                        "dueDate" to task.due,
                                        "updates" to task.updates,
                                        "worker" to task.workerId,
                                        "creator" to task.creatorId
                                    )
                                    taskMap[task.taskId] = t
                                }

                                result.success(taskMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getTasksByUserIdMethod -> {
                        try {
                            MainScope().launch {
                                val tasks = taskRepo.getTasksByUserId(
                                    call.argument("userId") ?: ""
                                )
                                val taskMap = mutableMapOf<String, Map<String, String>>()

                                for (task in tasks) {
                                    val t = mapOf(
                                        "id" to task.taskId,
                                        "status" to task.status.toString(),
                                        "title" to task.title,
                                        "desc" to task.desc,
                                        "dueDate" to task.due,
                                        "updates" to task.updates,
                                        "worker" to task.workerId,
                                        "creator" to task.creatorId
                                    )
                                    taskMap[task.taskId] = t
                                }

                                result.success(taskMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }


                    /// attendance methods

                    logAttendance -> {
                        try {
                            MainScope().launch {
                                attendanceRepo.insertAttendance(
                                    att = AttendanceEntity(
                                        attendanceId = "",
                                        workerId =  call.argument("userId") ?: "",
                                        loggedTime = "1",
                                        loggedDate = call.argument("date") ?: "",
                                        loginTime = call.argument("loginTime") ?: "",
                                        isActive = "No"
                                    )
                                )
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getLoggedTimeOrZero -> {
                        try {
                            val prefs = UserPreferences(application)
                            MainScope().launch {
                                val time = prefs.getLoggedTime().firstOrNull() ?: "0"
                                result.success(time)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    clearSaveLoggedTime -> {
                        try {
                            val prefs = UserPreferences(application)
                            MainScope().launch {
                                prefs.saveLoggedTime(time = "0")
                                result.success(null)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }
                    
                    updateLoggedTime -> {
                        try {
                            val prefs = UserPreferences(application)
                            MainScope().launch {
                                attendanceRepo.updateLoggedTime(
                                    workerId = call.argument("userId") ?: "",
                                    date = call.argument("date") ?: "",
                                    loggedTime = call.argument("loggedTime") ?: "0"
                                )
                                prefs.saveLoggedTime(time = call.argument("loggedTime") ?: "0")
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getUserAttendanceForMonth -> {
                        try {
                            MainScope().launch {

                                val data = attendanceRepo.getUserAttendanceForMonth(
                                    workerId = call.argument("userId") ?: "0",
                                    month = call.argument("month") ?: ""
                                )
                                val attendanceMap = mutableMapOf<String, Map<String, String>>()

                                for (att in data) {
                                    val t = mapOf(
                                        "date" to att.loggedDate,
                                        "loginTime" to att.loginTime,
                                        "logged" to att.loggedTime,
                                        "worker" to att.workerId,
                                    )
                                    attendanceMap[att.loggedDate] = t
                                }

                                result.success(attendanceMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getAllAttendanceForDay -> {
                        try {
                            MainScope().launch {
                                val data = attendanceRepo.getAllAttendanceForDay(
                                    date = call.argument("date") ?: ""
                                )

                                val attendanceMap = mutableMapOf<String, Map<String, String>>()

                                for (att in data) {
                                    val t = mapOf(
                                        "date" to att.loggedDate,
                                        "loginTime" to att.loginTime,
                                        "logged" to att.loggedTime,
                                        "worker" to att.workerId,
                                    )
                                    attendanceMap[att.workerId] = t
                                }

                                result.success(attendanceMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getAllActiveUsers -> {
                        try {
                            MainScope().launch {
                                val data = attendanceRepo.getAllActiveUser(
                                    date = call.argument("date") ?: ""
                                )

                                val attendanceMap = mutableMapOf<String, Map<String, String>>()

                                for (att in data) {
                                    val t = mapOf("worker" to att.workerId)
                                    attendanceMap[att.workerId] = t
                                }

                                result.success(attendanceMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }


                    // quotation list

                    addQuotation ->  {
                        try {
                            MainScope().launch {

                                val id = quotationRepo.addQuotation(
                                    q = QuotationEntity(
                                        quotationId = "", // "quotationId"
                                        name = call.argument("name") ?: "",
                                        info = call.argument("info") ?: "",
                                        note = call.argument("note") ?: "",
                                        taskId = call.argument("taskId") ?: "",
                                        worker = call.argument("worker") ?: "",
                                        services = call.argument("services") ?: "",
                                        modifiedDate = call.argument("modifiedDate") ?: ""
                                    )
                                )
                                result.success(id)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    updateQuotation ->  {
                        try {
                            MainScope().launch {

                                val id = quotationRepo.updateQuotation(
                                    quotationId = call.argument("quotationId") ?: "",
                                    updatedData = QuotationEntity(
                                        quotationId = call.argument("quotationId") ?: "",
                                        name = call.argument("name") ?: "",
                                        info = call.argument("info") ?: "",
                                        note = call.argument("note") ?: "",
                                        taskId = call.argument("taskId") ?: "",
                                        worker = call.argument("worker") ?: "",
                                        services = call.argument("services") ?: "",
                                        modifiedDate = call.argument("modifiedDate") ?: ""
                                    )
                                )
                                result.success(id)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    deleteQuotation ->  {
                        try {
                            MainScope().launch {

                                quotationRepo.deleteQuotation(
                                    quotationId = call.argument("quotationId") ?: "",
                                )
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getQuotationsByWorker ->  {
                        try {
                            MainScope().launch {

                                val quotations = quotationRepo.getQuotationsByWorker(
                                    workerId = call.argument("worker") ?: "",
                                )
                                val quotationsMap = mutableMapOf<String, Map<String, String>>()

                                for (quotation in quotations) {
                                    val t = mapOf(
                                        "quotationId" to quotation.quotationId,
                                        "name" to quotation.name,
                                        "info" to quotation.info,
                                        "note" to quotation.note,
                                        "taskId" to quotation.taskId,
                                        "worker" to quotation.worker,
                                        "services" to quotation.services,
                                        "modifiedDate" to quotation.modifiedDate
                                    )
                                    quotationsMap[quotation.quotationId] = t
                                }

                                result.success(quotationsMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getQuotationsByTask ->  {
                        try {
                            MainScope().launch {

                                val quotations = quotationRepo.getQuotationsByTask(
                                    taskId = call.argument("taskId") ?: "",
                                )
                                val quotationsMap = mutableMapOf<String, Map<String, String>>()

                                for (quotation in quotations) {
                                    val t = mapOf(
                                        "quotationId" to quotation.quotationId,
                                        "name" to quotation.name,
                                        "info" to quotation.info,
                                        "note" to quotation.note,
                                        "taskId" to quotation.taskId,
                                        "worker" to quotation.worker,
                                        "services" to quotation.services,
                                        "modifiedDate" to quotation.modifiedDate
                                    )
                                    quotationsMap[quotation.quotationId] = t
                                }

                                result.success(quotationsMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }

                    getAllQuotation -> {
                        try {
                            MainScope().launch {
                                val quotations = quotationRepo.getAllQuotations()
                                val quotationsMap = mutableMapOf<String, Map<String, String>>()

                                for (quotation in quotations) {
                                    val t = mapOf(
                                        "quotationId" to quotation.quotationId,
                                        "name" to quotation.name,
                                        "info" to quotation.info,
                                        "note" to quotation.note,
                                        "taskId" to quotation.taskId,
                                        "worker" to quotation.worker,
                                        "services" to quotation.services,
                                        "modifiedDate" to quotation.modifiedDate
                                    )
                                    quotationsMap[quotation.quotationId] = t
                                }

                                result.success(quotationsMap)
                            }
                        } catch (e: Exception) {
                            result.error(
                                otherErrorCode,
                                otherErrorMsg,
                                e.message,
                            )
                        }
                    }


                    else -> result.error(
                        unimplementedErrorCode,
                        unimplementedErrorMsg,
                        unimplementedErrorMsg
                    )
                }
            }
    }


    private fun getStartAndEndTimestamps(date: String): Pair<Long, Long> {
        val localDate = LocalDate.parse(date) // Format: YYYY-MM-DD
        val startOfDay = localDate.atStartOfDay(ZoneId.systemDefault()).toEpochSecond() * 1000
        val endOfDay = localDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toEpochSecond() * 1000 - 1
        return Pair(startOfDay, endOfDay)
    }

    fun List<LocationEntity>.deduplicated(): List<LocationEntity> {
        val seen = mutableSetOf<String>()
        val result = mutableListOf<LocationEntity>()

        for (location in this) {
            val key = "${location.latitude},${location.longitude},${location.taskId},${location.batteryLevel},${location.event}"
            if (key !in seen) {
                seen.add(key)
                result.add(location)
            }
        }

        return result
    }


    // constants
    private val methodChannelName: String               = "app.channel/native"
    private val nameKey: String                         = "name"
    private val emailKey: String                        = "email"
    private val passwordKey: String                     = "password"
    private val roleKey: String                         = "role"
    private val designationKey: String                  = "designation"
    private val creatorKey: String                      = "creator"
    private val idKey: String                           = "id"
    private val fcmKey: String                          = "fcm"

    // methods name
    private val startLoggingMethod: String              = "startLoggingMethod"
    private val stopLoggingMethod: String               = "stopLoggingMethod"
    private val saveUserData: String                    = "saveUserData"
    private val getSavedUserData: String                = "getSavedUserData"
    private val createUserMethod: String                = "createUser"
    private val updateUserMethod: String                = "updateUser"
    private val deleteUserMethod: String                = "deleteUser"
    private val getUserByIdMethod: String               = "getUserById"
    private val getUserByEmailMethod: String            = "getUserByEmail"
    private val getUsersMethod: String                  = "getUsers"
    private val createTaskMethod : String               = "createTask"
    private val updateTaskMethod : String               = "updateTask"
    private val deleteTaskMethod : String               = "deleteTask"
    private val getAllTasksMethod : String              = "getAllTasks"
    private val getTasksByUserIdMethod : String         = "getTasksByUserId"
    private val logAttendance : String                  = "logAttendance"
    private val updateLoggedTime : String               = "updateLoggedTime"
    private val getUserAttendanceForMonth : String      = "getUserAttendanceForMonth"
    private val getAllAttendanceForDay : String         = "getAllAttendanceForDay"
    private val getAllActiveUsers : String              = "getAllActiveUsers"
    private val getLoggedTimeOrZero : String            = "getLoggedTimeOrZero"
    private val getLocDataByUserId : String             = "getLocDataByUserId"
    private val addQuotation : String                   = "addQuotation"
    private val updateQuotation : String                = "updateQuotation"
    private val deleteQuotation : String                = "deleteQuotation"
    private val getQuotationsByWorker : String          = "getQuotationsByWorker"
    private val getQuotationsByTask : String            = "getQuotationsByTask"
    private val getAllQuotation : String                = "getAllQuotation"
    private val clearSaveLoggedTime : String                = "clearSaveLoggedTime"

    // error codes
    private val otherErrorCode: String          = "111x"
    private val unimplementedErrorCode: String  = "000x"

    // error messages
    private val otherErrorMsg: String           = "catch caught exception"
    private val unimplementedErrorMsg: String   = "Platform Method Unimplemented Error"
}
