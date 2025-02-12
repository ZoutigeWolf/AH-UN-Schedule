package dev.zoutigewolf.ahun_schedule.api

import dev.zoutigewolf.ahun_schedule.api.models.User
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.Serializable
import okhttp3.OkHttpClient

class AuthManager {
    companion object {
        private var instance: AuthManager? = null

        fun shared(): AuthManager {
            if (instance == null) {
                instance = AuthManager()
            }

            return instance!!
        }
    }

    val serverUrl: String = "https://ah-un.zoutigewolf.dev"

    val httpClient: OkHttpClient = OkHttpClient()

    private val _token = MutableStateFlow<String?>(null)
    val token: StateFlow<String?> = _token

    private val _user = MutableStateFlow<User?>(null)
    val user: StateFlow<User?> = _user

    fun login(credentials: UserCredentials, onCompletion: (Boolean) -> Unit) {
        Requests.post<UserCredentials, AuthResponse>("/auth/login", credentials) { success, data ->
            if (!success || data == null) {
                onCompletion(false)
                return@post
            }

            _token.value = data.token
            onCompletion(true)

            fetchUser()
        }
    }

    fun logout() {
        _token.value = null
        _user.value = null


    }

    private fun fetchUser() {
        Requests.get<User>("/auth/me") { _, data ->
            _user.value = data
        }
    }
}

@Serializable
data class UserCredentials(val username: String, val password: String)


@Serializable
data class AuthResponse(val token: String)