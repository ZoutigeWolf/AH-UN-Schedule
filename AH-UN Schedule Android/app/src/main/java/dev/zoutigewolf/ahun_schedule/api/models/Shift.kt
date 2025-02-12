package dev.zoutigewolf.ahun_schedule.api.models

import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Shift(
    @SerialName("id") val id: String,
    @SerialName("username") val username: String,
    @SerialName("start") var start: LocalDateTime,
    @SerialName("end") var end: LocalDateTime?,
    @SerialName("canceled") var canceled: Boolean,
    @SerialName("user") val user: User,
)

@Serializable
data class ShiftUpdate(
    @SerialName("start") var start: LocalDateTime?,
    @SerialName("end") var end: LocalDateTime?,
    @SerialName("canceled") var canceled: Boolean?,
)

fun Shift.toUpdate(): ShiftUpdate {
    return ShiftUpdate(
        start = this.start,
        end = this.end,
        canceled = this.canceled
    )
}