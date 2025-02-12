package dev.zoutigewolf.ahun_schedule

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.TimePickerState
import kotlinx.datetime.Clock
import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.plus
import kotlinx.datetime.toJavaLocalDate
import kotlinx.datetime.toJavaLocalDateTime
import kotlinx.datetime.toKotlinLocalDate
import kotlinx.datetime.toKotlinLocalDateTime
import kotlinx.datetime.toKotlinTimeZone
import kotlinx.datetime.toLocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class DateUtils {
    companion object {
        fun now(): LocalDate {
            return Clock.System.now().toLocalDateTime(ZoneId.systemDefault().toKotlinTimeZone()).date
        }

        fun getFirstDayOfWeek(date: LocalDate): LocalDate {
            val jDate = date.toJavaLocalDate()

            return jDate.with(DayOfWeek.MONDAY).toKotlinLocalDate()
        }
        fun getDaysInWeek(date: LocalDate): List<LocalDate> {
            val first = getFirstDayOfWeek(date)

            return (0 until 7).map {
                first.plus(it, DateTimeUnit.DAY)
            }
        }
    }
}

fun LocalDate.toString(format: String): String {
    val formatter = DateTimeFormatter.ofPattern(format)

    return formatter.format(this.toJavaLocalDate())
}

fun LocalDateTime.toString(format: String): String {
    val formatter = DateTimeFormatter
        .ofPattern(format)

    return formatter.format(this.toJavaLocalDateTime())
}

fun LocalDateTime.setTime(hour: Int, minute: Int): LocalDateTime {
    return this
        .toJavaLocalDateTime()
        .withHour(hour)
        .withMinute(minute)
        .toKotlinLocalDateTime()
}