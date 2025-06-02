package com.vender.vender_tracker.pref

import android.content.Context
import android.util.Log
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore("user_prefs")

class UserPreferences(private val context: Context) {
    companion object {
        val KEY_LOGGED_TIME = stringPreferencesKey("loggedTime")
        val KEY_USERNAME    = stringPreferencesKey("username")
        val KEY_EMP_ID      = stringPreferencesKey("empId")
    }

    suspend fun saveUser(username: String, empId: String) {
        context.dataStore.edit {
            it[KEY_USERNAME]    = username
            it[KEY_EMP_ID]      = empId
        }
        Log.d("prefUser", "saved name: $username | empId: $empId")
    }

    fun getUser() = context.dataStore.data.map {
        val username = it[KEY_USERNAME]
        val empId = it[KEY_EMP_ID]

        Log.d("prefUser", "get name: $username | empId: $empId")

        if ((username ?: "").isNotEmpty() && (empId ?: "").isNotEmpty())
            Pair(username, empId)
        else
            null
    }

    suspend fun saveLoggedTime(time: String) { // time in min
        context.dataStore.edit {
            it[KEY_LOGGED_TIME] = time
        }
        Log.d("prefUser", "saved time: $time")
    }

    fun getLoggedTime() = context.dataStore.data.map {
        val time = it[KEY_LOGGED_TIME]

        Log.d("prefUser", "get time: $time")

        if ((time ?: "").isNotEmpty()) time
        else null
    }
}