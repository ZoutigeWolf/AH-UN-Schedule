package dev.zoutigewolf.ahun_schedule.api

import kotlinx.serialization.json.Json
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import java.io.IOException

class Requests {
    companion object {
        val httpClient: OkHttpClient = OkHttpClient()

        inline fun <reified TResponse> get(
            path: String,
            crossinline onCompletion: (success: Boolean, data: TResponse?) -> Unit
        ) {
            val request = Request.Builder()
                .url(AuthManager.shared().serverUrl + path)
                .header("Authorization", ("Bearer " + AuthManager.shared().token.value) ?: "")
                .get()
                .build()

            httpClient.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    onCompletion(false, null)
                }

                override fun onResponse(call: Call, response: Response) {
                    if (!response.isSuccessful) {
                        onCompletion(false, null)
                        return
                    }

                    val body = response.body?.string()

                    if (body == null) {
                        onCompletion(false, null)
                        return
                    }

                    try {
                        val responseData = Json.decodeFromString<TResponse>(body)
                        onCompletion(true, responseData)
                    } catch (e: Exception) {
                        onCompletion(false, null)
                    }
                }
            })
        }

        inline fun <reified TPayload, reified TResponse> post(
            path: String,
            data: TPayload,
            crossinline onCompletion: (success: Boolean, data: TResponse?) -> Unit
        ) {
            val payload = Json.encodeToString(data)
                .toRequestBody("application/json; charset=utf-8".toMediaType())

            val request = Request.Builder()
                .url(AuthManager.shared().serverUrl + path)
                .header("Authorization", ("Bearer " + AuthManager.shared().token.value) ?: "")
                .post(payload)
                .build()

            httpClient.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    onCompletion(false, null)
                }

                override fun onResponse(call: Call, response: Response) {
                    if (!response.isSuccessful) {
                        onCompletion(false, null)
                        return
                    }

                    if (TResponse::class == Unit::class) {
                        onCompletion(true, null)
                        return
                    }

                    val body = response.body?.string()

                    if (body == null) {
                        onCompletion(false, null)
                        return
                    }

                    try {
                        val responseData = Json.decodeFromString<TResponse>(body)
                        onCompletion(true, responseData)
                    } catch (e: Exception) {
                        onCompletion(false, null)
                        return
                    }
                }
            })
        }

        inline fun <reified TPayload, reified TResponse> patch(
            path: String,
            data: TPayload,
            crossinline onCompletion: (success: Boolean, data: TResponse?) -> Unit
        ) {
            val payload = Json.encodeToString(data)
                .toRequestBody("application/json; charset=utf-8".toMediaType())

            val request = Request.Builder()
                .url(AuthManager.shared().serverUrl + path)
                .header("Authorization", ("Bearer " + AuthManager.shared().token.value) ?: "")
                .patch(payload)
                .build()

            httpClient.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    onCompletion(false, null)
                }

                override fun onResponse(call: Call, response: Response) {
                    if (!response.isSuccessful) {
                        onCompletion(false, null)
                        return
                    }

                    if (TResponse::class == Unit::class) {
                        onCompletion(true, null)
                        return
                    }

                    val body = response.body?.string()

                    if (body == null) {
                        onCompletion(false, null)
                        return
                    }

                    try {
                        val responseData = Json.decodeFromString<TResponse>(body)
                        onCompletion(true, responseData)
                    } catch (e: Exception) {
                        onCompletion(false, null)
                        return
                    }
                }
            })
        }
    }
}