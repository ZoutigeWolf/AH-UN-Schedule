package dev.zoutigewolf.ahun_schedule

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import dev.zoutigewolf.ahun_schedule.api.UserCredentials

class CredentialsManager(context: Context) {
    private val sharedPreferences = EncryptedSharedPreferences.create(
        "credentials",
        MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC),
        context,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun storeUserCredentials(userCredentials: UserCredentials) {
        with(sharedPreferences.edit()) {
            putString("username", userCredentials.username)
            putString("password", userCredentials.password)
            apply()
        }
    }

    fun loadUserCredentials(): UserCredentials? {
        val username = sharedPreferences.getString("username", null)
        val password = sharedPreferences.getString("password", null)

        return if (username != null && password != null) {
            UserCredentials(username, password)
        } else {
            null
        }
    }

    fun deleteUserCredentials() {
        with(sharedPreferences.edit()) {
            remove("username")
            remove("password")
            apply()
        }
    }
}