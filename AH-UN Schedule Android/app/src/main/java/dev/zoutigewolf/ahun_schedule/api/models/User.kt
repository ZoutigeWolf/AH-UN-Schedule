package dev.zoutigewolf.ahun_schedule.api.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class User(
    @SerialName("username") val username: String,
    @SerialName("name") val name: String,
    @SerialName("admin") val isAdmin: Boolean
)

@Serializable
data class UserUpdate(
    @SerialName("admin") val isAdmin: Boolean
)